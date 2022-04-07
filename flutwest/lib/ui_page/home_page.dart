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
  static const Color unselectedNavItemColor = Colors.black45;
  static const Color selectedNavItemColor = Colors.black;
  static const double navItemIconSize = 30.0;

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
            selectedFontSize: 12.0,
            unselectedFontSize: 12.0,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home, size: navItemIconSize),
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
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
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
                  activeIcon: Icon(Icons.person, size: navItemIconSize),
                  icon: Icon(Icons.person_outline, size: navItemIconSize),
                  label: "Profile",
                  tooltip: "Profile"),
            ],
          ),
        ));
  }

  void _onNavbarTap(int index) {
    if (index == 2) {
    } else {
      setState(() {
        _currPage = index;
      });
    }
  }
}
