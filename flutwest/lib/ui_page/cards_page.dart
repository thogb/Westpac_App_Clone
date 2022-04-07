import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cards")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Security
            CustHeading(heading: "Security"),
            //lock cards
            CustTextButton(heading: "Report lost or stolen"),
            CustTextButton(heading: "Set or change PIN"),
            CustTextButton(heading: "Reissue Card"),
            CustTextButton(heading: "Notify of overseas travel"),

            //Wallets
            CustHeading(heading: "Wallets"),
            CustTextButton(heading: "Other wallets and Wearables"),

            //Controls
            CustHeading(heading: "Controls"),
            CustTextButton(heading: "Gamlbing Block"),
            CustTextButton(heading: "Activate card"),

            //Linked Account
            CustHeading(heading: "Linked accounts"),
            StandardPadding(
                child: CustButton(
                    leftWidget: Text(
                      "Westpac Choice",
                      style: TextStyle(fontSize: CustButton.buttonHeadingSize),
                    ),
                    heading: "\n",
                    rightWidget: Text("\$1333.33",
                        style: CustButton.buttonHeadingStyle))),
            SizedBox(height: 30.0)
          ],
        ),
      ),
    );
  }
}
