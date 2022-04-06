import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class ProfilePage extends StatelessWidget {
  static const double iconSize = CustButton.buttonHeadingSize + 4.0;

  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            const CustTextButton(
              heading: "Settings",
              paragraph: "Personal details, security and communications",
            ),
            const CustTextButton(
              heading: "Documents",
              paragraph: "Statements, taxs summaries, proof of balance",
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
  }

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
    return const StandardPadding(
        child: CustButton(
      heading: "Inbox",
      paragraph: "Alerts, messages, notifications",
      leftWidget: Icon(
        Icons.send,
        size: iconSize,
      ),
      rightWidget: null,
    ));
  }

  Widget _getRewardsButton() {
    return const StandardPadding(
        child: CustButton(
      heading: "Rewards and offers",
      leftWidget: Icon(
        CupertinoIcons.gift_fill,
        size: iconSize,
      ),
      rightWidget: null,
    ));
  }
}
