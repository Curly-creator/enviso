import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';
import 'database.dart';

String baseUrl = 'https://sandbox.plaid.com';
String clientId = '635fb7749f143e0013c8b0b0';
String secret = '4677ec60b05fb453e0b629a6f0df50';

class PlaidService {
  LinkConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  LinkObject? _successObject;

  PlaidService(){
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);
  }

  Future<void> _onSuccess(LinkSuccess event) async {
    final token = event.publicToken;
    final metadata = event.metadata.description();
    _successObject = event;
    String accessToken = await exchangeLinkToken(token);
    print('0000000::: 0000000');
    DatabaseService.updateTokenPlaid(accessToken);
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    print("onExit metadata: $metadata, error: $error");
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
    if (response.statusCode == 200) {
      return responseData['access_token'];
    } else {
      throw Exception(responseData['error_message']);
    }
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
}
