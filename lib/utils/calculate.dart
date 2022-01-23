/*
 * @Author: Monte
 * @Date: 2022-01-23
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';

// 根据经过三个点，计算各两点之间的控制点
getControllerPoints(x0, y0, x1, y1, x2, y2, t) {
  var d01 = sqrt(pow(x1 - x0, 2) + pow(y1 - y0, 2));
  var d12 = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  var fa = t * d01 / (d01 + d12);
  var fb = t * d12 / (d01 + d12);
  var p1x = x1 - fa * (x2 - x0);
  var p1y = y1 - fa * (y2 - y0);
  var p2x = x1 + fb * (x2 - x0);
  var p2y = y1 + fb * (y2 - y0);
  return [Offset(p1x, p1y), Offset(p2x, p2y)];
}
