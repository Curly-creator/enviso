import 'package:enviso/main.dart';
import 'package:enviso/services/database.dart';
import 'package:enviso/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  final VoidCallback onClickedSignIn;

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
              Image.asset('images/2zero.jpg', scale: 7.0),
              const SizedBox(height: 40),
              const Text(
                'Bitte melde dich an.',
                style: headline1,
                textAlign: TextAlign.left,
              ),
              const Text(
                'Gib deine E-Mail Adresse an, um fortzufahren.',
                style: headline6,
                textAlign: TextAlign.left,
              ),
              const Text(
                'E-Mail',
                style: startText,
                textAlign: TextAlign.left,
              ),
              TextFormField(
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Bitte gib eine valide E-Mail ein'
                        : null,
              ),
              const SizedBox(height: 4),
              const Text(
                'Passwort',
                style: startText,
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: passwordController,
                cursorColor: colorWhite,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Passwort eingeben',
                    labelStyle: TextStyle(
                      color: colorBlackLight,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorBlackLight)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorGreen))),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (password) => password != null && password.length < 6
                    ? 'Dein Passwort stimmt nicht überein.'
                    : null,
              ),
              const SizedBox(height: 4),
              const Text(
                'Passwort wiederholen',
                style: startText,
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: passwordController,
                cursorColor: colorWhite,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Passwort eingeben',
                    labelStyle: TextStyle(
                      color: colorBlackLight,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorBlackLight)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorGreen))),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (password) => password != null && password.length < 6
                    ? 'Dein Passwort muss mindestens 6 Zeichen enthalten'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0))),
                  child: const Text(
                    'Anmelden',
                    style: buttonText,
                  )),
              const SizedBox(height: 24),
              RichText(
                  text: TextSpan(
                      style: headline5,
                      text: 'Du hast schon ein Konto? ',
                      children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignIn,
                        text: 'Login',
                        style: startText)
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
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      await DatabaseService().createUser();
    } on Exception catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
