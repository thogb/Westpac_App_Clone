import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class BiometricsConfirmPage extends StatelessWidget {
  const BiometricsConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fingerIconSize = 100;
    double lockIconSize = 40;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StandardPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Vars.heightGapBetweenWidgets * 2),
                  Stack(
                    children: [
                      Icon(Icons.fingerprint, size: fingerIconSize),
                      Positioned.fill(
                          left: fingerIconSize - lockIconSize + 6,
                          top: fingerIconSize - lockIconSize - 3,
                          child: SizedBox(
                            child: Material(color: Colors.grey[50]),
                          )),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Stack(
                            children: [
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Icon(
                                  Icons.lock,
                                  size: lockIconSize + 6,
                                  color: Colors.grey[50],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.lock,
                                  size: lockIconSize,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Vars.heightGapBetweenWidgets),
                  CustHeading.big(
                    showHorPadding: true,
                    heading: "Sign in faster next time with biometrics",
                    textStyle:
                        CustHeading.bigHeadingStyle.copyWith(fontSize: 26),
                  )
                ],
              ),
            ),
            Column(
              children: [
                CustFloatingButton.enabled(
                    title: "Turn on",
                    onPressed: () async {
                      bool turnOn = false;

                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Vars.standardPaddingSize),
                              title: const Text("Keep you secure"),
                              content: const Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ut lectus id purus varius accumsan a at augue.\n\n Phasellus sed elit velit. Duis tristique condimentum tempor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum eget augue vel turpis gravida elementum et nec turpis. Nunc eget."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("cancel")),
                                TextButton(
                                    onPressed: () {
                                      turnOn = true;
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Continue"))
                              ],
                            );
                          });

                      if (turnOn) {
                        Navigator.pop(context, turnOn);
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.all(Vars.standardPaddingSize * 1.5),
                  child: Center(
                    child: ClickableText.medium(
                        text: "More ways to sign in",
                        onTap: () {
                          Navigator.pop(context, false);
                        }),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
