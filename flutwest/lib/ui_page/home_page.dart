import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currPage = 0;

  static const List<Widget> _pages = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(children: _pages, index: _currPage),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onNavbarTap,
        currentIndex: _currPage,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home", tooltip: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Cards", tooltip: "Cards"),
          BottomNavigationBarItem(icon: Icon(Icons.money)),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: "Products",
              tooltip: "Products"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile", tooltip: "Profile"),
        ],
      ),
    );
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
