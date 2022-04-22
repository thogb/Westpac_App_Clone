import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/sign_in_page.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({Key? key}) : super(key: key);

  @override
  _GuestPageState createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> with TickerProviderStateMixin {
  static const int buttonSizeDuration = 300;
  //static const int buttonSlidedDuration = 1;
  static const int welcomeFadeDuration = 200;
  static const int welcomeSlideDuration = 500;

  late final AnimationController _buttonSizeController = AnimationController(
      duration: const Duration(milliseconds: buttonSizeDuration), vsync: this)
    ..forward().then((value) {
      _welcomeFadeController.forward().then((value) {
        _welcomeSlideController.forward();
      });
    });
  late final Animation<double> _buttonSizeAnimation =
      CurvedAnimation(parent: _buttonSizeController, curve: Curves.linear);

  /*
  late final AnimationController _buttonSlideController = AnimationController(
      duration: const Duration(milliseconds: buttonSlidedDuration),
      vsync: this);
  late final Animation<Offset> _buttonSlideAnimation =
      Tween<Offset>(begin: const Offset(0.0, -0.0), end: const Offset(0.0, 0.0))
          .animate(CurvedAnimation(
              parent: _buttonSlideController, curve: Curves.linear));*/

  late final AnimationController _welcomeFadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: welcomeFadeDuration));
  late final Animation<double> _welcomeFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _welcomeFadeController, curve: Curves.linear));

  late final AnimationController _welcomeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: welcomeSlideDuration));
  late final Animation<Offset> _weclomeSlideAnimation =
      Tween<Offset>(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
          .animate(CurvedAnimation(
              parent: _welcomeSlideController, curve: Curves.linear));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            highlightColor: const Color.fromARGB(80, 243, 123, 123),
          ),
          child: Stack(
            children: [
              const BackgroundImage(),
              StandardPadding(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 50.0),
                        _getFakeAppbar(),
                        const SizedBox(height: 30.0),
                        SizeTransition(
                            sizeFactor: _welcomeFadeAnimation,
                            axis: Axis.vertical,
                            axisAlignment: -1.0,
                            child: SlideTransition(
                                position: _weclomeSlideAnimation,
                                child: _getWelcomeText())),
                        Column(
                          children: [
                            SizeTransition(
                              sizeFactor: _buttonSizeAnimation,
                              axis: Axis.vertical,
                              axisAlignment: -1.0,
                              child: Column(
                                children: [
                                  _getButton("Cardless Cash", _openSignInPage),
                                  _getButton("Locate us", () {}),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                    onTap: _openSignInPage,
                                    child: const Icon(Icons.settings,
                                        color: Colors.white)))
                          ],
                        ),
                      ],
                    ),
                    _getSignInButton()
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _getFakeAppbar() {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const WestLogo(width: 50.0),
      const SizedBox(width: Vars.standardPaddingSize),
      GestureDetector(
          onTap: _openSignInPage,
          child: const Text("Contact us",
              style: TextStyle(fontSize: 16.0, color: Colors.white)))
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
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets / 2),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.0),
        child: InkWell(
          onTap: voidCallback,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Vars.topBotPaddingSize,
                horizontal: Vars.standardPaddingSize),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _getSignInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets + 40.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Material(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(3.0),
        child: InkWell(
          onTap: _openSignInPage,
          child: const Padding(
            padding: EdgeInsets.symmetric(
                vertical: Vars.topBotPaddingSize,
                horizontal: Vars.standardPaddingSize),
            child: Center(
                child: Text("Sign in",
                    style: TextStyle(color: Colors.white, fontSize: 18.0))),
          ),
        ),
      ),
    );
  }

  void _openSignInPage() {
    Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: ((context, animation, secondaryAnimation) =>
                    const SignInPage()),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero))
        .then((value) {
      _buttonSizeController.reset();
      _welcomeFadeController.reset();
      _welcomeSlideController.reset();

      _buttonSizeController.forward().then((value) {
        _welcomeFadeController.forward().then((value) {
          _welcomeSlideController.forward();
        });
      });
    });
  }
}
