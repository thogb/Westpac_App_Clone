import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({Key? key}) : super(key: key);

  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              TextButton(
                  onPressed: () {},
                  child: Container(
                    child: Text("Sign Out"),
                  ))
            ],
            pinned: true,
            floating: true,
            snap: false,
            expandedHeight: 80.0,
            title: Text("asdasd"),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
              titlePadding: EdgeInsets.only(bottom: 12.0, left: 15.0),
              expandedTitleScale: 1.2,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test"),
              const CustTextButton(heading: "Hello", paragraph: "test")
            ]),
          )
        ],
      ),
    );
  }
}
