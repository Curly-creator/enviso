import 'package:enviso/services/database.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/widgets/icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountPage extends StatelessWidget {
  static const keyFuel = 'key-fuel';
  static const keySize = 'key-size';
  static const keyName = 'key-name';

  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) => SimpleSettingsTile(
      title: 'Profil bearbeiten',
      leading: const IconWidget(
        icon: Icons.person,
        color: colorGreen,
      ),
      child: SettingsScreen(
        children: <Widget>[
          buildFuelType(),
          buildEngineSize(),
          buildUsername(),
        ],
      ));

  Widget buildFuelType() => DropDownSettingsTile(
        settingKey: keyFuel,
        title: 'Kraftstoff Art des Fahrzeugs',
        selected: 1,
        values: const <int, String>{
          1: 'Diesel',
          2: 'Petrol',
          3: 'CNG',
          4: 'Hydrogen',
          5: 'Electric',
        },
        onChange: (fuelType) => DatabaseService().updateFuelType(fuelType),
      );

  Widget buildEngineSize() => DropDownSettingsTile(
        settingKey: keySize,
        title: 'Motorgröße',
        selected: 1,
        values: const <int, String>{
          1: 'small',
          2: 'medium',
          3: 'large',
        },
        onChange: (engineSize) =>
            DatabaseService().updateEngineSize(engineSize),
      );

  Widget buildUsername() => TextInputSettingsTile(
        settingKey: keyName,
        title: 'Name',
        initialValue: 'Username',
        onChange: (name) => DatabaseService().updateUsername(name),
      );
}