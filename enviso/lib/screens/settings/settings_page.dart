import 'package:enviso/screens/settings/account_page.dart';
import 'package:enviso/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:enviso/services/database.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const keyDarkMode = 'key-dark-mode';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: colorBlack),
          backgroundColor: colorWhite,
          title: const Text('Einstellungen'),
          titleTextStyle: headline3,
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(
                title: 'Mein Profil',
                titleTextStyle: headline4,
                children: <Widget>[
                  buildProfile(),
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
                  buildTermsOfUse(),
                  buildPrivacyPolicy(),
                  buildDeleteAccount(),
                ])
          ],
        )),
      );

  Widget buildProfile() => Row(
        children: [
          const Expanded(
            child: CircleAvatar(
              radius: 25,
              backgroundColor: colorGreen,
              child: Icon(
                Icons.person,
                color: colorWhite,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TextInputSettingsTile(
                  title: '',
                  titleTextStyle: headline2,
                  initialValue: 'Name',
                  settingKey: 'keyName',
                  onChange: (name) => DatabaseService().updateUsername(name),
                ),
                const Text('E-Mail: name@mail.de'),
              ],
            ),
          )
        ],
      );

  Widget buildLogout() => SimpleSettingsTile(
        title: 'Abmelden',
        titleTextStyle: headline4,
        leading: const Icon(Icons.logout_outlined),
        onTap: () => FirebaseAuth.instance.signOut(),
      );

  Widget buildDeleteAccount() => SimpleSettingsTile(
        title: 'Account löschen',
        titleTextStyle: redText,
        subtitle: '',
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
        subtitle: '',
        titleTextStyle: headline4,
        leading: const Icon(Icons.bug_report),
        onTap: () async {},
      );

  Widget buildSendFeedback(BuildContext context) => SimpleSettingsTile(
        title: 'Feedback senden',
        subtitle: '',
        titleTextStyle: headline4,
        leading: const Icon(Icons.feedback),
        onTap: () async {},
      );

  Widget buildTermsOfUse() => SimpleSettingsTile(
        title: 'Nutzungsbedinungen',
        subtitle: '',
        titleTextStyle: headline4,
        leading: const Icon(Icons.verified_user),
        onTap: () async {},
      );

  Widget buildPrivacyPolicy() => SimpleSettingsTile(
        title: 'Datenschutzbedingung',
        subtitle: '',
        titleTextStyle: headline4,
        leading: const Icon(Icons.info_outline),
        onTap: () async {},
      );

  Widget buildDarkMode() => SwitchSettingsTile(
        title: 'Dark Mode',
        settingKey: keyDarkMode,
        titleTextStyle: headline4,
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
