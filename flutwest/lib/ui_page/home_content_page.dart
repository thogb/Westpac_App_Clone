import 'package:decimal/decimal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/account_button.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/account_id.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/navbar_state.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/account_ordering_page.dart';
import 'package:flutwest/ui_page/hidden_accounts_page.dart';
import 'package:flutwest/ui_page/home_search_page.dart';
import 'package:flutwest/ui_page/transfer_page.dart';

import 'account_detail_page.dart';

class HomeContentPage extends StatefulWidget {
  final NavbarState navbarState;
  final Member member;
  final List<AccountOrderInfo> accountOrderInfos;
  final List<Account> rawAccounts;

  const HomeContentPage(
      {Key? key,
      required this.navbarState,
      required this.member,
      required this.accountOrderInfos,
      required this.rawAccounts})
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

  late final Animation<Color?> _colorAnimation =
      ColorTween(begin: Colors.transparent, end: Colors.grey[50]).animate(
          CurvedAnimation(parent: _colorController, curve: Curves.easeOut));

  late final AnimationController _colorController =
      AnimationController(vsync: this, duration: const Duration(seconds: 0));

  /// the controller for welcome text animation sliding in
  late final AnimationController _welcomeController;

  /// welcome text animation sliding in
  late final Animation<Offset> _welcomeAnimation;

  // final Map<String, bool> _accountRedBorderState = {};
  // final Map<String, AnimationController> _accountAnimationControllers = {};
  // final Map<String, Animation<double>> _accountAnimations = {};

  final ScrollController _scrollController = ScrollController();

  /*static List<Account> accounts = [
    Account(
        type: Account.typeChocie,
        bsb: "666-777",
        number: "232383",
        balance: 2000.0,
        cardNumber: "213123123123123123"),
    Account(
        type: Account.typeeSaver,
        bsb: "888-999",
        number: "223323",
        balance: 6000.0,
        cardNumber: ""),
    Account(
        type: Account.typeBusiness,
        bsb: "111-222",
        number: "231231",
        balance: 100000.0,
        cardNumber: "")
  ];*/

  late List<Account> accounts;

  late final List<AccountOrderInfo> _accountOrderInfos;
  late final List<AccountOrderInfo> _hiddenAccountOrderInfos = [];

  bool _dragging = false;

  late double _topSectionHeight;
  late bool _pinnedSearch = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    widget.navbarState.addObserver(_checkWelcomeAnimation);

    _accountOrderInfos = widget.accountOrderInfos;

    _updateNOfHiddenAccount();

