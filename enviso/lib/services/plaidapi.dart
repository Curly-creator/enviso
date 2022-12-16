import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'dart:convert';
//import 'package:plaid_link/plaid_link.dart';

// Replace these values with your own API keys and options
String baseUrl = 'https://sandbox.plaid.com';
String clientId = '635fb7749f143e0013c8b0b0';
String secret = '4677ec60b05fb453e0b629a6f0df50';
String accessToken = 'your-access-token';

// generate link token
Future<String> generateLinkToken() async {
  final Uri url = Uri.parse(baseUrl + '/link/token/create');
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
    'products': ['auth'],
    'country_codes': ['DE'],
    'language': 'de',
  };
// manage http response from Plaid and display response on screen
  final http.Response response =
      await http.post(url, headers: headers, body: json.encode(body));
  final Map<String, dynamic> responseData = json.decode(response.body);
  if (response.statusCode == 200) {
    return responseData['link_token'];
  } else {
    throw Exception(responseData['error_message']);
  }
}

// exchange public token for access token
Future<String> exchangeLinkToken(String publicToken) async {
  final Uri url = Uri.parse(baseUrl + '/item/public_token/exchange');
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

// function start link