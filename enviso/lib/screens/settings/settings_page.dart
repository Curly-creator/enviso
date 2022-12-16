import 'package:enviso/screens/settings/account_page.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/widgets/icon_widget.dart';
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
          title: const Text('Einstellungen'),
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(title: 'Mein Profil', children: <Widget>[
              buildProfile(),
              const AccountPage(),
              buildDarkMode(),
              buildLogout(),
              buildDeleteAccount(),
            ]),
            const SizedBox(
              height: 32,
            ),
            SettingsGroup(title: 'Feedback', children: <Widget>[
              buildReportBug(context),
              buildSendFeedback(context),
            ])
          ],
        )),
      );

  Widget buildProfile() => TextInputSettingsTile(
      title: 'Name',
      initialValue: 'Username',
      settingKey: 'keyName',
      onChange: (name) => DatabaseService().updateUsername(name));

  Widget buildLogout() => SimpleSettingsTile(
        title: 'Abmelden',
        leading: const IconWidget(
          icon: Icons.logout,
          color: colorGreen,
        ),
        onTap: () => FirebaseAuth.instance.signOut(),
      );

  Widget buildDeleteAccount() => SimpleSettingsTile(
        title: 'Account löschen',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.delete,
          color: colorGreen,
        ),
        onTap: () {
          //await DatabaseService().deleteuser();
          FirebaseAuth.instance.currentUser!.delete();
        },
      );

  Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
        title: 'Fehler melden',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.bug_report,
          color: Colors.brown,
        ),
        onTap: () async {},
      );

  Widget buildSendFeedback(BuildContext context) => SimpleSettingsTile(
        title: 'Feedback senden',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.feedback,
          color: Colors.purple,
        ),
        onTap: () async {},
      );

  Widget buildDarkMode() => SwitchSettingsTile(
        title: 'Dark Mode',
        settingKey: keyDarkMode,
        leading: const IconWidget(
          icon: Icons.dark_mode,
          color: Colors.black,
        ),
      );
}
