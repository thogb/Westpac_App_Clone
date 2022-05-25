import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/big_circular_loading.dart';

class LoadingPage extends StatelessWidget {
  final Future<dynamic> futureObject;
  const LoadingPage({Key? key, required this.futureObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    awaitFutureObject(context);
    return const Scaffold(
      body: Center(
        child: BigCircularLoading(),
      ),
    );
  }

  void awaitFutureObject(BuildContext context) async {
    dynamic stuff = await futureObject;
    Navigator.pop(context, stuff);
  }
}
