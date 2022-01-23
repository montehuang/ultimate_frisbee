/*
 * @Author: Monte
 * @Date: 2022-01-23
 * @Description: 
 */
import 'dart:math';

import 'package:flutter/material.dart';
class CurvePainter extends CustomPainter {
  CurvePainter(
      { this.begin,
       this.middle,
       this.end,
       this.controlPos=const[],
       this.isLine});
  Offset? begin;
  Offset? middle;
  Offset? end;
  late List<Offset> controlPos;
  bool? isLine = true;


  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
    ..strokeWidth = 1
    ..color = Colors.grey.shade300
    ..style = PaintingStyle.stroke;
    var path = Path();
    if (isLine == true) {
      path.moveTo(begin!.dx, begin!.dy);
      if (middle != null) {
      
        path.lineTo(middle!.dx, middle!.dy);
        // var segmentLength = 10.0;
        // var length = sqrt(pow(begin!.dx - end!.dx, 2) + pow(begin!.dy - end!.dy, 2));
        // var currentLength = 0.0;
        // var index = 0;
        // var beginPoint = begin;
        // var xPositive = end!.dx - begin!.dx > 0 ? true : false;
        // var yPositive = end!.dy - begin!.dy > 0 ? true : false;
        // var tanConst = 
        // while(currentLength < length){
        //   currentLength += segmentLength;
        //   var xLength = 
        //   if (index % 2 != 0) {
        //     continue;
        //   } else {
            
        //   }
        //   index += 1;
        // }
      }
      path.lineTo(end!.dx, end!.dy);
    } else if (controlPos.length == 2) {
      var controlPos1 = controlPos[0];
      var controlPos2 = controlPos[1];
      path.moveTo(begin!.dx, begin!.dy);
      path.quadraticBezierTo(controlPos1.dx, controlPos1.dy, middle!.dx, middle!.dy);
      path.quadraticBezierTo(controlPos2.dx, controlPos2.dy, end!.dx, end!.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}