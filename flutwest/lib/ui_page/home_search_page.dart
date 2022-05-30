import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/cust_fake_appbar.dart';
import 'package:flutwest/cust_widget/cust_text_field_search.dart';

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({Key? key}) : super(key: key);

  @override
  _HomeSearchPageState createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  static const filterTop = "Top";

  final TextEditingController _tecSearch = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        CustFakeAppbar(
          scrollController: _scrollController,
          content: Column(
            children: [
              CustTextFieldSearch(
                  textEditingController: _tecSearch,
                  autoFocus: true,
                  onPrefixButtonTap: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ],
    ));
  }
}
