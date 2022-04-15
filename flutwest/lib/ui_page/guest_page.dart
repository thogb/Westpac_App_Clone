import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/sign_in_page.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({Key? key}) : super(key: key);

  @override
  _GuestPageState createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const BackgroundImage(),
            StandardPadding(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 30.0),
                      _getFakeAppbar(),
                      const SizedBox(height: 30.0),
                      _getWelcomeText(),
                      _getButton("Cardless Cash", () {}),
                      _getButton("Locate us", () {}),
                      const SizedBox(height: 20.0),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.settings, color: Colors.white)),
                    ],
                  ),
                  _getSignInButton()
                ],
              ),
            )
          ],
        ));
  }

  Widget _getFakeAppbar() {
    return Row(children: const [
      Icon(
        Icons.share,
      ),
      Text("Contact us", style: TextStyle(fontSize: 16.0, color: Colors.white))
    ]);
  }

  Widget _getWelcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize),
      child: Text("HOW CAN WE HELP YOU THIS EVENING?",
          style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _getButton(String title, VoidCallback voidCallback) {
    return InkWell(
      onTap: voidCallback,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets / 2),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _getSignInButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) =>
                    const SignInPage()),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets + 40.0),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: BoxDecoration(
            color: Colors.red[700], borderRadius: BorderRadius.circular(5)),
        child: const Center(
            child: Text("Sign in",
                style: TextStyle(color: Colors.white, fontSize: 18.0))),
      ),
    );
  }
}
