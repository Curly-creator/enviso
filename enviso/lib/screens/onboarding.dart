import 'package:enviso/screens/home/home_page.dart';
import 'package:enviso/screens/plaid.dart';
import 'package:enviso/services/plaid_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:enviso/utils/constants.dart';
import 'package:enviso/services/database.dart';

import '../services/transportapi.dart';

const List<String> fuelTypes = <String>[
  'Diesel',
  'Petrol',
  'CNG',
  'Hydrogen',
  'Electric'
];
const List<String> motorSizes = <String>['small', 'medium', 'large'];

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  static const keyFuel = 'key-fuel';
  static const keySize = 'key-size';
  static const keyName = 'key-name';

  int currentStep = 0;
  int fuelType = 0;
  int engineSize = 0;
  bool isCompleted = false;
  String username = '';
  String plaidToken = '';
  String filepath = '';

  @override
  Widget build(BuildContext context) => Scaffold(
      body: isCompleted
          ? const HomePage()
          : Stepper(
              type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: currentStep,
              onStepTapped: (step) => setState(() => currentStep = step),
              onStepContinue: () {
                final isLastStep = currentStep == getSteps().length - 1;

                if (isLastStep) {
                  DatabaseService.updateEngineSize(engineSize);
                  DatabaseService.updateFuelType(fuelType);
                  DatabaseService.updateUsername(username);
                  DatabaseService.updateTokenPlaid(plaidToken);
                  setState(() => isCompleted = true);

                  //DATA TO DATABASE
                } else {
                  setState(() => currentStep += 1);
                }
              },
              onStepCancel: currentStep == 0
                  ? null
                  : () => setState(() => currentStep -= 1),
              controlsBuilder: (context, details) {
                final isLastStep = currentStep == getSteps().length - 1;
                return Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(isLastStep ? 'Speichern' : 'Next'),
                        )),
                        const SizedBox(
                          width: 12,
                        ),
                        if (currentStep != 0)
                          Expanded(
                              child: ElevatedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Zurück'),
                          )),
                      ],
                    ));
              },
            ));

  List<Step> getSteps() => [
        Step(
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 0,
            title: const Text('Account'),
            content: SettingsGroup(title: '', children: <Widget>[
              buildUserName(),
              buildFuelType(),
              buildEngineSize()
            ])),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 1,
            title: const Text('Google'),
            content: Column(
              children: [
                const Text(
                    'Wie kann man seine Daten auf Google Maps herunterladen?'),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          style: headline4,
                          text:
                              "1. Erstmal, mit Google-Konto anmelden.\n\n2. Dann "),
                      TextSpan(
                          style: const TextStyle(color: Colors.blue),
                          text: "Google Takeout",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final Uri url =
                                  Uri.parse('https://takeout.google.com/');
                              launchUrl(url);
                            }),
                      const TextSpan(
                          style: headline4,
                          text:
                              " öffnen.\n\n3. Location History auswählen.\n\n4. Next step klicken.\n\n5. Create export klicken. \n\n6. Der Standortverlauf wird in einer ZIP-Datei gespeichert. Laden Sie die Daten aus der JSON-Datei im Verzeichnis Semantic Location History hoch."),
                    ],
                  ),
                ),
                TextButton(
                  child: const Text('Get Filepath'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    TransportApi.readTransportData();
                  },
                ),
              ],
            )),
        Step(
            isActive: currentStep >= 2,
            title: const Text('Plaid'),
            content: ElevatedButton(
              onPressed: () async {
                String linkToken = await PlaidService().generateLinkToken();

                LinkConfiguration configuration =
                    LinkTokenConfiguration(token: linkToken);
                PlaidLink.open(configuration: configuration);
              },
              child: const Text('Connect Bank Account'),
            )),
      ];

  Widget buildUserName() => TextInputSettingsTile(
        settingKey: keyName,
        title: 'Dein Name',
        titleTextStyle: headline4,
        onChange: ((value) => username = value),
      );

  Widget buildFuelType() => DropDownSettingsTile(
        settingKey: keyFuel,
        title: 'Kraftstoff deines Fahrzeugs',
        titleTextStyle: headline4,
        selected: 1,
        values: const <int, String>{
          1: 'Diesel',
          2: 'Petrol',
          3: 'CNG',
          4: 'Hydrogen',
          5: 'Electric',
        },
        onChange: (value) => fuelType = value,
      );

  Widget buildEngineSize() => DropDownSettingsTile(
        settingKey: keySize,
        title: 'Motorgröße',
        titleTextStyle: headline4,
        selected: 1,
        values: const <int, String>{
          1: 'small',
          2: 'medium',
          3: 'large',
        },
        onChange: (value) => engineSize = value,
      );
}