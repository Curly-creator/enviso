import 'package:enviso/main.dart';
import 'package:enviso/screens/onboarding.dart';
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
  final confirmPasswordController = TextEditingController();
  final bool _obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              Image.asset('assets/images/2zero.jpg', scale: 7.0),
              const SizedBox(height: 40),
              buildEmail(),
              const SizedBox(height: 40),
              buildPassword(),
              const SizedBox(height: 30),
              buildConfirmPassword(),
              const SizedBox(height: 30),
              buildLoginButton(),
              const SizedBox(height: 30),
              buildSignInButton()
            ],
          ),
        ),
      );

  Widget buildEmail() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Bitte melde dich an.',
        style: headline1,
        textAlign: TextAlign.left,
      ),
      const SizedBox(height: 5),
      const Text(
        'Gib deine E-Mail Adresse an, um fortzufahren.',
        style: headline6,
        textAlign: TextAlign.left,
      ),
      const SizedBox(height: 40),
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
        validator: (email) => email != null && !EmailValidator.validate(email)
            ? 'Bitte gib eine valide E-Mail ein'
            : null,
      ),
    ]);
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
                    _obscureText != _obscureText;
                  });
                },
              )),
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (password) {
            if (password!.isEmpty) return 'Bitte gib ein Passwort ein.';
            if (password.length < 6) {
              return 'Dein Passwort muss mindestens 6 Zeichen enthalten.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildConfirmPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passwort wiederholen',
          style: startText,
          textAlign: TextAlign.left,
        ),
        TextFormField(
          controller: confirmPasswordController,
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
          validator: (confirmPassword) {
            if (confirmPassword!.isEmpty) {
              return 'Bitte validiere dein Passwort.';
            }
            if (confirmPassword != passwordController.text) {
              return 'Die Passwörter stimmen nicht überein.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return ElevatedButton(
      onPressed: signUp,
      style: ElevatedButton.styleFrom(
          backgroundColor: colorGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0))),
      child: const Text(
        'Anmelden',
        style: buttonText,
      ),
    );
  }

  Widget buildSignInButton() {
    return RichText(
        text: TextSpan(
            style: headline5,
            text: 'Du hast schon ein Konto? ',
            children: [
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = widget.onClickedSignIn,
              text: 'Login',
              style: startText)
        ]));
  }

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
      DatabaseService.createUser();
    } on Exception catch (e) {
      print(e);
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Onboarding()));
    // navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  // Future signUp() async {
  //   print('Helllo');
  //   final isValid = fromKey.currentState!.validate();
  //   if (!isValid) return;
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(
  //             child: CircularProgressIndicator(),
  //           ));
  //   try {
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim());
  //     await DatabaseService.createUser();
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  //   print('Helllo222');
  //   Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (context) => const Onboarding()));
  //   // navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }
}
