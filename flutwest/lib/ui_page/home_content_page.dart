import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_silver_appbar.dart';
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
          CustSilverAppbar(title: "Profile", actions: [
            TextButton(onPressed: () {}, child: const Text("Sign Out"))
          ]),
          SliverList(
            delegate: SliverChildListDelegate([
              CustTextButton(
                heading: "Hello",
                paragraph: "test",
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return Theme(
                            data: ThemeData(
                                listTileTheme: const ListTileThemeData(
                              tileColor: Colors.black,
                              iconColor: Colors.white,
                              textColor: Colors.white,
                            )),
                            child: Container(
                              child: Column(
                                children: [
                                  ListTile(
                                      leading:
                                          Icon(Icons.transfer_within_a_station),
                                      title: Text("Transfer between accounts"))
                                ],
                              ),
                            ));
                      });
                },
              ),
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
