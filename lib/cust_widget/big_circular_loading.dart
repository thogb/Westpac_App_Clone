import 'package:flutter/material.dart';

class BigCircularLoading extends StatefulWidget {
  final double width;
  final double height;
  const BigCircularLoading({Key? key, this.width = 100, this.height = 100})
      : super(key: key);

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
      width: widget.width,
      height: widget.height,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: ColorTween(begin: Colors.blue[900], end: Colors.grey)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.linear)),
      ),
    );
  }
}