    _welcomeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _welcomeAnimation =
        Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero).animate(
            CurvedAnimation(parent: _welcomeController, curve: Curves.easeIn));

    accounts = widget.member.accounts;

    FirestoreController.instance.colAccount
        .addOnBalanceChangeObserver(_onBalanceChange);
    _scrollController.addListener(_onScroll);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    _topAnimationController.dispose();
    _welcomeFadeController.dispose();
    _paymentContentFadeController.dispose();
    _welcomeController.dispose();
    _botAnimationController.dispose();
    _colorController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    FirestoreController.instance.colAccount
        .removeOnBalanceChangeObserver(_onBalanceChange);

    super.dispose();
  }

  void _onBalanceChange(String docId, Decimal balance) {
    for (Account account in widget.rawAccounts) {
      if (account.docID == docId) {
        account.setBalance = balance;
        break;
      }
    }

    _recreateAccountDrags();
  }

  void _onScroll() {
    _colorController.animateTo(_scrollController.offset / _topSectionHeight);

    if (_scrollController.offset >= _topSectionHeight) {
      if (!_pinnedSearch) {
        setState(() {
          _pinnedSearch = true;
        });
      }
    } else {
      if (_pinnedSearch) {
        setState(() {
          _pinnedSearch = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _accountOrderInfos.length = _accountOrderInfos.length;
      });
      _runWelcomeFadeAnimation(300);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    _topSectionHeight = MediaQuery.of(context).size.height * 0.25;
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          AnimatedBuilder(
              animation: _colorController,
              builder: (context, child) => Container(
                  color: _dragging ? Colors.grey[50] : _colorAnimation.value)),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                SizedBox(
                  height: _topSectionHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StandardPadding(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: kToolbarHeight - 10),
                            FadeTransition(
                              opacity: _topFadeAnimation,
                              child: _getFakeAppBar(),
                            ),
                          ],
                        ),
                      ),
                      StandardPadding(
                        child: SlideTransition(
                            position: _welcomeAnimation,
                            child: FadeTransition(
                                opacity: _welcomeFadeAnimation,
                                child: _getWelcomeText())),
                      ),
                    ],
                  ),
                )
              ])),
              SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: HeaderDelegate(
                      height: _pinnedSearch ? 100 : 80,
                      child: Material(
                        animationDuration: Duration.zero,
                        elevation: _pinnedSearch ? 2.0 : 0.0,
                        color: _pinnedSearch
                            ? Colors.grey[50]
                            : Colors.transparent,
                        child: SizedBox(
                          height: _pinnedSearch ? 100 : 80,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: StandardPadding(
                              child: FadeTransition(
                                  opacity: _topFadeAnimation,
                                  child: _getSearchBar()),
                            ),
                          ),
                        ),
                      ))),
              SliverList(
                  delegate: SliverChildListDelegate([
                SlideTransition(
                  position: _botOffSetAnimation,
                  child: _getBottomContent(),
                )
              ]))
            ],
          )
        ],
      ),
    );
  }

  void _recreateAccountDrags() {
    setState(() {
      _accountOrderInfos.length;
    });
  }

  void _updateNOfHiddenAccount() {
    _hiddenAccountOrderInfos.clear();
    for (AccountOrderInfo accountOrderInfo in _accountOrderInfos) {
      if (accountOrderInfo.isHidden) {
        _hiddenAccountOrderInfos.add(accountOrderInfo);
      }
    }
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
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
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
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(3.0)),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Try 'Pay Alice'",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0))),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => HomeSearchPage(
                          member: widget.member,
                          rawAccounts: widget.rawAccounts,
                        ))));
          },
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
          _getNetPosition(),
          const SizedBox(height: Vars.heightGapBetweenWidgets),
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

  Widget _getNetPosition() {
    Decimal total = Decimal.zero;

    for (Account account in accounts) {
      total = total + account.balance;
    }
    return OutlinedContainer(
        child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Net position", style: Vars.headingStyle2),
        GestureDetector(
          child: const Icon(Icons.info_outline,
              size: Vars.headingTextSize2, color: Vars.clickAbleColor),
          onTap: () {},
        ),
      ]),
      const SizedBox(height: Vars.heightGapBetweenWidgets / 2),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Credit", style: Vars.paragraphStyleGrey),
        Text("\$${Utils.formatDecimalMoneyUS(total)}",
            style: Vars.paragraphStyleGrey)
      ]),
      const SizedBox(height: Vars.gapBetweenTextVertical),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Debit", style: Vars.paragraphStyleGrey),
        Text("\$${Utils.formatDecimalMoneyUS(Decimal.zero)}",
            style: Vars.paragraphStyleGrey)
      ]),
      const SizedBox(height: Vars.gapBetweenTextVertical),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text(
          "Total",
          style: TextStyle(fontSize: Vars.headingTextSize3),
        ),
        const SizedBox(height: Vars.gapBetweenTextVertical),
        Text("\$${Utils.formatDecimalMoneyUS(total)}",
            style: Vars.headingStyle3)
      ]),
    ]));
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
          _hiddenAccountOrderInfos.length == _accountOrderInfos.length
              ? const Padding(
                  padding: EdgeInsets.only(top: Vars.topBotPaddingSize),
                  child: Text(
                      "No accounts to see here. Looks like you've hidden all your accounts",
                      style: TextStyle(fontSize: 18.0)),
                )
              : Column(
                  children: List.generate(_accountOrderInfos.length, (index) {
                  print(
                      "${_accountOrderInfos[index].account.hashCode} recreating and ${_accountOrderInfos[index].account.type}  ${_accountOrderInfos[index].account.balance}                             ${DateTime.now().toString()}");
                  return !_accountOrderInfos[index].isHidden
                      ? _getAccountDrag(_accountOrderInfos[index])
                      : const SizedBox();
                })),
          Padding(
            padding: const EdgeInsets.only(top: Vars.topBotPaddingSize - 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hiddenAccountOrderInfos.isNotEmpty
                    ? ClickableText(
                        text: _hiddenAccountOrderInfos.length > 1
                            ? "${_hiddenAccountOrderInfos.length} hidden accounts"
                            : "${_hiddenAccountOrderInfos.length} hidden account",
                        onTap: () async {
                          await Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: ((context, animation,
                                          secondaryAnimation) =>
                                      HiddenAccountsPage(
                                          hiddenAccountOrderInfos:
                                              _hiddenAccountOrderInfos,
                                          accountOrderInfos: _accountOrderInfos,
                                          accounts: accounts,
                                          memberId: widget.member.id,
                                          recentPayeeDate: widget
                                              .member.recentPayeeChange))));
                          _updateNOfHiddenAccount();
                          _recreateAccountDrags();
                        })
                    : const SizedBox(),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => AccountOrderingPage(
                                  memberId: widget.member.id,
                                  accountOrderInfos: _accountOrderInfos,
                                ))));
                    _updateNOfHiddenAccount();
                    _recreateAccountDrags();
                  },
                  child: Icon(Icons.settings,
                      color: _dragging ? Colors.transparent : Colors.red[700]),
                )
              ],
            ),
          )
        ]));
  }

  Widget _getAccountDrag(AccountOrderInfo accountOrderInfo) {
    if (accountOrderInfo.isHidden) {
      return const SizedBox();
    }

    return DraggableAccountButton(
      rawAccounts: widget.rawAccounts,
      account: accountOrderInfo.getAccount(),
      feedback: dollarIcon,
      onDragStart: () {
        _welcomeFadeController.duration = topFadeDuration;
        _welcomeFadeController.reverse();
        _topAnimationController.reverse();
        _paymentContentFadeController.reverse();

        _scrollController.jumpTo(_scrollController.offset + 40.0);

        if (_scrollController.offset > _topSectionHeight * 0.75) {
          _scrollController.jumpTo((_topSectionHeight * 0.75) - 10);
        }

        widget.navbarState.hide();

        setState(() {
          _dragging = true;
        });
      },
      onDragEnd: (details) {
        _welcomeFadeController.forward();
        _topAnimationController.forward();
        _paymentContentFadeController.forward();
        _welcomeController.duration = topFadeDuration;

        _scrollController.jumpTo(_scrollController.offset - 40.0);
        widget.navbarState.show();

        setState(() {
          _dragging = false;
        });
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AccountDetailPage(
                    rawAccounts: widget.rawAccounts,
                    memberId: widget.member.id,
                    recentPayeeDate: widget.member.recentPayeeChange,
                    accounts: _accountOrderInfos,
                    currIndex: _accountOrderInfos.indexOf(accountOrderInfo))));
      },
    );
  }
}

