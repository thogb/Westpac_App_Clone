import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({Key? key}) : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  TextEditingController _tecSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustTextFieldSearch(
            textEditingController: _tecSearch,
            autoFocus: true,
            onPrefixButtonTap: () {
              Navigator.pop(context);
            }),
      ],
    );
  }
}
