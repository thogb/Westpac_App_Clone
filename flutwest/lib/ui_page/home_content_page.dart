import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/navbar_state.dart';
import 'package:flutwest/model/vars.dart';

class HomeContentPage extends StatefulWidget {
  final NavbarState navbarState;

  const HomeContentPage({Key? key, required this.navbarState})
      : super(key: key);

  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const TextStyle fakeAppBarStyle =
      TextStyle(color: Colors.white, fontSize: 16.0);

  late final AnimationController _botAnimationController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..forward();

  late final AnimationController _topAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this)
    ..forward();

  late final AnimationController _welcomeFadeController = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this);

  late final Animation<double> _welcomeFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _welcomeFadeController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInExpo)));

  late final AnimationController _welcomeController;

  late final Animation<Offset> _botOffSetAnimation =
      Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _botAnimationController, curve: Curves.easeInExpo));

  late final Animation<double> _topFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _topAnimationController,
          curve: const Interval(1000 / 1200, 1.0, curve: Curves.easeIn)));

  late final Animation<Offset> _welcomeAnimation;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    widget.navbarState.addObserver(_checkWelcomeAnimation);

    _welcomeController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    _welcomeAnimation =
        Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn));

    super.initState();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _welcomeController.forward();
      Future.delayed(const Duration(milliseconds: 800), () {
        _welcomeFadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runWelcomeFadeAnimation(300);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const BackgroundImage(),
          SingleChildScrollView(
            child: Column(
              children: [
                StandardPadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50.0),
                      FadeTransition(
                        opacity: _topFadeAnimation,
                        child: _getFakeAppBar(),
                      ),
                      const SizedBox(height: 120.0),
                      SlideTransition(
                          position: _welcomeAnimation,
                          child: FadeTransition(
                              opacity: _welcomeFadeAnimation,
                              child: _getWelcomeText())),
                      FadeTransition(
                          opacity: _topFadeAnimation, child: _getSearchBar())
                    ],
                  ),
                ),
                SlideTransition(
                  position: _botOffSetAnimation,
                  child: _getBottomContent(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkWelcomeAnimation(int prevIndex, int currIndex) {
    if (currIndex == 0 && prevIndex != 0) {
      _runWelcomeFadeAnimation(300);
    }
  }

  void _runWelcomeFadeAnimation(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      _welcomeFadeController.reset();
      _welcomeFadeController.forward();
    });
  }

  Widget _getFakeAppBar() {
    return Row(
      children: [
        const Icon(Icons.share),
        const SizedBox(width: 10.0),
        Expanded(
          child: GestureDetector(
            child: const Text("Contact us", style: fakeAppBarStyle),
          ),
        ),
        GestureDetector(
          child: const Text(
            "Sign out",
            style: fakeAppBarStyle,
          ),
        )
      ],
    );
  }

  Widget _getWelcomeText() {
    return const Text(
      "HOW CAN WE HELP YOU THIS EVENING?",
      style: TextStyle(
          color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _getSearchBar() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[50], borderRadius: BorderRadius.circular(3.0)),
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Icon(Icons.search),
                hintText: "Try 'Pay Alice'",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0))),
            onTap: () {},
          ),
        ));
  }

  Widget _getBottomContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      child: StandardPadding(
        child: Column(
          children: [
            const SizedBox(height: Vars.topBotPaddingSize),
            _getAccountSection(),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            CustButton(
              leftWidget: const Icon(Icons.money),
              heading: "Payments",
              paragraph: "Upcoming, past, direct debits, BPAY View",
              onTap: () {
                print("start----");
                print("end -------");
              },
            ),
            const SizedBox(height: 200.0)
          ],
        ),
      ),
    );
  }

  Widget _getAccountSection() {
    return OutlinedContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Accounts", style: Vars.headingStyle2),
          GestureDetector(
            onTap: () {},
            child: Text(
              "New account",
              style: TextStyle(color: Colors.red[600], fontSize: 12.0),
            ),
          )
        ],
      ),
      const SizedBox(height: 30.0),
      const Text("Cash", style: TextStyle(fontSize: 14.0)),
      const SizedBox(height: 3.0),
      Container(height: 0.25, color: Colors.black45),
      Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(top: Vars.topBotPaddingSize),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.settings, color: Colors.red[700]),
            ),
          )),
    ]));
  }
}
