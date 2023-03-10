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
  'Benzin',
  'CNG',
  'Wasserstoff',
  'Elektrisch'
];
const List<String> motorSizes = <String>['klein', 'mittel', 'groß'];

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
      body: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: colorGreen)),
          child: isCompleted
              ? const HomePage()
              : Stepper(
                  type: StepperType.horizontal,
                  steps: getSteps(),
                  currentStep: currentStep,
                  onStepTapped: (step) => setState(() => currentStep = step),
                  onStepContinue: () {
                    final isLastStep = currentStep == getSteps().length - 1;

                    if (isLastStep) {
                      setState(() => isCompleted = true);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const HomePage()));
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
                            if (currentStep != 0)
                              Expanded(
                                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: colorGreen,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0))),
                                onPressed: details.onStepCancel,
                                child: const Text(
                                  'Zurück',
                                  style: buttonText,
                                  textAlign: TextAlign.center,
                                ),
                              )),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                                child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: colorGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50.0))),
                              child: Text(
                                isLastStep ? 'Speichern' : 'Weiter',
                                style: buttonText,
                                textAlign: TextAlign.center,
                              ),
                            )),
                          ],
                        ));
                  },
                )));

  List<Step> getSteps() => [
        Step(
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 0,
            title: const Text('Konto'),
            content: SettingsGroup(title: '', children: <Widget>[
              buildUserName(),
              buildFuelType(),
              buildEngineSize()
            ])),
        Step(
            isActive: currentStep >= 1,
            title: const Text('Plaid'),
            content: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0))),
              onPressed: () async {
                String linkToken = await PlaidService().generateLinkToken();
                LinkConfiguration configuration =
                    LinkTokenConfiguration(token: linkToken);
                PlaidLink.open(configuration: configuration);
              },
              child: const Text(
                'Connect Bank Account',
                style: buttonText,
                textAlign: TextAlign.center,
              ),
            )),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 2,
            title: const Text('Google'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wie kann ich meine Daten von Google Maps laden?',
                  style: headline3,
                ),
                const SizedBox(
                  height: 32,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(style: headline4, text: "1. Öffne "),
                      TextSpan(
                          style: websiteText,
                          text: "Google Takeout.",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final Uri url =
                                  Uri.parse('https://takeout.google.com/');
                              launchUrl(url);
                            }),
                      // const TextSpan(
                      //     style: headline4,
                      //     text:
                      //         "\n\n2. Wähle Maps und Maps (Meine Orte) aus.\n\n3. Next step klicken.\n\n5. Create export klicken. \n\n6. Der Standortverlauf wird in einer ZIP-Datei gespeichert. Lade die Daten aus der JSON-Datei im Verzeichnis Semantic Location History hoch."),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '2. Wähle Maps und Maps (Meine Orte) aus.',
                  style: headline4,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '3. Nächsten Schritt auswählen.',
                  style: headline4,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '4. Als ZIP-Datei mit gewünschter Häufigkeit exportieren.',
                  style: headline4,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '5.  Lade die Daten aus dem Verzeichnis Semantic Location History hoch.',
                  style: headline4,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  child: const Text(
                    'Get Filepath',
                    style: websiteText,
                  ),
                  onPressed: () async {
                    TransportApi.readTransportData();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const HomePage()));
                  },
                ),
              ],
            )),
      ];

  Widget buildUserName() => TextInputSettingsTile(
      settingKey: keyName,
      title: 'Dein Name',
      titleTextStyle: headline5,
      //onChange: ((value) => username = value),
      onChange: ((value) => DatabaseService.updateUsername(value)));

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
        //onChange: (value) => fuelType = value,
        onChange: (value) => DatabaseService.updateFuelType(value),
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
        //onChange: (value) => engineSize = value,
        onChange: (value) => DatabaseService.updateEngineSize(value),
      );
}
