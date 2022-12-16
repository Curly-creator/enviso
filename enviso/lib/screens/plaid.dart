import 'package:enviso/services/database.dart';
import 'package:enviso/services/transportdata.dart';
import 'package:flutter/material.dart';
import 'package:enviso/services/transportapi.dart';
import 'package:enviso/services/plaidapi.dart';

class PlaidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Plaid'),
        ),
        body: Center(
            // create elevated button that calls generateLinkToken(). If token is successfully generated, then call exchangeLinkToken() with the generated token
            child: ElevatedButton(
                child: Text('Get Plaid Link Token'),
                onPressed: () async {
                  String token = await generateLinkToken();
                  print(token);
                  //startLink(token);
                })));
  }
}
