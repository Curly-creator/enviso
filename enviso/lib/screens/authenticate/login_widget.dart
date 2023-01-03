import 'package:enviso/main.dart';
import 'package:enviso/utils/constants.dart';
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

  bool _obscureText = true;

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
            Image.asset('images/2zero.jpg', scale: 7.0),
            const SizedBox(height: 40),
            const Text(
              'Login',
              style: headline1,
              textAlign: TextAlign.left,
            ),
            const Text(
              'E-Mail',
              style: startText,
              textAlign: TextAlign.left,
            ),
            //Email eingeben
            TextField(
              controller: emailController,
              cursorColor: colorWhite,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                  labelText: 'E-Mail eingeben',
                  labelStyle: TextStyle(
                    color: colorBlackLight,
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorBlackLight)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorGreen))),
            ),
            const SizedBox(height: 4),
            const Text(
              'Passwort',
              style: startText,
              textAlign: TextAlign.left,
            ),
            //Passwort eingeben
            TextFormField(
              controller: passwordController,
              cursorColor: colorWhite,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: 'Passwort eingeben',
                  labelStyle: const TextStyle(
                    color: colorBlackLight,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: colorBlackLight)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: colorGreen)),
                  suffixIcon: IconButton(
                    color: colorBlackLight,
                    icon: _obscureText
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )),
              obscureText: _obscureText,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0))),
                child: const Text(
                  'Anmelden',
                  style: buttonText,
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            RichText(
                text: TextSpan(
                    style: headline5,
                    text: 'Du hast kein Konto? ',
                    children: [
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: 'Registrieren',
                      style: startText)
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
