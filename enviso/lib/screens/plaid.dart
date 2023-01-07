import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:enviso/services/database.dart';

String baseUrl = 'https://sandbox.plaid.com';
String clientId = '635fb7749f143e0013c8b0b0';
String secret = '4677ec60b05fb453e0b629a6f0df50';

class PlaidScreen extends StatefulWidget {
  const PlaidScreen({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PlaidScreen> {
  LinkConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  LinkObject? _successObject;

  @override
  void initState() {
    super.initState();

    /*_streamEvent = PlaidLink.onEvent.listen(_onEvent);*/
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);
  }

  @override
  void dispose() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    super.dispose();
  }

  Future generateLinkToken() async {
    final Uri url = Uri.parse('$baseUrl/link/token/create');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'client_id': clientId,
      'secret': secret,
      'user': {
        'client_user_id': 'user-id',
      },
      'client_name': 'Enviso',
      'products': ['auth', 'transactions'],
      'country_codes': ['DE'],
      'language': 'de',
      'android_package_name': 'com.plaid.enviso'
    };
    final http.Response response =
        await http.post(url, headers: headers, body: json.encode(body));
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData['link_token'];
    } else {
      throw Exception(responseData['error_message']);
    }
  }

  Future exchangeLinkToken(String publicToken) async {
    final Uri url = Uri.parse('$baseUrl/item/public_token/exchange');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> body = {
      'client_id': clientId,
      'secret': secret,
      'public_token': publicToken,
    };
    final http.Response response =
        await http.post(url, headers: headers, body: json.encode(body));
    final Map<String, dynamic> responseData = json.decode(response.body);
    print("Access Token: " + responseData['access_token']);
    if (response.statusCode == 200) {
      return responseData['access_token'];
    } else {
      throw Exception(responseData['error_message']);
    }
  }

  /*void _onEvent(LinkEvent event) {
    final name = event.name;
    final metadata = event.metadata.description();
    print("onEvent: $name, metadata: $metadata");
  }*/

  Future<void> _onSuccess(LinkSuccess event) async {
    final token = event.publicToken;
    final metadata = event.metadata.description();
    print("onSuccess: $token, metadata: $metadata");
    setState(() => _successObject = event);
    String accessToken = await exchangeLinkToken(token);

    DatabaseService.updateTokenPlaid(accessToken);
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    print("onExit metadata: $metadata, error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    _configuration?.toJson().toString() ?? "",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Connect Bank Account'),
                onPressed: () async {
                  String LinkToken = await generateLinkToken();
                  LinkConfiguration configuration =
                      LinkTokenConfiguration(token: LinkToken);
                  PlaidLink.open(configuration: configuration);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
