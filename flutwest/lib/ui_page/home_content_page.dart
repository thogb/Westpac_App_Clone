import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/navbar_state.dart';
import 'package:flutwest/model/vars.dart';

import 'account_detail_page.dart';

class HomeContentPage extends StatefulWidget {
  final NavbarState navbarState;

  const HomeContentPage({Key? key, required this.navbarState})
      : super(key: key);

  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration topFadeDuration = Duration(milliseconds: 300);

  static const Duration welcomeFadeDuration = Duration(milliseconds: 500);

  static final Widget dollarIcon = Container(
    padding: const EdgeInsets.all(15.0),
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red[800]),
    child: const Center(
        child: Icon(Icons.attach_money, color: Colors.white, size: 50)),
  );

  static const TextStyle fakeAppBarStyle =
      TextStyle(color: Colors.white, fontSize: 16.0);

  /// controller for bottom part sliding in animation
  late final AnimationController _botAnimationController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..forward().then((value) => {
        _topAnimationController.forward().then((value) {
          _welcomeController.forward();
          _welcomeFadeController.forward();
        })
      });

  /// animation for bottom to slide in
  late final Animation<Offset> _botOffSetAnimation =
      Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _botAnimationController, curve: Curves.easeInExpo));

  /// controller for the top part's fading in animation
  late final AnimationController _topAnimationController =
      AnimationController(duration: topFadeDuration, vsync: this);

  /// the top part of the page animation fading in
  late final Animation<double> _topFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _topAnimationController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeIn)));

  /// welcome text animation controller for fading in
  late final AnimationController _welcomeFadeController =
      AnimationController(duration: welcomeFadeDuration, vsync: this);

  /// welcome text animation fading in
  late final Animation<double> _welcomeFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _welcomeFadeController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInExpo)));

  late final AnimationController _paymentContentFadeController =
      AnimationController(
          duration: const Duration(microseconds: 0), vsync: this)
        ..forward().then((value) {
          _paymentContentFadeController.duration =
              const Duration(milliseconds: 200);
        });

  late final Animation<double> _paymentContentFadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _paymentContentFadeController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeIn)));

  /// the controller for welcome text animation sliding in
  late final AnimationController _welcomeController;

  /// welcome text animation sliding in
  late final Animation<Offset> _welcomeAnimation;

  final Map<String, bool> _accountRedBorderState = {};
  final Map<String, AnimationController> _accountAnimationControllers = {};
  final Map<String, Animation<double>> _accountAnimations = {};

  final ScrollController _scrollController = ScrollController();

  static List<Account> accounts = [
    Account(Account.typeChocie, "666-777", "232383", 2000.0),
    Account(Account.typeeSaver, "888-999", "223323", 6000.0),
    Account(Account.typeBusiness, "111-222", "231231", 100000.0)
  ];

  bool _dragging = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    widget.navbarState.addObserver(_checkWelcomeAnimation);

    _welcomeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _welcomeAnimation =
        Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn));

    for (Account account in accounts) {
      AnimationController controller = AnimationController(
          duration: const Duration(milliseconds: 300), vsync: this);

      Animation<double> animation = Tween<double>(begin: 1.0, end: 1.02)
          .animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      _accountAnimations[account.bsb] = animation;
      _accountAnimationControllers[account.bsb] = controller;
      _accountRedBorderState[account.bsb] = false;
    }

    super.initState();

    /*
    Future.delayed(const Duration(milliseconds: 1000), () {
      _topAnimationController.forward();
    });*/

    /*
    Future.delayed(const Duration(milliseconds: 1500), () {
      _welcomeController.forward();
      Future.delayed(const Duration(milliseconds: 800), () {
        _welcomeFadeController.forward();
      });
    });*/
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
            controller: _scrollController,
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

  /// check if home content page is opened from another page
  /// if it is then run text welcome fading aniamtion.
  void _checkWelcomeAnimation(int prevIndex, int currIndex) {
    if (currIndex == 0 && prevIndex != 0) {
      _runWelcomeFadeAnimation(300);
    }
  }

  /// set a delay when to run welcome text fading animation before run
  void _runWelcomeFadeAnimation(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      _welcomeFadeController.reset();
      _welcomeFadeController.forward();
    });
  }

  /// returns the fake app bar of this page that looks like app bar
  Widget _getFakeAppBar() {
    return Row(
      children: [
        const WestLogo(width: 50),
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
            _getPaymentsContent(),
            const SizedBox(height: 200.0)
          ],
        ),
      ),
    );
  }

  Widget _getPaymentsContent() {
    // column there might be more stuff under payments button
    return FadeTransition(
      opacity: _paymentContentFadeAnimation,
      child: Column(
        children: [
          CustButton(
            leftWidget: const Icon(Icons.money),
            heading: "Payments",
            paragraph: "Upcoming, past, direct debits, BPAY View",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _getAccountSection() {
    return Container(
        padding: OutlinedContainer.defaultPadding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0),
            border: !_dragging
                ? Border.all(width: 0.5, color: Colors.black12)
                : Border.all(width: 0.0, color: Colors.transparent)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          !_dragging
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Accounts", style: Vars.headingStyle2),
                    GestureDetector(
                      onTap: () {
                        widget.navbarState.changeToPage(3);
                      },
                      child: Text(
                        "New account",
                        style:
                            TextStyle(color: Colors.red[600], fontSize: 12.0),
                      ),
                    )
                  ],
                )
              : const SizedBox(
                  height: 40.0,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Drag & drop to transfer",
                        style: TextStyle(fontSize: 16.0),
                      ))),
          const SizedBox(height: 30.0),
          const Text("Cash", style: TextStyle(fontSize: 14.0)),
          const SizedBox(height: 3.0),
          Container(height: 0.25, color: Colors.black45),
          const SizedBox(height: 4.0),
          Column(
              children: List.generate(accounts.length, (index) {
            return _getAccountDrag(accounts[index]);
          })),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: Vars.topBotPaddingSize - 4.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.settings, color: Colors.red[700]),
                ),
              )),
        ]));
  }

  Widget _getAccountDrag(Account account) {
    return DragTarget<Account>(
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return LongPressDraggable(
          data: account,
          child: _getAccountButton(account, false),
          feedback: dollarIcon,
          childWhenDragging: _getAccountButton(account, true),
          onDragStarted: () {
            _welcomeFadeController.duration = topFadeDuration;
            _welcomeFadeController.reverse();
            _topAnimationController.reverse();
            _paymentContentFadeController.reverse();

            _scrollController.jumpTo(_scrollController.offset + 40.0);

            _accountAnimationControllers[account.bsb]!.forward();
            if (_scrollController.offset > 160.0) {
              _scrollController.jumpTo(150.0);
            }

            widget.navbarState.hide();

            setState(() {
              _dragging = true;
            });
          },
          onDragEnd: (DraggableDetails details) {
            _welcomeFadeController.forward();
            _topAnimationController.forward();
            _paymentContentFadeController.forward();
            _welcomeController.duration = topFadeDuration;

            _scrollController.jumpTo(_scrollController.offset - 40.0);
            /*if (_overScrolled) {
                _scrollController.jumpTo(_scrollController.offset - 30.0);
              }*/
            _accountAnimationControllers[account.bsb]!.reverse();

            widget.navbarState.show();

            setState(() {
              _dragging = false;
            });
          },
        );
      },
      onWillAccept: (Account? inAccount) {
        if (account.bsb != inAccount!.bsb) {
          setState(() {
            _accountRedBorderState[account.bsb] = true;
            _accountAnimationControllers[account.bsb]!.forward();
          });
        }
        return true;
      },
      onLeave: (Account? inAccount) {
        if (account.bsb != inAccount!.bsb) {
          setState(() {
            _accountRedBorderState[account.bsb] = false;
            _accountAnimationControllers[account.bsb]!.reverse();
          });
        }
      },
      onAccept: (Account inAccount) {
        //TODO: open transaction page
        if (account.bsb != inAccount.bsb) {
          setState(() {
            _accountRedBorderState[account.bsb] = false;
            _accountAnimationControllers[account.bsb]!.reverse();
          });
        }
      },
    );
  }

  Widget _getAccountButton(Account account, bool inDrag) {
    return ScaleTransition(
      scale: _accountAnimations[account.bsb]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 3,
                  offset: const Offset(0, 3))
            ],
            border: inDrag
                ? Border.all(width: 2.0, color: Colors.black)
                : !_accountRedBorderState[account.bsb]!
                    ? Border.all(width: 0.5, color: Colors.black12)
                    : Border.all(width: 2.0, color: Colors.red)),
        child: Material(
          borderRadius: BorderRadius.circular(4.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AccountDetailPage(accounts: accounts, currIndex: 0)));
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    Vars.standardPaddingSize,
                    Vars.topBotPaddingSize,
                    Vars.standardPaddingSize,
                    Vars.topBotPaddingSize * 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Westpac ${account.type}",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text("\$${account.balance}",
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold))
                  ],
                )),
          ),
        ),
      ),
    );
  }

  /*
  Widget _getAccountButton(Account account, bool inDrag) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AccountDetailPage(accounts: accounts, currIndex: 0)));
      },
      child: ScaleTransition(
        scale: _accountAnimations[account.bsb]!,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.fromLTRB(
                Vars.standardPaddingSize,
                Vars.topBotPaddingSize,
                Vars.standardPaddingSize,
                Vars.topBotPaddingSize * 2.5),
            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 3,
                      offset: const Offset(0, 3))
                ],
                border: inDrag
                    ? Border.all(width: 2.0, color: Colors.black)
                    : !_accountRedBorderState[account.bsb]!
                        ? Border.all(width: 0.5, color: Colors.black12)
                        : Border.all(width: 2.0, color: Colors.red)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Westpac ${account.type}",
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text("\$${account.balance}",
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold))
              ],
            )),
      ),
    );
  }*/
}
