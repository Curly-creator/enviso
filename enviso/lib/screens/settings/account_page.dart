import 'package:enviso/services/database.dart';
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
      title: 'Account Settings',
      subtitle: 'More Details for better calculations',
      leading: const IconWidget(
        icon: Icons.person,
        color: Colors.green,
      ),
      child: SettingsScreen(
        children: <Widget>[
          buildFuelType(),
          buildCarSize(),
          buildName(),
        ],
      ));

  Widget buildFuelType() => DropDownSettingsTile(
        settingKey: keyFuel,
        title: 'Fuel Type',
        selected: 1,
        values: const <int, String>{
          1: 'Petrol',
          2: 'Diesel',
          3: 'Electic',
          4: 'LPG',
        },
        onChange: (fuelType) => DatabaseService().updateFuelType(fuelType),
      );

  Widget buildCarSize() => DropDownSettingsTile(
        settingKey: keySize,
        title: 'Car Size',
        selected: 1,
        values: const <int, String>{
          1: 'big',
          2: 'medium',
          3: 'small',
        },
        onChange: (carSize) => DatabaseService().updateCarSize(carSize),
      );

  Widget buildName() => TextInputSettingsTile(
        settingKey: keyName,
        title: 'Username',
        initialValue: 'Username',
        onChange: (name) => DatabaseService().updateUsername(name),
      );
}
