import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/model/vars.dart';

class PaymentFinishPage extends StatelessWidget {
  final String senderName;
  final String receiverName;
  final String amount;

  const PaymentFinishPage(
      {Key? key,
      required this.senderName,
      required this.receiverName,
      required this.amount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: Vars.standardPaddingSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Vars.standardPaddingSize * 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Vars.standardPaddingSize * 1.5),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green[800],
                      size: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Vars.standardPaddingSize * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustHeading.big(heading: "Paid"),
                        Text(
                          "We've moved \$$amount from $senderName to $receiverName",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                            height: Vars.heightGapBetweenWidgets * 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Transfer details "),
                                GestureDetector(
                                  child: Row(
                                    children: const [
                                      Text("1111111",
                                          style: TextStyle(
                                              color: Vars.clickAbleColor)),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Vars.clickAbleColor,
                                        size: 14,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            GestureDetector(
                                child: const Icon(Icons.share,
                                    color: Vars.clickAbleColor),
                                onTap: () {})
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              CustFloatingButton.enabled(
                  title: "Done",
                  onPressed: () {
                    Navigator.pop(context, true);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
