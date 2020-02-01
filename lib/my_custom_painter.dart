import 'dart:math';

import 'package:flutter/material.dart';

class MyPainterWidget extends StatelessWidget {
  double xPosition1;
  double yPosition1;
  double xPosition2;
  double yPosition2;
  Point startPos;
  Point endPos;

  MyPainterWidget(
      this.xPosition1, this.xPosition2, this.yPosition1, this.yPosition2) {
    startPos = Point(min(xPosition1, xPosition2), min(yPosition1, yPosition2));
    endPos = Point(max(xPosition1, xPosition2), max(yPosition1, yPosition2));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        painter: MyPainter(
            this.xPosition1, this.xPosition2, this.yPosition1, this.yPosition2),
        child: Container(
            // height: MediaQuery.of(context).size.height,
            // width: MediaQuery.of(context).size.width,
            ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  double xPosition1;
  double yPosition1;
  double xPosition2;
  double yPosition2;

  MyPainter(this.xPosition1, this.xPosition2, this.yPosition1, this.yPosition2);

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(this.xPosition1, this.yPosition1);
    final p2 = Offset(this.xPosition2, this.yPosition2);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return xPosition1 != oldDelegate.xPosition1;
    // return false;
  }
}
