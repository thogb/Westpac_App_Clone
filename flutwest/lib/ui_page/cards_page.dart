import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/cust_widget/cust_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_silver_appbar.dart';
import 'package:flutwest/cust_widget/cust_text_button.dart';
import 'package:flutwest/cust_widget/loading_text.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/bank_card.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/account_detail_page.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/lock_card_info_page.dart';

class CardsPage extends StatefulWidget {
  final String cardNumber;
  final Account cardAccount;
  final List<AccountOrderInfo> accountOrderInfos;

  const CardsPage(
      {Key? key,
      required this.cardNumber,
      required this.cardAccount,
      required this.accountOrderInfos})
      : super(key: key);

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

  bool? _lockCard;
  bool _showDigitalCard = false;
  late BankCard _bankCard;
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _futureCard;

  @override
  void initState() {
    _futureCard = FirestoreController.instance.getBankCard(widget.cardNumber);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CustSilverAppbar(title: "Cards"),
        SliverList(
            delegate: SliverChildListDelegate([
          FutureBuilder(
              future: _futureCard,
              builder: ((context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.hasError) {
                  return const Align(
                      alignment: Alignment.center,
                      child: Text("Error loading card"));
                }

                bool loading =
                    snapshot.connectionState == ConnectionState.waiting;

                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      !snapshot.data!.exists) {
                    return const Align(
                        alignment: Alignment.center,
                        child: Text("Card not found"));
                  }

                  _bankCard = BankCard.fromMap(snapshot.data!.data()!);
                  _lockCard ??= _bankCard.locked;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    loading
                        ? _getCard(
                            Vars.loadingDummyColor, Vars.loadingDummyColor)
                        : _getCard(Colors.red[600], Colors.red[900]),
                    Text(
                      "Westpac Debit\nMastercard\u00AE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: loading ? Colors.transparent : Colors.black),
                    ),
                    !loading
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //card info
                              const SizedBox(height: 10.0),

                              _getShowCardInfo(),
                              _getLockButton(),
                              _getBottomButtons()
                            ],
                          )
                        : Column(
                            children: const [
                              LoadingText(),
                              LoadingText(),
                              LoadingText()
                            ],
                          ),
                  ],
                );
              }))
        ]))
      ],
    );
  }

  Widget _getCard(Color? unlocked, Color? locked) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        width: 280.0,
        height: 180.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: _lockCard != null && !_lockCard! ? unlocked : locked),
        child: _lockCard != null && _lockCard!
            ? Column(
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
                  ])
            : null);
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
        onExpansionChanged: ((value) {
          setState(() {
            _showDigitalCard = value;
          });
        }),
        childrenPadding: const EdgeInsets.symmetric(vertical: 0.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card number",
              style: cardInfoTitleStyle,
            ),
            const SizedBox(height: cardInfoTitleGap),
            Text(
              !_showDigitalCard
                  ? "* * * *  * * * *  * * * *  ${_bankCard.fourthFourDigit}"
                  : "${_bankCard.firstFourDigit} ${_bankCard.secondFourDigit} ${_bankCard.thirdFourDigit} ${_bankCard.fourthFourDigit}",
              style: cardInfoSubTitleStyle,
            )
          ],
        ),
        trailing: Text("Show Digital Card",
            style: TextStyle(
                color: cardInfoTrailingColor, fontSize: cardInfoTrailingSize)),
        children: [
          _getCardInfoTile("Name", _bankCard.name, null),
          _getCardInfoTile("Expiry", _bankCard.expiryString, null),
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
        subtitle: !_lockCard!
            ? const Text("Unlocked")
            : Row(
                children: [
                  const Text("Temporarily locked."),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  ((context, animation, secondaryAnimation) =>
                                      const LockCardInfoPage()),
                              transitionDuration: const Duration(seconds: 0)));
                    },
                    child: Icon(
                      Icons.info_outline,
                      color: cardInfoTrailingColor,
                    ),
                  )
                ],
              ),
        value: _lockCard!,
        onChanged: (bool value) async {
          setState(() {
            _lockCard = value;
          });
          await Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: ((context, animation, secondaryAnimation) =>
                      LoadingPage(
                          futureObject: FirestoreController.instance
                              .updateBankCardLockStatus(
                                  widget.cardNumber, value))),
                  transitionDuration: const Duration(seconds: 0),
                  reverseTransitionDuration: const Duration(seconds: 0)));
          if (value == false) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Your card is unlocked"),
                    content: const Text("You can use your card as normal"),
                    actions: [
                      TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Ok")),
                    ],
                  );
                });
          } else {
            Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: ((context, animation, secondaryNimation) =>
                        const LockCardInfoPage()),
                    transitionDuration: const Duration(seconds: 0)));
          }
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
                onTap: () {
                  int index = 0;
                  for (int i = 0; i < widget.accountOrderInfos.length; i++) {
                    if (widget.cardAccount.getNumber ==
                        widget.accountOrderInfos[i].getAccount().getNumber) {
                      index = i;
                      break;
                    }
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountDetailPage(
                              accounts: widget.accountOrderInfos,
                              currIndex: index)));
                },
                leftWidget: Text(
                  "Westpac ${widget.cardAccount.getType}",
                  style: const TextStyle(fontSize: Vars.headingTextSize2),
                ),
                heading: "\n",
                rightWidget: Text("\$${widget.cardAccount.getBalance}",
                    style: CustButton.buttonHeadingStyle))),
        const SizedBox(height: 30.0)
      ],
    );
  }
}
