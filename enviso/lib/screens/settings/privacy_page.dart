import 'package:enviso/utils/constants.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Datenschutzbedingungen'),
        ),
        body: SafeArea(
          child: Column(
            children: const [
              SizedBox(
                height: 32,
              ),
              Text(
                'Datenschutzbedingungen',
                style: headline1,
              ),
            ],
          ),
        ),
      );
}