class DraggableAccountButton extends StatefulWidget {
  final Account account;
  final List<Account> rawAccounts;
  final VoidCallback? onTap;
  final Widget feedback;
  final VoidCallback? onDragStart;
  final void Function(DraggableDetails)? onDragEnd;

  const DraggableAccountButton(
      {Key? key,
      required this.rawAccounts,
      this.onDragStart,
      this.onDragEnd,
      required this.account,
      this.onTap,
      required this.feedback})
      : super(key: key);

  @override
  _DraggableAccountButtonState createState() => _DraggableAccountButtonState();
}

class _DraggableAccountButtonState extends State<DraggableAccountButton>
    with SingleTickerProviderStateMixin {
  bool _inDrag = false;
  bool _onBeingDragFocused = false;
  late final AnimationController _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);

  late final Animation<double> _scaleAnimation = Tween<double>(
          begin: 1.0, end: 1.02)
      .animate(CurvedAnimation(parent: _scaleController, curve: Curves.linear));

  @override
  Widget build(BuildContext context) {
    return DragTarget<Account>(
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return LongPressDraggable(
          data: widget.account,
          child: _getAccountButton(),
          feedback: widget.feedback,
          childWhenDragging: _getAccountButton(),
          onDragStarted: () {
            if (widget.onDragStart != null) {
              widget.onDragStart!();
            }

            _scaleController.forward();
            setState(() {
              _inDrag = true;
            });
          },
          onDragEnd: (DraggableDetails details) {
            if (widget.onDragEnd != null) {
              widget.onDragEnd!(details);
            }

            _scaleController.reverse();
            setState(() {
              _inDrag = false;
            });
          },
        );
      },
      onWillAccept: (Account? inAccount) {
        if (widget.account.getNumber != inAccount!.getNumber) {
          setState(() {
            _onBeingDragFocused = true;
            _scaleController.forward();
          });
        }
        return true;
      },
      onLeave: (Account? inAccount) {
        if (widget.account.getNumber != inAccount!.getNumber) {
          setState(() {
            _onBeingDragFocused = false;
            _scaleController.reverse();
          });
        }
      },
      onAccept: (Account inAccount) {
        if (widget.account.getNumber != inAccount.getNumber) {
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: ((context, animation, secondaryAnimation) =>
                      TransferPage(
                          accounts: widget.rawAccounts,
                          currAccount: inAccount,
                          toAccount: widget.account))));
          setState(() {
            _onBeingDragFocused = false;
            _scaleController.reverse();
          });
        }
      },
    );
  }

  Widget _getAccountButton() {
    return ScaleTransition(
        scale: _scaleAnimation,
        child: AccountButton(
            leftTitle: "Westpac ${widget.account.type}",
            rightTitle:
                "\$${Utils.formatDecimalMoneyUS(widget.account.balance)}",
            ontap: widget.onTap,
            border: _inDrag
                ? Border.all(width: 2.0, color: Colors.black)
                : !_onBeingDragFocused
                    ? Border.all(width: 0.5, color: Colors.black12)
                    : Border.all(width: 2.0, color: Colors.red)));
  }
}

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  HeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
