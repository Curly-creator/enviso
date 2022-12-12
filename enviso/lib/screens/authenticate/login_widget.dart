import 'package:enviso/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  final VoidCallback onClickedSignUp;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Login',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const Text(
              'E-Mail',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(30, 201, 105, 1.0),
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'E-Mail eingeben'),
            ),
            const SizedBox(height: 4),
            const Text(
              'Passwort',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Color.fromRGBO(30, 201, 105, 1.0),
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            TextField(
              controller: passwordController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Passwort eingeben'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(30, 201, 105, 1.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0))),
                child: const Text(
                  'Anmelden',
                  style: TextStyle(fontSize: 12, fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    text: 'Du hast kein Konto? ',
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Registrieren',
                      style: const TextStyle(
                        color: Color.fromRGBO(30, 201, 105, 1.0),
                        fontWeight: FontWeight.bold,
                      ))
                ]))
          ],
        ),
      );

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on Exception catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
