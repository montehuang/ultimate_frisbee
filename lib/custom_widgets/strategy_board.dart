/*
 * @Author: Monte
 * @Date: 2022-01-12
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';

class StrategyBoard extends StatelessWidget {
  StrategyBoard(
      {Key? key,
      required this.playerMap,
      required this.currentStepMap,
      required this.lastStepMap,
      required this.controller}) {
    key = key;
    for (var key in playerMap.keys) {
      for (var index in playerMap[key]) {
        var indexKey = key + index.toString();
        indexKeys.add(indexKey);
      }
    }
    for (var indexKey in indexKeys) {
      var lastX = lastStepMap[indexKey]['xend'] * width / 100 - 15.r;
      var lastY = lastStepMap[indexKey]['yend'] * height / 100 - 15.r;
      var currentX = currentStepMap[indexKey]['xend'] * width / 100 - 15.r;
      var currentY = currentStepMap[indexKey]['yend'] * height / 100 - 15.r;
      var leftAnimation = Tween(begin: lastX, end: currentX).animate(
          CurvedAnimation(parent: controller, curve: const Interval(0, 1)));
      var topAnimation = Tween(begin: lastY, end: currentY).animate(
          CurvedAnimation(parent: controller, curve: const Interval(0, 1)));
      leftAnimationMap[indexKey] = leftAnimation;
      topAnimationMap[indexKey] = topAnimation;
    }
  }
  var width = 330.r;
  var height = 600.r;
  Map playerMap;
  Map currentStepMap;
  Map lastStepMap;
  late Map<String, Animation> leftAnimationMap = {};
  late Map<String, Animation> topAnimationMap = {};
  Animation<double> controller;
  late List indexKeys = [];
  List animations = [];
  Widget _createItemWidgets(BuildContext context, Widget? child) {
    List<Widget> items = [];

    for (var key in indexKeys) {
      late Widget item;
      if (key.contains('a')) {
        item = Positioned(
            left: leftAnimationMap[key]?.value,
            top: topAnimationMap[key]?.value,
            child: FieldItemWidget(
              color: Colors.yellow,
              showText: key.substring(1),
            ));
      } else if (key.contains('b')) {
        item = Positioned(
            left: leftAnimationMap[key]?.value,
            top: topAnimationMap[key]?.value,
            child: FieldItemWidget(
              color: Colors.grey,
              showText: key.substring(1),
            ));
      } else if (key.contains('x')) {
        item = Positioned(
            left: leftAnimationMap[key]?.value,
            top: topAnimationMap[key]?.value,
            child: FieldItemWidget(
              color: Colors.red,
              showText: key.substring(1),
            ));
      }
      items.add(item);
    }
    // print(steps[0]);
    return Stack(
      clipBehavior: Clip.none,
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: AnimatedBuilder(
            builder: _createItemWidgets,
            animation: controller,
          ));
    });
  }
}
