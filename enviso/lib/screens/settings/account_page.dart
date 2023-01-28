import 'package:enviso/services/database.dart';
import 'package:enviso/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountPage extends StatelessWidget {
  static const keyFuel = 'key-fuel';
  static const keySize = 'key-size';
  static const keyName = 'key-name';

  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profil bearbeiten',
            style: headline3,
          ),
        ),
        body: SafeArea(
            child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(
                title: 'Profilinformationen',
                titleTextStyle: headline4,
                children: <Widget>[buildUsername()]),
            SettingsGroup(
                title: 'weitere Informationen',
                titleTextStyle: headline4,
                children: <Widget>[buildFuelType(), buildEngineSize()])
          ],
        )),
      );

  Widget buildUsername() => TextInputSettingsTile(
        title: 'Name',
        titleTextStyle: headline6,
        initialValue: keyName,
        settingKey: 'key-name',
        onChange: (name) => DatabaseService.updateUsername(name),
      );

  Widget buildFuelType() => DropDownSettingsTile(
        settingKey: keyFuel,
        title: 'Kraftstoff deines Fahrzeugs',
        titleTextStyle: headline4,
        selected: 1,
        values: const <int, String>{
          1: 'Diesel',
          2: 'Benzin',
          3: 'CNG',
          4: 'Wasserstoff',
          5: 'Elektrisch',
        },
        onChange: (fuelType) => DatabaseService.updateFuelType(fuelType),
      );

  Widget buildEngineSize() => DropDownSettingsTile(
        settingKey: keySize,
        title: 'Motorgröße',
        titleTextStyle: headline4,
        selected: 1,
        values: const <int, String>{
          1: 'klein',
          2: 'mittel',
          3: 'groß',
        },
        onChange: (engineSize) => DatabaseService.updateEngineSize(engineSize),
      );
}
