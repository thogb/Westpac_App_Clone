import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class WestLogo extends StatelessWidget {
  final double width;

  const WestLogo({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = 8.5 / 20.5 * width;
    double sideWidth = 7.5 / 20.5 * width;
    double middleWidth = 4.5 / 20.5 * width;
    double gapWidth = (20.5 - 7.5 - 7.5 - 4.5) / 2.0 / 20.5 * width;
    Matrix4 matrix = Matrix4.rotationY(pi)..translate(sideWidth * -1.0);

    return Wrap(
      direction: Axis.horizontal,
      children: [
        Container(
          width: sideWidth,
          height: height,
          transform: matrix,
          decoration:
              ShapeDecoration(color: Colors.white, shape: LogoSideBorder()),
        ),
        SizedBox(width: gapWidth),
        Container(
          color: Colors.white,
          width: middleWidth,
          height: height,
        ),
        SizedBox(width: gapWidth),
        Container(
          width: sideWidth,
          height: height,
          decoration:
              ShapeDecoration(color: Colors.white, shape: LogoSideBorder()),
        ),
      ],
    );
  }
}

class LogoSideBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()
      ..moveTo(rect.topLeft.dx + rect.width * 0.45, rect.topLeft.dy)
      ..relativeArcToPoint(Offset(rect.width * -0.1, rect.width * 0.1),
          radius: Radius.circular(rect.width * 0.1 * 1.5), clockwise: false)
      ..lineTo(rect.bottomLeft.dx + rect.width * 0.1 * 0.5,
          rect.bottomLeft.dy - rect.width * 0.1)
      ..arcToPoint(Offset(rect.bottomLeft.dx, rect.bottomLeft.dy),
          radius: Radius.circular(rect.width * 0.3))
      ..lineTo(rect.bottomLeft.dx + rect.width * 0.55, rect.bottomLeft.dy)
      ..relativeArcToPoint(Offset(rect.width * 0.1, rect.width * -0.1),
          radius: Radius.circular(rect.width * 0.1 * 1.5), clockwise: false)
      ..lineTo(rect.topRight.dx + rect.width * -0.1 * 0.5,
          rect.topRight.dy + rect.width * 0.1)
      ..arcToPoint(Offset(rect.topRight.dx, rect.topRight.dy),
          radius: Radius.circular(rect.width * 0.1 * 1.5))
      ..lineTo(rect.topLeft.dx + rect.width * 0.45, rect.topLeft.dy);

    return path..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}
