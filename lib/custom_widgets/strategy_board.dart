/*
 * @Author: Monte
 * @Date: 2022-01-12
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/animations/custom_animation.dart';
import 'package:frisbee/custom_widgets/custom_painter.dart';
import 'package:frisbee/custom_widgets/draw_line.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';
import 'package:frisbee/utils/calculate.dart';

class StrategyBoard extends StatelessWidget {
  StrategyBoard(
      {Key? key,
      this.filedItemSizeNum,
      required this.cort,
      required this.playerMap,
      required this.currentStepMap,
      required this.stepIndex,
      required this.controller,
      required this.showLines}) {
    key = key;
    filedItemSizeNum ??= 26.r;
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
      var midX = currentStepMap[indexKey][xmid] * width / 100 - filedItemSizeNum! / 2;
      var midY = currentStepMap[indexKey][ymid] * height / 100 - filedItemSizeNum! / 2;
      var endX = currentStepMap[indexKey][xend] * width / 100 - filedItemSizeNum! / 2;
      var endY = currentStepMap[indexKey][yend] * height / 100 - filedItemSizeNum! / 2;
      var startX = 0.0;
      var startY = 0.0;
      if (stepIndex == 0) {
        startX = endX;
        startY = endY;
      } else {
        startX = currentStepMap[indexKey][xtart] * width / 100 - filedItemSizeNum! / 2;
        startY = currentStepMap[indexKey][ystart] * height / 100 - filedItemSizeNum! / 2;
      }
      var beginPoint = Offset(startX + filedItemSizeNum! / 2, startY + filedItemSizeNum! / 2);
      var endPoint = Offset(endX + filedItemSizeNum! / 2, endY + filedItemSizeNum! / 2);
      pointMap[indexKey] = {"beginPoint": beginPoint, 'endPoint': endPoint};
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
        var middlePoint = Offset(midX + filedItemSizeNum! / 2, midY + filedItemSizeNum! / 2);
        pointMap[indexKey]?['middlePoint'] = middlePoint;
      } else if (currentStepMap[indexKey]['mode'] == 'curve') {
        var beginOffset = Offset(startX, startY);
        var middleOffset = Offset(midX, midY);
        var endOffset = Offset(endX, endY);
        var firstWeight = sqrt(pow(midX - startX, 2) + pow(midY - startY, 2));
        var secondWeight = sqrt(pow(endX - midX, 2) + pow(endY - midY, 2));
        var result =
            getControllerPoints(startX, startY, midX, midY, endX, endY, 0.5);
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
        var middlePoint = Offset(midX + filedItemSizeNum! / 2, midY + filedItemSizeNum! / 2);
        pointMap[indexKey]?['middlePoint'] = middlePoint;
        List<Offset> controlPoints = [];
        for (Offset point in result) {
          controlPoints.add(Offset(point.dx + filedItemSizeNum! / 2, point.dy + filedItemSizeNum! / 2));
        }
        pointMap[indexKey]?['controlPoints'] = controlPoints;
      }
    }
  }
  var width = 330.r;
  var height = 600.r;
  Map playerMap;
  double? filedItemSizeNum;
  Map currentStepMap;
  late List allPoints = [];
  List<Offset?>? controlPoints;
  late Map<String, Map> pointMap = {};
  int stepIndex;
  Map cort;
  bool showLines = false;
  late Map<String, Animation> curveAnimationMap = {};
  late Map<String, Animation> leftAnimationMap = {};
  late Map<String, Animation> topAnimationMap = {};
  Animation<double> controller;
  late List indexKeys = [];
  List animations = [];
  Widget _createItemWidgets(BuildContext context, Widget? child) {
    List<Widget> items = [];
    if (showLines) {
      for (var key in indexKeys) {
        var pointInfo = pointMap[key];
        if (pointInfo != null) {
          var controlPoints = pointInfo['controlPoints'] ?? <Offset>[];
          var beginPoint = pointInfo['beginPoint'];
          var endPoint = pointInfo['endPoint'];
          var middlePoint = pointInfo['middlePoint'];
          var isLine = true;
          if (!controlPoints.isEmpty) {
            isLine = false;
          }
          Widget line = CustomPaint(
              size: Size(width, height),
              painter: CurvePainter(
                  begin: beginPoint,
                  controlPos: controlPoints,
                  middle: middlePoint,
                  end: endPoint,
                  isLine: isLine));
          items.add(line);
          Widget item = _fieldItemWidget(key, beginPoint.dx - 1.5.r, beginPoint.dy - 1.5.r, '', 3.r);
          items.add(item);
        }
      }
    }

    for (var key in indexKeys) {
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
      Widget item = _fieldItemWidget(key, leftValue, topVaule, key.substring(1), filedItemSizeNum);
      items.add(item);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: items,
    );
  }
  Widget _createOneItemWidget(leftValue, topVaule, showText, sizeNum, color, shape, bool isShowBorder, textColor) {
    Widget widget = Positioned(
          left: leftValue,
          top: topVaule,
          child: FieldItemWidget(
            color: color,
            border: isShowBorder ? FieldItemBorder():null,
            showText: showText ?? '',
            sizeNum: sizeNum,
            shape: shape,
            textColor: textColor,
          ));
          return widget;
  }

  Widget _fieldItemWidget(key, leftValue, topVaule, showText, sizeNum) {
    Widget item;
    if (key.contains('a')) {
      item = _createOneItemWidget(leftValue, topVaule, showText, sizeNum, Colors.green.shade400, null, false, null);
    } else if (key.contains('b')) {
      item = _createOneItemWidget(leftValue, topVaule, showText, sizeNum, Colors.grey, null, false, null);
    } else if (key.contains('x')) {
      item = _createOneItemWidget(leftValue, topVaule, showText, sizeNum, Colors.white, null, true, Colors.grey);
    } else if (key.contains('y')) {
      item = _createOneItemWidget(leftValue, topVaule, '', sizeNum, Colors.orange, ItemShape.Triangle, false, null);
    } else {
      item = Container();
    }
    return item;
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
