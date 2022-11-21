import 'dart:convert';
import 'package:enviso/services/firestore.dart';
import 'package:enviso/main.dart';
import 'package:enviso/services/database.dart';
import 'package:enviso/services/userdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import '../../services/utils.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({
    Key? key,
    required this.OnClickedSignIn,
  }) : super(key: key);

  final VoidCallback OnClickedSignIn;

  @override
  State<SignUpWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<SignUpWidget> {
  final fromKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: fromKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Password'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (password) => password != null && password.length < 6
                    ? 'Enter min. 6 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: signUp,
                  icon: const Icon(Icons.lock_open, size: 32),
                  label: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24),
                  )),
              const SizedBox(height: 24),
              RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      text: 'Already have an account? ',
                      children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.OnClickedSignIn,
                        text: 'Sign In',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.secondary,
                        ))
                  ]))
            ],
          ),
        ),
      );

  Future signUp() async {
    final isValid = fromKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    //register with email & password
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      final user = FirebaseAuth.instance.currentUser!;
      //create a new document for the user with the uid

      UserData test = UserData(uid: user.uid);
      test.name = 'Fenia';
      await DataBaseFireStore().updateUserData(test);

      // print(user.uid);
      // await DatabaseService(uid: user.uid).updateUserData('vehicle', 0);
    } on Exception catch (e) {
      Utils.showSnackBar(e.toString());
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
