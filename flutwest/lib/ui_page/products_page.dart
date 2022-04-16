import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_silver_appbar.dart';

import '../cust_widget/cust_text_button.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CustSilverAppbar(title: "Products"),
        SliverList(
            delegate: SliverChildListDelegate(const [
          SizedBox(height: 30.0),
          CustTextButton(
            heading: "Bank accounts",
          ),
          CustTextButton(
            heading: "Home loans",
          ),
          CustTextButton(
            heading: "Credit cards",
          ),
          CustTextButton(
            heading: "Personal loans",
          ),
          CustTextButton(
            heading: "International & travel",
          ),
          CustTextButton(
            heading: "Insurance",
          ),
          CustTextButton(
            heading: "Shares & investing",
          ),
          CustTextButton(
            heading: "Superannuation",
          ),
          CustTextButton(
            heading: "Business products",
          )
        ]))
      ],
    );
  }
}
