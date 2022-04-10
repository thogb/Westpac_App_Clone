import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({Key? key}) : super(key: key);

  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  static const TextStyle fakeAppBarStyle =
      TextStyle(color: Colors.white, fontSize: 16.0);

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
                      _getFakeAppBar(),
                      const SizedBox(height: 120.0),
                      _getWelcomeText(),
                      _getSearchBar(),
                    ],
                  ),
                ),
                _getBottomContent()
              ],
            ),
          ),
        ],
      ),
    );
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
              color: Colors.white, borderRadius: BorderRadius.circular(3.0)),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      child: StandardPadding(
        child: Column(
          children: [
            const SizedBox(height: Vars.topBotPaddingSize),
            _getAccountSection(),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            const CustButton(
              leftWidget: Icon(Icons.money),
              heading: "Payments",
              paragraph: "Upcoming, past, direct debits, BPAY View",
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
