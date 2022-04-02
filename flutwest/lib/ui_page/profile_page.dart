import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}

Widget _getProfileDataSection() {
  return StandardPadding(child: Container());
}
