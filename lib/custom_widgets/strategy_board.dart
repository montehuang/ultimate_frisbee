/*
 * @Author: Monte
 * @Date: 2022-01-12
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';

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
      } else if (currentStepMap[indexKey]['mode'] == 'cut' ||
          currentStepMap[indexKey]['mode'] == 'curve') {
        var leftAnimation = TweenSequence([
          TweenSequenceItem(
              tween: Tween(begin: startX, end: midX),
              weight: (midX - startX).abs()),
          TweenSequenceItem(
              tween: Tween(begin: midX, end: endX),
              weight: (endX - midX).abs()),
        ]).animate(controller);
        var topAnimation = TweenSequence([
          TweenSequenceItem(
              tween: Tween(begin: startY, end: midY),
              weight: (midY - startY).abs()),
          TweenSequenceItem(
              tween: Tween(begin: midY, end: endY),
              weight: (endY - midY).abs()),
        ]).animate(controller);
        leftAnimationMap[indexKey] = leftAnimation;
        topAnimationMap[indexKey] = topAnimation;
      }
    }
  }
  var width = 330.r;
  var height = 600.r;
  Map playerMap;
  Map currentStepMap;
  int stepIndex;
  Map cort;
  Map<String, CatmullRomCurve> catmullRomPathMap = {};
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
