/*
 * @Author: Monte
 * @Date: 2022-01-23
 * @Description: 
 */
import 'package:flutter/material.dart';

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