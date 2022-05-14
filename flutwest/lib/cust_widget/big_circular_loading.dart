import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BigCircularLoading extends StatefulWidget {
  const BigCircularLoading({Key? key}) : super(key: key);

  @override
  _BigCircularLoadingState createState() => _BigCircularLoadingState();
}

class _BigCircularLoadingState extends State<BigCircularLoading>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..repeat();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: ColorTween(begin: Colors.blue[900], end: Colors.grey)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.linear)),
      ),
    );
  }
}
