import 'package:enviso/main.dart';
import 'package:enviso/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:functions/model/error.dart';

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
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/2zero.jpg',
              scale: 7.0,
            ),
            const SizedBox(height: 40),
            buildEmail(),
            const SizedBox(height: 40),
            buildPassword(),
            const SizedBox(height: 30),
            buildLoginButton(),
            const SizedBox(height: 30),
            buildSignUpButton(),
          ],
        ),
      );

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login',
          style: headline1,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 30),
        const Text('E-Mail', style: startText),
        const SizedBox(height: 3),
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
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passwort',
          style: startText,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 3),
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
      ],
    );
  }

  Widget buildLoginButton() {
    return ElevatedButton(
        onPressed: signIn,
        style: ElevatedButton.styleFrom(
            backgroundColor: colorGreen,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0))),
        child: const Text(
          'Anmelden',
          style: buttonText,
          textAlign: TextAlign.center,
        ));
  }

  Widget buildSignUpButton() {
    return RichText(
        text:
            TextSpan(style: headline5, text: 'Du hast kein Konto? ', children: [
      TextSpan(
          recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignUp,
          text: 'Registrieren',
          style: startText)
    ]));
  }

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
