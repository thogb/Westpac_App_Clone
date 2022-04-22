import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_silver_appbar.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  static const TextStyle cardInfoTitleStyle =
      TextStyle(color: Colors.black54, fontSize: 14.0);
  static const TextStyle cardInfoSubTitleStyle = TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0);
  static final Color? cardInfoTrailingColor = Colors.red[600];
  static const double cardInfoTrailingSize = 14.0;
  static const double cardInfoTitleGap = 4.0;

  bool _lockCard = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CustSilverAppbar(title: "Cards"),
        SliverList(
            delegate: SliverChildListDelegate([
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getCard(),
              const Text(
                "Westpac Debit\nMastercard\u00AE",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //card info
                  const SizedBox(height: 10.0),

                  _getShowCardInfo(),
                  _getLockButton(),
                  _getBottomButtons()
                ],
              ),
            ],
          )
        ]))
      ],
    );
  }

  Widget _getCard() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        width: 280.0,
        height: 180.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: !_lockCard ? Colors.red[600] : Colors.red[900]),
        child: !_lockCard
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                    Icon(
                      Icons.lock,
                      size: 60.0,
                      color: Colors.white,
                    ),
                    Text(
                      "Locked temporarily",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    )
                  ]));
  }

  Widget _getCardInfoTile(String title, String subtitle, Widget? trailer) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4.0),
      title: Padding(
        padding: const EdgeInsets.only(bottom: cardInfoTitleGap),
        child: Text(title, style: cardInfoTitleStyle),
      ),
      subtitle: Text(
        subtitle,
        style: cardInfoSubTitleStyle,
      ),
      trailing: trailer,
    );
  }

  Widget _getShowCardInfo() {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(vertical: 0.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Card number",
              style: cardInfoTitleStyle,
            ),
            SizedBox(height: cardInfoTitleGap),
            Text(
              "* * * *  * * * *  * * * *  8888",
              style: cardInfoSubTitleStyle,
            )
          ],
        ),
        trailing: Text("Show Digital Card",
            style: TextStyle(
                color: cardInfoTrailingColor, fontSize: cardInfoTrailingSize)),
        children: [
          _getCardInfoTile("Name", "TAO HU", null),
          _getCardInfoTile("Expiry", "02/23", null),
          _getCardInfoTile(
              "Dynamic CVC",
              "061",
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.fromLTRB(
                                24.0, 12.0, 24.0, 0.0),
                            actionsPadding: EdgeInsets.zero,
                            title: const Text(
                              "About your digital Card",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal),
                            ),
                            content: const Text(
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ut lectus id purus varius accumsan a at augue. Phasellus sed elit velit. Duis tristique condimentum tempor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum eget augue vel turpis gravida elementum et nec turpis. Nunc eget.",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black54),
                            ),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero),
                                onPressed: () {},
                                child: const Text("Learn more"),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ok"))
                            ],
                          );
                        });
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: cardInfoTrailingColor,
                  )))
        ],
      ),
    );
  }

  Widget _getLockButton() {
    return SwitchListTile(
        activeColor: Colors.blue[900],
        title: const Text("Lock card Temporarily"),
        subtitle: !_lockCard
            ? const Text("Unlocked")
            : Row(
                children: [
                  const Text("Temporarily locked."),
                  Icon(
                    Icons.info_outline,
                    color: cardInfoTrailingColor,
                  )
                ],
              ),
        value: _lockCard,
        onChanged: (bool value) {
          setState(() {
            _lockCard = value;
          });
        });
  }

  Widget _getBottomButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustHeading(
          heading: "Security",
        ),
        //lock cards
        CustTextButton(
          heading: "Report lost or stolen",
          onTap: () {},
        ),
        CustTextButton(
          heading: "Set or change PIN",
          onTap: () {},
        ),
        CustTextButton(
          heading: "Reissue Card",
          onTap: () {},
        ),
        CustTextButton(
          heading: "Notify of overseas travel",
          onTap: () {},
        ),

        //Wallets
        const CustHeading(
          heading: "Wallets",
        ),
        CustTextButton(
          heading: "Other wallets and Wearables",
          onTap: () {},
        ),

        //Controls
        const CustHeading(
          heading: "Controls",
        ),
        CustTextButton(
          heading: "Gamlbing Block",
          onTap: () {},
        ),
        CustTextButton(
          heading: "Activate card",
          onTap: () {},
        ),

        //Linked Account
        const CustHeading(
          heading: "Linked accounts",
        ),
        StandardPadding(
            child: CustButton(
                onTap: () {},
                leftWidget: const Text(
                  "Westpac Choice",
                  style: TextStyle(fontSize: Vars.headingTextSize2),
                ),
                heading: "\n",
                rightWidget: const Text("\$1333.33",
                    style: CustButton.buttonHeadingStyle))),
        const SizedBox(height: 30.0)
      ],
    );
  }
}
