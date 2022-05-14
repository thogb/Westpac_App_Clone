import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/outlined_container.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';
import 'package:flutwest/model/vars.dart';

class LockCardInfoPage extends StatelessWidget {
  const LockCardInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_getTopSection(), _getBottomSection(context)],
      ),
    );
  }

  Widget _getTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Vars.standardPaddingSize * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Vars.heightGapBetweenWidgets * 4),
          _getLockIcon(),
          const SizedBox(height: Vars.heightGapBetweenWidgets * 1.5),
          const Text(
            "We've temporarily locked your card",
            style: Vars.headingStyle1,
          ),
          const SizedBox(height: Vars.heightGapBetweenWidgets * 2),
          const Text(
              "You can unlock your card at any time. It'll automatically unlock after 15 days.\n\n"
              "Any digital Wallets you have set up using thyis card have also been locked.\n\n"
              "Recurring payments and direct debits on this card number may not work whilst locked."),
          const SizedBox(height: Vars.heightGapBetweenWidgets * 2),
          GestureDetector(
              onTap: () {},
              child: const Text("View direct debits",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _getLockIcon() {
    return Container(
        width: 80,
        height: 80,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.green[800]),
        child: const Icon(Icons.lock, color: Colors.white, size: 40));
  }

  Widget _getBottomSection(BuildContext context) {
    return Column(
      children: [
        _getExtraInfo(),
        const SizedBox(height: Vars.heightGapBetweenWidgets),
        _getDoneButton(context),
        const SizedBox(
          height: 60,
        )
      ],
    );
  }

  Widget _getExtraInfo() {
    return StandardPadding(
      child: Container(
        width: double.infinity,
        color: Colors.blueGrey.withOpacity(0.1),
        child: OutlinedContainer(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("You can still use ATMS",
                style: TextStyle(
                    fontSize: Vars.headingTextSize2,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text("Get cash without a card",
                style: TextStyle(fontSize: 12.0, color: Colors.black87)),
            const SizedBox(height: Vars.heightGapBetweenWidgets),
            GestureDetector(
                onTap: () {},
                child: const Text("Try Cardless Cash",
                    style: TextStyle(color: Colors.red)))
          ],
        )),
      ),
    );
  }

  Widget _getDoneButton(BuildContext context) {
    return StandardPadding(
      child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: Colors.red[800],
              splashFactory: NoSplash.splashFactory),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Center(
              child: Text("Done", style: TextStyle(color: Colors.white)))),
    );
  }
}
