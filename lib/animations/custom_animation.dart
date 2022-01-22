/*
 * @Author: Monte
 * @Date: 2022-01-22
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';
class BezierTween extends Tween<Offset?> {
  Offset? middle;
  BezierTween({ Offset? begin, Offset? end, this.middle }) : super(begin: begin, end: end);

  @override
  Offset? lerp(double t){
    var x = pow(1-t, 2) * begin!.dx + 2 * t * (1-t) * middle!.dx + pow(t, 2) * end!.dx;
    var y = pow(1-t, 2) * begin!.dy + 2 * t * (1-t) * middle!.dy + pow(t, 2) * end!.dy;
    return Offset(x, y);
  }
}