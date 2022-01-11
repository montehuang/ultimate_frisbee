/*
 * @Author: Monte
 * @Date: 2022-01-12
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';

class StrategyBoard extends StatefulWidget {
  StrategyBoard({Key? key, required this.data}) : super(key: key);
  Map data;

  @override
  State<StatefulWidget> createState() {
    return _StrategyBoardState();
  }
}

Widget _createItemWidgets(steps, players) {
  List<Widget> items = [];

  var keys = [];
  for (var key in players.keys) {
    for (var index in players[key]) {
      var indexKey = key + index.toString();
      keys.add(indexKey);
    }
  }
  for (var key in keys) {
    var width = 330.r;
    var height = 550.r;
    var x = steps[0][key]['xend'] * width / 100;
    var y = steps[0][key]['yend'] * height / 100;
    late Widget item;
    if (key.contains('a')) {
      item = Positioned(
          left: x,
          top: y,
          child: FieldItemWidget(
            color: Colors.yellow,
            showText: key.substring(1),
          ));
    } else if (key.contains('b')) {
      item = Positioned(
          left: x,
          top: y,
          child: FieldItemWidget(
            color: Colors.grey,
            showText: key.substring(1),
          ));
    } else if (key.contains('x')) {
      item = Positioned(
          left: x,
          top: y,
          child: FieldItemWidget(
            color: Colors.red,
            showText: key.substring(1),
          ));
    }
    items.add(item);
  }
  // print(steps[0]);
  return Stack(children: items);
}

class _StrategyBoardState extends State<StrategyBoard>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var width = 330.r;
    var height = 650.r;
    return Builder(builder: (context) {
      return Container(
          width: width,
          height: height,
          color: Colors.blue,
          child:
              _createItemWidgets(widget.data['steps'], widget.data['players']));
    });
  }
}
