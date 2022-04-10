import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
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

  bool _more = false;
  int _currPage = 0;

  static const List<Widget> _pages = <Widget>[
    HomeContentPage(),
    CardsPage(),
    SizedBox(),
    ProductsPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: AppBarTheme(
                color: Colors.grey[50],
                titleTextStyle: const TextStyle(color: Colors.black))),
        child: Scaffold(
          body: IndexedStack(children: _pages, index: _currPage),
          bottomNavigationBar: BottomNavigationBar(
            onTap: _onNavbarTap,
            currentIndex: _currPage,
            unselectedItemColor: unselectedNavItemColor,
            selectedItemColor: selectedNavItemColor,
            //selectedFontSize: 12.0,
            //unselectedFontSize: 12.0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                  label: "",
                  icon: _getNavIcon(Icons.home_outlined, "Home"),
                  activeIcon: _getNavIcon(Icons.home_sharp, "Home", true)),
              BottomNavigationBarItem(
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
                  label: "",
                  icon: _getNavIcon(CupertinoIcons.cube, "Products"),
                  activeIcon:
                      _getNavIcon(CupertinoIcons.cube_fill, "Products", true)),
              BottomNavigationBarItem(
                  label: "",
                  icon: _getNavIcon(Icons.person_outline, "Profile"),
                  activeIcon: _getNavIcon(Icons.person_sharp, "Profile", true)),
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
      setState(() {
        _currPage = index;
      });
    }
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
                          ])
                  ],
                ));
          });
        });
  }
}
