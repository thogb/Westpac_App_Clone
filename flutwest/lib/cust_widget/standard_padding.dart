import 'package:flutter/material.dart';

class StandardPadding extends StatelessWidget {
  const StandardPadding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
    );
  }
}
