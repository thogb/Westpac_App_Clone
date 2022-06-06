import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/navbar_state.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/ui_page/cards_page.dart';
import 'package:flutwest/ui_page/choose_payee_page.dart';
import 'package:flutwest/ui_page/home_content_page.dart';
import 'package:flutwest/ui_page/products_page.dart';
import 'package:flutwest/ui_page/profile_page.dart';
import 'package:flutwest/ui_page/transfer_from_page.dart';

class HomePage extends StatefulWidget {
  final Member member;
  final List<AccountOrderInfo> accountOrderInfos;
  final List<Account> accounts;

  const HomePage(
      {Key? key,
      required this.member,
      required this.accounts,
      required this.accountOrderInfos})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const Color unselectedNavItemColor = Colors.black54;
  static const Color selectedNavItemColor = Colors.black;
  static const double navItemIconSize = 25.0;

  late NavbarState navbarState;

  bool _showNavBar = true;
  bool _more = false;
  int _currPage = 0;

  final List<Widget> _pages = List.filled(5, const SizedBox());

  late final Future<List<Object>> futures;

  late Member _member;
  List<Account> _accounts = [];

  late final List<AccountOrderInfo> _accountOrderInfos;

  @override
  void initState() {
    Utils.showSysNavBarColour();
    navbarState = NavbarState(
        showNavBar: showNavBar,
        hideNavBar: hideNavBar,
        changeToPage: _onNavbarTap);

    _accountOrderInfos = widget.accountOrderInfos;
    _accounts = widget.accounts;
    _member = widget.member;
    _pages[0] = (HomeContentPage(
      rawAccounts: _accounts,
      navbarState: navbarState,
      member: _member,
      accountOrderInfos: _accountOrderInfos,
    ));

    super.initState();
  }

  @override
  void dispose() {
    Utils.hideSysNavBarColour();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      FirebaseAuth.instance.signOut();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await _onBackPress();
          return false;
        },
        child: _getHomePage());
  }

  Future<void> _onBackPress() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context, true);
  }

  /*Widget _getErrorPage(String errorMsg) {
    return Scaffold(
      body: Stack(children: [
        const BackgroundImage(),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Text(
              errorMsg,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ]),
    );
  }*/

  Widget _getHomePage() {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(highlightColor: Colors.grey[100]),
        child: Stack(
          children: [
            IndexedStack(children: _pages, index: _currPage),
          ],
        ),
      ),
      bottomNavigationBar: !_showNavBar
          ? const SizedBox()
          : BottomNavigationBar(
              backgroundColor: Colors.white,
              onTap: _onNavbarTap,
              currentIndex: _currPage,
              unselectedItemColor: unselectedNavItemColor,
              selectedItemColor: selectedNavItemColor,
              selectedFontSize: 0.0,
              unselectedFontSize: 0.0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                    tooltip: "Home",
                    label: "",
                    icon: _getNavIcon(Icons.home_outlined, "Home"),
                    activeIcon: _getNavIcon(Icons.home_sharp, "Home", true)),
                BottomNavigationBarItem(
                    tooltip: "Cards",
                    label: "",
                    icon: _getNavIcon(CupertinoIcons.creditcard, "Cards"),
                    activeIcon:
                        _getNavIcon(Icons.credit_card_sharp, "Cards", true)),
                BottomNavigationBarItem(
                    icon: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red[700]),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                      ),
                    ),
                    label: ""),
                BottomNavigationBarItem(
                    tooltip: "Products",
                    label: "",
                    icon: _getNavIcon(CupertinoIcons.cube, "Products"),
                    activeIcon: _getNavIcon(
                        CupertinoIcons.cube_fill, "Products", true)),
                BottomNavigationBarItem(
                    tooltip: "Profile",
                    label: "",
                    icon: _getNavIcon(Icons.person_outline, "Profile"),
                    activeIcon:
                        _getNavIcon(Icons.person_sharp, "Profile", true)),
              ],
            ),
    );
  }

  void showNavBar() {
    setState(() {
      _showNavBar = true;
    });
  }

  void hideNavBar() {
    setState(() {
      _showNavBar = false;
    });
  }

  Widget _getNavIcon(IconData iconData, String label, [bool active = false]) {
    return Column(
      children: [
        Icon(
          iconData,
          size: navItemIconSize,
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 12.0,
              color: active ? selectedNavItemColor : unselectedNavItemColor),
        )
      ],
    );
  }

  void _onNavbarTap(int index) {
    if (index == 2) {
      _showBottomSheet();
    } else if (index == 1) {
      if (_member.cardNumber != null && _member.cardNumber!.isNotEmpty) {
        if (_pages[1] is! CardsPage) {
          Account cardAccount = _accounts[0];

          for (Account account in _accounts) {
            if (account.cardNumber == _member.cardNumber) {
              cardAccount = account;
              break;
            }
          }
          _pages[1] = CardsPage(
              memberId: _member.id,
              recentPayeeDate: _member.recentPayeeChange,
              rawAccounts: _accounts,
              cardNumber: _member.cardNumber!,
              cardAccount: cardAccount,
              accountOrderInfos: _accountOrderInfos);
        }
        setState(() {
          _currPage = index;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You do not have a card yet")));
      }
    } else {
      if (index == 3) {
        if (_pages[3] is! ProductsPage) {
          _pages[3] = const ProductsPage();
        }
      } else if (index == 4) {
        if (_pages[4] is! ProfilePage) {
          _pages[4] = const ProfilePage();
        }
      }
      setState(() {
        _currPage = index;
      });
    }

    navbarState.updatePageIndex(index);
    navbarState.notifyObserver();
  }

  void _showBottomSheet() {
    _more = false;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return SafeArea(
            child: StatefulBuilder(
                builder: (BuildContext bc, StateSetter setModalState) {
              return Theme(
                  data: ThemeData(
                      listTileTheme: const ListTileThemeData(
                    tileColor: Colors.black,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                  )),
                  child: Wrap(
                    children: [
                      ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => TransferFromPage(
                                        accounts: _accounts,
                                        pushReplacement: true))));
                          },
                          leading: const Icon(Icons.transfer_within_a_station),
                          title: const Text("Transfer between accounts")),
                      ListTile(
                        leading: const Icon(Icons.payment_outlined),
                        title: const Text("Pay someone"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: ((context, animation,
                                          secondaryAnimation) =>
                                      ChoosePayeePage(
                                        accounts: _accounts,
                                        memberId: _member.id,
                                        recentPayeeEdit:
                                            _member.recentPayeeChange,
                                      )),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero));
                        },
                      ),
                      const ListTile(
                          leading: Icon(Icons.payment),
                          title: Text("Pay by BPay")),
                      const ListTile(
                          leading: Icon(Icons.phone),
                          title: Text("Cardles Cash")),
                      !_more
                          ? ListTile(
                              leading: const Icon(Icons.more_horiz),
                              title: const Text("More"),
                              onTap: () {
                                setModalState(() {
                                  _more = true;
                                });
                              },
                            )
                          : Column(children: const [
                              ListTile(
                                  leading: Icon(Icons.card_giftcard),
                                  title: Text("Cheque deposit")),
                              ListTile(
                                  leading: Icon(Icons.heart_broken),
                                  title: Text("Make a donation"))
                            ])
                    ],
                  ));
            }),
          );
        });
  }
}
