import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/cust_widget/clickable_text.dart';
import 'package:flutwest/cust_widget/cust_floating_button.dart';
import 'package:flutwest/cust_widget/cust_heading.dart';
import 'package:flutwest/cust_widget/cust_paragraph.dart';
import 'package:flutwest/cust_widget/editing_page_scaffold.dart';
import 'package:flutwest/model/account.dart';
import 'package:flutwest/model/payee.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/loading_page.dart';
import 'package:flutwest/ui_page/payment_page.dart';

class PayeeInfoPage extends StatelessWidget {
  final String memberId;
  final Payee payee;
  final List<Account> accounts;

  const PayeeInfoPage(
      {Key? key,
      required this.memberId,
      required this.payee,
      required this.accounts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditingPageScaffold(
      leadingIcon: EditingPageScaffold.leadingIconArrowBack,
      content: [
        CustHeading.big(heading: payee.getNickName),
        CustParagraph.normal(
            reversed: true,
            heading: "Account name",
            paragraph: payee.getAccountName),
        CustParagraph.php(
            paragraph1: "BSB",
            heading: payee.getAccountID.getBsb,
            paragraph2: "Bank Name"),
        CustParagraph.normal(
          reversed: true,
          heading: "Account number",
          paragraph: payee.getAccountID.getNumber,
        ),
        CustParagraph.normal(
            reversed: true,
            heading: "Payment Reference Number (PRN) pr EFT code",
            paragraph: "Not given"),
        const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),
        ClickableText.medium(
            text: "Delete Payee",
            onTap: () async {
              bool delete = false;

              await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                          "Are you sure you'd like to delete this payee?"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () {
                              delete = true;
                              Navigator.pop(context);
                            },
                            child: const Text("Delete"))
                      ],
                    );
                  });

              if (delete) {
                await Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder:
                            ((context, animation, secondaryAnimation) =>
                                LoadingPage(futureObject: deletePayee())),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero));
                Navigator.pop(context, true);
              }
            })
      ],
      floatingActionButton: CustFloatingButton.enabled(
          title: "Pay",
          onPressed: () async {
            Object? result = await Navigator.push(
                context,
                PageRouteBuilder(
                    pageBuilder: ((context, animation, secondaryAnimation) =>
                        PaymentPage(
                            memberId: memberId,
                            accounts: accounts,
                            currAccount: accounts[0],
                            payee: payee)),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero));
            if (result != null) {
              if ((result as bool) == true) {
                Navigator.pop(context);
              }
            }
          }),
    );
  }

  Future<void> deletePayee() async {
    DateTime delDate = DateTime.now();
    await FirestoreController.instance.colMember.colPayee
        .deletePayee(memberId, payee.docId, delDate);
    await SQLiteController.instance.delPayee(memberId, payee.docId, delDate);
  }
}
