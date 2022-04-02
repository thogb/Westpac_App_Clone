import 'package:flutter/material.dart';
import 'package:flutwest/model/vars.dart';

import '../cust_widget/cust_text_button.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          bottomOpacity: 0.0,
          titleTextStyle: Vars.appbarTitleStyle,
          title: const Text("Products"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: const [
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
            ],
          ),
        ));
  }
}
