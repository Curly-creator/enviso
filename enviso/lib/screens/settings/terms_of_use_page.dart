import 'package:enviso/utils/constants.dart';
import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Nutzungsbedingungen'),
        ),
        body: SafeArea(
          child: Column(
            children: const [
              SizedBox(
                height: 32,
              ),
              Text(
                'Nutzungsbedingungen',
                style: headline1,
              ),
            ],
          ),
        ),
      );
}
