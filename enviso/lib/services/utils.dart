import 'package:flutter/material.dart';

class Utils {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red);

    // messengerKey.currentState!  **** Something is not working
    //   ..removeCurrentSnackBar()
    //   ..showSnackBar(snackBar);
  }
}
