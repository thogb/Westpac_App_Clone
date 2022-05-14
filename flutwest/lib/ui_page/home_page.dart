import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/member.dart';
import 'package:flutwest/model/navbar_state.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/cards_page.dart';
import 'package:flutwest/ui_page/home_content_page.dart';
import 'package:flutwest/ui_page/products_page.dart';
import 'package:flutwest/ui_page/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color unselectedNavItemColor = Colors.black54;
  static const Color selectedNavItemColor = Colors.black;
  static const double navItemIconSize = 30.0;

  late NavbarState navbarState;

  bool _showNavBar = true;
  bool _more = false;
  int _currPage = 0;

  final List<Widget> _pages = List.filled(5, const SizedBox());

  final Future<DocumentSnapshot<Map<String, dynamic>>> _futureMember =
      FirestoreController.instance.getMember(Vars.fakeMemberID);
  final Future<QuerySnapshot<Map<String, dynamic>>> _futureAccounts =
      FirestoreController.instance.getAccounts(Vars.fakeMemberID);

  late final Future<List<Object>>? futures;

  late Member _member;
  late List<Account> _accounts;

  final List<AccountOrderInfo> _accountOrderInfos = [];

  @override
  void initState() {
    Utils.showSysNavBarColour();
    navbarState = NavbarState(
        showNavBar: showNavBar,
        hideNavBar: hideNavBar,
        changeToPage: _onNavbarTap);

    // _pages.add(HomeContentPage(navbarState: navbarState));
    // _pages.add(const CardsPage());
    // _pages.add(const SizedBox());
    // _pages.add(const ProductsPage());
    // _pages.add(const ProfilePage());

    futures = Future.wait([_futureMember, _futureAccounts]);

    super.initState();
  }

  @override
  void dispose() {
    Utils.hideSysNavBarColour();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futures,
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshots) {
        if (snapshots.hasError) {
          return _getErrorPage("Error, could not retrieve data");
        }

        if (snapshots.hasData && snapshots.data!.isEmpty) {
          return _getErrorPage("Document does not exist");
        }

        if (snapshots.connectionState == ConnectionState.done) {
          QuerySnapshot<Map<String, dynamic>> queryAccounts =
              snapshots.data![1] as QuerySnapshot<Map<String, dynamic>>;
          DocumentSnapshot<Map<String, dynamic>> queryMember =
              snapshots.data![0] as DocumentSnapshot<Map<String, dynamic>>;

          if (queryMember.data() == null) {
            return _getErrorPage(
                "Could not load member data of member: ${Vars.fakeMemberID}");
          }

          _accounts =
              queryAccounts.docs.map((e) => Account.fromMap(e.data())).toList();
          _member = Member.fromMap(
              (queryMember.data() as Map<String, dynamic>), _accounts);

          _pages[0] = (HomeContentPage(
            navbarState: navbarState,
            member: _member,
            accountOrderInfos: _accountOrderInfos,
          ));
          //_pages.add(CardsPage(cardNumber: _member.cardNumber));
          //_pages.add(const SizedBox());
          //_pages.add(const ProductsPage());
          //_pages.add(const ProfilePage());

          print("Opening home page in future");
          return _getHomePage();
        }

        return const BackgroundImage();
      },
    );
  }

  Widget _getErrorPage(String errorMsg) {
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
  }

  Widget _getHomePage() {
    print("Home Page recreated");
    return Theme(
        data: ThemeData(
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: AppBarTheme(
                color: Colors.grey[50],
                titleTextStyle: const TextStyle(color: Colors.black))),
        child: Scaffold(
          body: Theme(
            data: ThemeData(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.grey[100]),
            child: Stack(
              children: [
                IndexedStack(children: _pages, index: _currPage),
              ],
            ),
          ),
          bottomNavigationBar: !_showNavBar
              ? const SizedBox()
              : BottomNavigationBar(
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
                        label: "",
                        icon: _getNavIcon(Icons.home_outlined, "Home"),
                        activeIcon:
                            _getNavIcon(Icons.home_sharp, "Home", true)),
                    BottomNavigationBarItem(
                        label: "",
                        icon: _getNavIcon(CupertinoIcons.creditcard, "Cards"),
                        activeIcon: _getNavIcon(
                            Icons.credit_card_sharp, "Cards", true)),
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
                        label: "",
                        icon: _getNavIcon(CupertinoIcons.cube, "Products"),
                        activeIcon: _getNavIcon(
                            CupertinoIcons.cube_fill, "Products", true)),
                    BottomNavigationBarItem(
                        label: "",
                        icon: _getNavIcon(Icons.person_outline, "Profile"),
                        activeIcon:
                            _getNavIcon(Icons.person_sharp, "Profile", true)),
                  ],
                  /*items: [
              const BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home_sharp, size: navItemIconSize),
                  icon: Icon(Icons.home_outlined, size: navItemIconSize),
                  label: "Home",
                  tooltip: "Home"),
              const BottomNavigationBarItem(
                  activeIcon: Icon(CupertinoIcons.creditcard_fill,
                      size: navItemIconSize),
                  icon: Icon(CupertinoIcons.creditcard, size: navItemIconSize),
                  label: "Cards",
                  tooltip: "Cards"),
              BottomNavigationBarItem(
                  icon: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red[700]),
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                  ),
                  label: ""),
              const BottomNavigationBarItem(
                  activeIcon: Icon(CupertinoIcons.cube_fill),
                  icon: Icon(CupertinoIcons.cube),
                  label: "Products",
                  tooltip: "Products"),
              const BottomNavigationBarItem(
                  activeIcon: Icon(Icons.person_sharp, size: navItemIconSize),
                  icon: Icon(Icons.person_outline, size: navItemIconSize),
                  label: "Profile",
                  tooltip: "Profile"),
            ],*/
                ),
        ));
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
              color: active ? selectedNavItemColor : unselectedNavItemColor),
        )
      ],
    );
  }

  void _onNavbarTap(int index) {
    if (index == 2) {
      _showBottomSheet();
    } else {
      if (index == 1) {
        Account cardAccount = _accounts[0];

        for (Account account in _accounts) {
          if (account.cardNumber == _member.cardNumber) {
            cardAccount = account;
            break;
          }
        }
        _pages[1] = CardsPage(
            cardNumber: _member.cardNumber,
            cardAccount: cardAccount,
            accountOrderInfos: _accountOrderInfos);
      } else if (index == 3) {
        _pages[3] = const ProductsPage();
      } else if (index == 4) {
        _pages[4] = const ProfilePage();
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
          return StatefulBuilder(
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
                    const ListTile(
                        leading: Icon(Icons.transfer_within_a_station),
                        title: Text("Transfer between accounts")),
                    const ListTile(
                        leading: Icon(Icons.payment_outlined),
                        title: Text("Pay someone")),
                    const ListTile(
                        leading: Icon(Icons.payment),
                        title: Text("Pay by BPay")),
                    const ListTile(
                        leading: Icon(Icons.phone),
                        title: Text("Cardles Cash")),
                    !_more
                        ? ListTile(
                            leading: const Icon(Icons.expand),
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
                          ]),
                    const ListTile(title: Text("")),
                  ],
                ));
          });
        });
  }
}
