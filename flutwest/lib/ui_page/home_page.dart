import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [],
    )));
  }
}

StandardPadding getTop() {
  return const StandardPadding();
}
