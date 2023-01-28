import 'package:enviso/main.dart';
import 'package:enviso/screens/settings/account_page.dart';
import 'package:enviso/screens/settings/privacy_page.dart';
import 'package:enviso/screens/settings/terms_of_use_page.dart';
import 'package:enviso/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:enviso/services/database.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const keyDarkMode = 'key-dark-mode';
  static const keyName = 'key-name';

  static const String email = 'test@email.de';
  static const String name = 'Dein Name';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Einstellungen'),
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(
                title: 'Mein Profil',
                titleTextStyle: headline4,
                children: <Widget>[
                  const SizedBox(
                    height: 12,
                  ),
                  buildProfile(),
                  const SizedBox(
                    height: 12,
                  ),
                  buildAccountPage(context),
                  buildDarkMode(),
                  buildLogout(),
                ]),
            const SizedBox(
              height: 32,
            ),
            SettingsGroup(
                title: 'Feedback',
                titleTextStyle: headline4,
                children: <Widget>[
                  buildReportBug(context),
                  buildSendFeedback(context),
                ]),
            const SizedBox(
              height: 32,
            ),
            SettingsGroup(
                title: 'Zustimmungen & Datenschutz',
                titleTextStyle: headline4,
                children: <Widget>[
                  buildTermsOfUse(context),
                  buildPrivacyPolicy(context),
                  buildDeleteAccount(),
                ])
          ],
        )),
      );

  Widget buildProfile() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 25,
            backgroundColor: colorGreen,
            child: Icon(
              Icons.person,
              color: colorWhite,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text('Name: $name'),
              Text('Email: $email'),
            ],
          ),
          // const Expanded(
          //   child: CircleAvatar(
          //     radius: 25,
          //     backgroundColor: colorGreen,
          //     child: Icon(
          //       Icons.person,
          //       color: colorWhite,
          //     ),
          //   ),
          // ),
          // Expanded(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       TextInputSettingsTile(
          //         title: 'Name',
          //         titleTextStyle: headline6,
          //         initialValue: keyName,
          //         settingKey: 'key-name',
          //         onChange: (name) => DatabaseService.updateUsername(name),
          //       ),
          //       const Text('E-Mail: $email'),
          //     ],
          //   ),
          // )
        ],
      );

  Widget buildLogout() => SimpleSettingsTile(
        title: 'Abmelden',
        titleTextStyle: headline4,
        leading: const Icon(Icons.logout_outlined),
        onTap: () {
          FirebaseAuth.instance.signOut();
          MaterialPageRoute(builder: (context) => const PrivacyPage());
          navigatorKey.currentState!.popUntil((route) => route.isFirst);
        },
      );

  Widget buildDeleteAccount() => SimpleSettingsTile(
        title: 'Account löschen',
        titleTextStyle: redText,
        leading: const Icon(
          Icons.delete,
          color: colorRed,
        ),
        onTap: () {
          //await DatabaseService().deleteuser();
          FirebaseAuth.instance.currentUser!.delete();
        },
      );

  Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
        title: 'Fehler melden',
        titleTextStyle: headline4,
        leading: const Icon(Icons.bug_report),
        onTap: () async {},
      );

  Widget buildSendFeedback(BuildContext context) => SimpleSettingsTile(
        title: 'Feedback senden',
        titleTextStyle: headline4,
        leading: const Icon(Icons.feedback),
        onTap: () async {},
      );

  Widget buildTermsOfUse(BuildContext context) => SimpleSettingsTile(
        title: 'Nutzungsbedinungen',
        titleTextStyle: headline4,
        leading: const Icon(Icons.verified_user),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TermsOfUsePage()));
        },
      );

  Widget buildPrivacyPolicy(BuildContext context) => SimpleSettingsTile(
        title: 'Datenschutzbedingungen',
        titleTextStyle: headline4,
        leading: const Icon(Icons.info_outline),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacyPage()));
        },
      );

  Widget buildDarkMode() => SwitchSettingsTile(
        title: 'Dark Mode',
        titleTextStyle: headline4,
        settingKey: keyDarkMode,
        leading: const Icon(Icons.dark_mode),
      );

  Widget buildAccountPage(BuildContext context) => SimpleSettingsTile(
        title: 'Profil bearbeiten',
        titleTextStyle: headline4,
        leading: const Icon(Icons.create),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountPage()));
        },
      );
}
