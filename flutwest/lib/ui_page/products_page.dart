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
            delegate: SliverChildListDelegate([
          const SizedBox(height: 30.0),
          CustTextButton(
            onTap: () {},
            heading: "Bank accounts",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Home loans",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Credit cards",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Personal loans",
          ),
          CustTextButton(
            onTap: () {},
            heading: "International & travel",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Insurance",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Shares & investing",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Superannuation",
          ),
          CustTextButton(
            onTap: () {},
            heading: "Business products",
          )
        ]))
      ],
    );
  }
}
