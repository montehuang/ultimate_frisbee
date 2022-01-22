/*
 * @Author: Monte
 * @Date: 2022-01-12
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/animations/custom_animation.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';

_getControllerPoints(x0, y0, x1, y1, x2, y2, t) {
  // var d01=Math.sqrt(Math.pow(x1-x0,2)+Math.pow(y1-y0,2));
  //   var d12=Math.sqrt(Math.pow(x2-x1,2)+Math.pow(y2-y1,2));
  //   var fa=t*d01/(d01+d12);   // scaling factor for triangle Ta
  //   var fb=t*d12/(d01+d12);   // ditto for Tb, simplifies to fb=t-fa
  //   var p1x=x1-fa*(x2-x0);    // x2-x0 is the width of triangle T
  //   var p1y=y1-fa*(y2-y0);    // y2-y0 is the height of T
  //   var p2x=x1+fb*(x2-x0);
  //   var p2y=y1+fb*(y2-y0);
  //   return [p1x,p1y,p2x,p2y];
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

class FieldCustomSeparator extends StatelessWidget {
  final double height;
  final Color color;
  final bool isLine;

  const FieldCustomSeparator(
      {this.height = 1, this.color = Colors.black, this.isLine = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = isLine ? boxWidth : 10.0;
        final dashHeight = height;
        final dashCount = isLine ? 1 : (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

class CurvePainter1 extends CustomPainter {
  CurvePainter1(
      {required this.begin,
      required this.controlPos1,
      required this.controlPos2,
      required this.end});
  Offset begin;
  Offset controlPos1;
  Offset controlPos2;
  Offset end;

  ///实际的绘画发生在这里
  @override
  void paint(Canvas canvas, Size size) {
    ///创建画笔
    var paint = Paint();

    ///设置画笔的颜色
    paint.color = Colors.blue;

    ///创建路径
    var path = Path();

    ///A点 设置初始绘制点
    path.moveTo(begin.dx, begin.dy);

    /// 绘制到 B点（100，0）
    path.cubicTo(controlPos1.dx, controlPos1.dy, controlPos2.dx, controlPos2.dy,
        end.dx, end.dy);

    ///绘制 Path
    canvas.drawPath(path, paint);
  }

  ///你的绘画依赖于一个变量并且该变量发生了变化，那么你在这里返回true，
  ///这样Flutter就知道它必须调用paint方法来重绘你的绘画。否则，在此处返回false表示您不需要重绘
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class StrategyBoard extends StatelessWidget {
  StrategyBoard(
      {Key? key,
      required this.cort,
      required this.playerMap,
      required this.currentStepMap,
      required this.stepIndex,
      required this.controller}) {
    key = key;
    for (var key in playerMap.keys) {
      for (var index in playerMap[key]) {
        var indexKey = key + index.toString();
        indexKeys.add(indexKey);
      }
    }
    for (var indexKey in indexKeys) {
      var xtart = cort['width'] > cort['height'] ? 'ystart' : 'xstart';
      var xend = cort['width'] > cort['height'] ? 'yend' : 'xend';
      var ystart = cort['width'] > cort['height'] ? 'xstart' : 'ystart';
      var yend = cort['width'] > cort['height'] ? 'xend' : 'yend';
      var xmid = cort['width'] > cort['height'] ? 'ymid' : 'xmid';
      var ymid = cort['width'] > cort['height'] ? 'xmid' : 'ymid';
      var midX = currentStepMap[indexKey][xmid] * width / 100 - 15.r;
      var midY = currentStepMap[indexKey][ymid] * height / 100 - 15.r;
      var endX = currentStepMap[indexKey][xend] * width / 100 - 15.r;
      var endY = currentStepMap[indexKey][yend] * height / 100 - 15.r;
      var startX = 0.0;
      var startY = 0.0;
      if (stepIndex == 0) {
        startX = endX;
        startY = endY;
      } else {
        startX = currentStepMap[indexKey][xtart] * width / 100 - 15.r;
        startY = currentStepMap[indexKey][ystart] * height / 100 - 15.r;
      }

      if (currentStepMap[indexKey]['mode'] == 'line') {
        var leftAnimation = Tween(begin: startX, end: endX).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0, 1)));
        var topAnimation = Tween(begin: startY, end: endY).animate(
            CurvedAnimation(parent: controller, curve: const Interval(0, 1)));
        leftAnimationMap[indexKey] = leftAnimation;
        topAnimationMap[indexKey] = topAnimation;
      } else if (currentStepMap[indexKey]['mode'] == 'cut') {
        var firstWeight = sqrt(pow(midX - startX, 2) + pow(midY - startY, 2));
        var secondWeight = sqrt(pow(endX - midX, 2) + pow(endY - midY, 2));
        var leftAnimation = TweenSequence([
          TweenSequenceItem(
            tween: Tween(begin: startX, end: midX),
            weight: firstWeight,
          ),
          TweenSequenceItem(
            tween: Tween(begin: midX, end: endX),
            weight: secondWeight,
          )
        ]).animate(controller);
        var topAnimation = TweenSequence([
          TweenSequenceItem(
            tween: Tween(begin: startY, end: midY),
            weight: firstWeight,
          ),
          TweenSequenceItem(
            tween: Tween(begin: midY, end: endY),
            weight: secondWeight,
          )
        ]).animate(controller);
        leftAnimationMap[indexKey] = leftAnimation;
        topAnimationMap[indexKey] = topAnimation;
      } else if (currentStepMap[indexKey]['mode'] == 'curve') {
        var beginOffset = Offset(startX, startY);
        var middleOffset = Offset(midX, midY);
        var endOffset = Offset(endX, endY);
        var firstWeight = sqrt(pow(midX - startX, 2) + pow(midY - startY, 2));
        var secondWeight = sqrt(pow(endX - midX, 2) + pow(endY - midY, 2));
        var result =
            _getControllerPoints(startX, startY, midX, midY, endX, endY, 0.5);
        var curveAnimation = TweenSequence([
          TweenSequenceItem(
            tween: BezierTween(
                begin: beginOffset, end: middleOffset, middle: result[0]),
            weight: firstWeight,
          ),
          TweenSequenceItem(
            tween: BezierTween(
                begin: middleOffset, end: endOffset, middle: result[1]),
            weight: secondWeight,
          )
        ]).animate(controller);
        curveAnimationMap[indexKey] = curveAnimation;
        middleP = Offset(midX, midY);
      }
    }
  }
  var width = 330.r;
  var height = 600.r;
  Map playerMap;
  Map currentStepMap;
  late List allPoints = [];
  Offset? middleP;
  int stepIndex;
  Map cort;
  late Map<String, Animation> curveAnimationMap = {};
  late Map<String, Animation> leftAnimationMap = {};
  late Map<String, Animation> topAnimationMap = {};
  Animation<double> controller;
  late List indexKeys = [];
  List animations = [];
  Widget _createItemWidgets(BuildContext context, Widget? child) {
    List<Widget> items = [];
    for (var key in indexKeys) {
      late Widget item;
      var leftValue = leftAnimationMap[key]?.value;
      var topVaule = topAnimationMap[key]?.value;
      if (curveAnimationMap[key] != null) {
        var curveAnimationValue = curveAnimationMap[key]?.value;
        leftValue = curveAnimationValue.dx;
        topVaule = curveAnimationValue.dy;
      } else {
        leftValue = leftAnimationMap[key]?.value;
        topVaule = topAnimationMap[key]?.value;
      }

      if (key.contains('a')) {
        item = Positioned(
            left: leftValue,
            top: topVaule,
            child: FieldItemWidget(
              color: Colors.green.shade400,
              showText: key.substring(1),
            ));
      } else if (key.contains('b')) {
        item = Positioned(
            left: leftValue,
            top: topVaule,
            child: FieldItemWidget(
              color: Colors.grey,
              showText: key.substring(1),
            ));
      } else if (key.contains('x')) {
        item = Positioned(
            left: leftValue,
            top: topVaule,
            child: FieldItemWidget(
              color: Colors.white,
              border: FieldItemBorder(),
              showText: key.substring(1),
              textColor: Colors.grey,
            ));
      } else if (key.contains('y')) {
        item = Positioned(
            left: leftValue,
            top: topVaule,
            child: FieldItemWidget(
              color: Colors.orange,
              shape: ItemShape.Triangle,
            ));
      }
      items.add(item);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: items,
    );
  }

  List<Widget> _createAllFieldItems() {
    List<Widget> allWidgets = [];
    var scale = cort['height'] / cort['width'];
    if (scale == 333 / 900 || scale == 900 / 333) {
      allWidgets.add(
        Positioned(
          child: const FieldCustomSeparator(
            color: Colors.grey,
            isLine: true,
          ),
          top: height * 1 / 4,
          width: width,
        ),
      );
      allWidgets.add(
        Positioned(
          child: const FieldCustomSeparator(color: Colors.grey),
          top: height * 1 / 2,
          width: width,
        ),
      );
      allWidgets.add(
        Positioned(
          child: const FieldCustomSeparator(
            color: Colors.grey,
            isLine: true,
          ),
          top: height * 3 / 4,
          width: width,
        ),
      );
    } else if (scale == 554 / 333) {
      allWidgets.add(Positioned(
        child: const FieldCustomSeparator(color: Colors.grey),
        top: height * 5 / 6,
        width: width,
      ));
      allWidgets.add(Positioned(
        child: const FieldCustomSeparator(
          color: Colors.grey,
          isLine: true,
        ),
        top: height * 2 / 5,
        width: width,
      ));
    }
    allWidgets.add(AnimatedBuilder(
      builder: _createItemWidgets,
      animation: controller,
    ));
    if (middleP != null) {
      allWidgets.add(Positioned(
        child: Container(
          color: Colors.red,
          width: 5,
          height: 5,
        ),
        left: middleP!.dx,
        top: middleP!.dy,
      ));
    }

    return allWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Stack(
            children: _createAllFieldItems(),
          ));
    });
  }
}
