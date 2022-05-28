import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_silver_appbar.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double iconSize = Vars.headingTextSize2 + 4.0;
  int value = 31;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CustSilverAppbar(
          title: "Profile",
          actions: [
            TextButton(onPressed: () {}, child: const Text("Sign Out"))
          ],
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          _getProfileDataSection(),
          _getInboxButton(),
          const SizedBox(height: Vars.heightGapBetweenWidgets),
          _getRewardsButton(),
          const SizedBox(height: Vars.heightGapBetweenWidgets),
          CustTextButton(
              onTap: () {},
              heading: "Settings",
              paragraph: "Personal details, security and communications"),
          CustTextButton(
            heading: "Documents",
            paragraph: "Statements, taxs summaries, proof of balance",
            onTap: () {
              setState(() {
                value--;
              });
            },
          ),
          CustTextButton(
            onTap: () {},
            heading: "Payments",
            paragraph: "Upcoming, past, direct debits, BPAY View",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Payees and billers",
            paragraph: "Add, delete",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Help",
            paragraph: "FAQs, topics, feedback, contact us",
          ),
          const SizedBox(height: 50.0)
        ]))
      ],
    );
  }

/*
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _getProfileDataSection(),
            _getInboxButton(),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            _getRewardsButton(),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            CustTextButton(
                heading: "Settings",
                paragraph: "Personal details, security and communications",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProductsPage()));
                }),
            CustTextButton(
              heading: "Documents",
              paragraph: "Statements, taxs summaries, proof of balance",
              onTap: () {
                setState(() {
                  value--;
                });
              },
            ),
            const CustTextButton(
              heading: "Payments",
              paragraph: "Upcoming, past, direct debits, BPAY View",
            ),
            const CustTextButton(
              heading: "Payees and billers",
              paragraph: "Add, delete",
            ),
            const CustTextButton(
              heading: "Help",
              paragraph: "FAQs, topics, feedback, contact us",
            )
          ],
        ),
      ),
    );
  }*/

  Widget _getProfileDataSection() {
    return StandardPadding(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 35.0),
      child: Row(
        children: [
          Stack(
            children: [
              const SizedBox(
                width: 54.0,
                height: 54.0,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.person,
                    size: 34.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(width: 1.0, color: Colors.black12)),
                  child: const Icon(Icons.camera_alt_outlined, size: 11.0),
                ),
              ),
            ],
          ),
          const SizedBox(width: 17.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Hi Tao Hu",
                style: CustButton.buttonHeadingStyle,
              ),
              SizedBox(height: 4.0),
              Text("Customer ID 22222222")
            ],
          )
        ],
      ),
    ));
  }

  Widget _getInboxButton() {
    return StandardPadding(
        child: CustButton(
      onTap: () {},
      heading: "Inbox",
      paragraph: "Alerts, messages, notifications",
      leftWidget: const Icon(
        Icons.send,
        size: iconSize,
      ),
      rightWidget: _getAlertUnseen(value),
    ));
  }

  Widget _getRewardsButton() {
    return StandardPadding(
        child: CustButton(
      onTap: () {},
      heading: "Rewards and offers",
      leftWidget: const Icon(
        CupertinoIcons.gift_fill,
        size: iconSize,
      ),
      rightWidget: _getAlertUnseen(1),
    ));
  }

  Widget _getAlertUnseen(int val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
      decoration: BoxDecoration(
          color: Colors.red[700], borderRadius: BorderRadius.circular(10.0)),
      child: Text(
        val.toString(),
        style: const TextStyle(fontSize: 12.0, color: Colors.white),
      ),
    );
  }
}
