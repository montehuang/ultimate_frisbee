/*
 * @Author: Monte
 * @Date: 2022-01-23
 * @Description: 
 */
import 'dart:math';

import 'package:flutter/material.dart';

class CurvePaintData {
  CurvePaintData({this.beginPoint, this.controlPoints, this.middlePoint, this.endPoint, this.isLine, this.size});
  Size? size;
  late Offset? beginPoint;
  late List<Offset>? controlPoints;
  late Offset? middlePoint;
  late Offset? endPoint;
  late bool? isLine;
}
class CurvePainter extends CustomPainter {
  CurvePainter(
      {required this.curveData});
  CurvePaintData curveData;


  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
    ..strokeWidth = 1
    ..color = Colors.grey.shade300
    ..style = PaintingStyle.stroke;
    var path = Path();
    if (curveData.isLine == true) {
      path.moveTo(curveData.beginPoint!.dx, curveData.beginPoint!.dy);
      if (curveData.middlePoint != null) {
      
        path.lineTo(curveData.middlePoint!.dx, curveData.middlePoint!.dy);
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
      path.lineTo(curveData.endPoint!.dx, curveData.endPoint!.dy);
    } else if (curveData.controlPoints!.length == 2) {
      var controlPos1 = curveData.controlPoints![0];
      var controlPos2 = curveData.controlPoints![1];
      path.moveTo(curveData.beginPoint!.dx, curveData.beginPoint!.dy);
      path.quadraticBezierTo(controlPos1.dx, controlPos1.dy, curveData.middlePoint!.dx, curveData.middlePoint!.dy);
      path.quadraticBezierTo(controlPos2.dx, controlPos2.dy, curveData.endPoint!.dx, curveData.endPoint!.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}