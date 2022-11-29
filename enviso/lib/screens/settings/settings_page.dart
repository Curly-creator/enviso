import 'package:enviso/screens/settings/account_page.dart';
import 'package:enviso/services/database.dart';
import 'package:enviso/widgets/icon_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const keyDarkMode = 'key-dark-mode';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Name'),
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(title: 'GENERAL', children: <Widget>[
              buildDarkMode(),
              const AccountPage(),
              buildLogout(),
              buildDeleteAccount(),
            ]),
            const SizedBox(
              height: 32,
            ),
            SettingsGroup(title: 'FEEDBACK', children: <Widget>[
              buildReportBug(context),
              buildSendFeedback(context)
            ])
          ],
        )),
      );

  Widget buildLogout() => SimpleSettingsTile(
        title: 'Logout',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.logout,
          color: Colors.green,
        ),
        onTap: () => FirebaseAuth.instance.signOut(),
      );

  Widget buildDeleteAccount() => SimpleSettingsTile(
        title: 'Delet Account',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.delete,
          color: Colors.red,
        ),
        onTap: () {
          DatabaseService().deleteuser();
          FirebaseAuth.instance.currentUser!.delete();
        },
      );

  Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
        title: 'Report a Bug',
        subtitle: '',
        leading: const IconWidget(
          icon: Icons.bug_report,
          color: Colors.brown,
        ),
        onTap: () async {},
      );

  Widget buildSendFeedback(BuildContext context) => SimpleSettingsTile(
        title: 'Send Feedback',
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
