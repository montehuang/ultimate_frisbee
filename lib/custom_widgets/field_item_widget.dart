/*
 * @Author: Monte
 * @Date: 2022-01-09
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ItemShape {
  Circle,
  Triangle,
}

class FieldItemWidget extends StatefulWidget {
  FieldItemWidget(
      {Key? key,
      this.shape = ItemShape.Circle,
      this.showText = '',
      this.isSelected = false,
      this.posX = 0,
      this.posY = 0,
      this.color = Colors.white})
      : super(key: key);
  ItemShape shape;
  String showText;
  bool isSelected;
  double posX;
  double posY;
  Color color;

  @override
  State<StatefulWidget> createState() {
    return _FieldItemWidgetState();
  }
}

class _FieldItemWidgetState extends State<FieldItemWidget> {
  Widget _createShapeWidget() {
    var sizeNum = 30.r;
    return Container(
      child: Builder(builder: (context) {
        List<Widget> widgets = [];
        Widget showWidget = CustomeShapeWidget(
          shape: widget.shape,
          style: PaintingStyle.fill,
          child: SizedBox(
            width: sizeNum,
            height: sizeNum,
            child: Center(child: Text(widget.showText),) ,
          ),
          color: widget.color,
        );
        widgets.add(showWidget);
        if (widget.isSelected) {
          Widget selectWidget = CustomeShapeWidget(
            shape: widget.shape,
            style: PaintingStyle.stroke,
            child: SizedBox(
              width: sizeNum,
              height: sizeNum,
            ),
            color: Colors.lightGreen.shade200,
          );
          widgets.add(selectWidget);
        }
        

        return Stack(
          children: widgets,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shape == ItemShape.Circle ||
        widget.shape == ItemShape.Triangle) {
      return _createShapeWidget();
    } else {
      return const Text('widget item wrong shaope');
    }
  }
}

class CustomeShapeWidget extends StatelessWidget {
  CustomeShapeWidget(
      {color = Colors.white,
      this.child,
      style = PaintingStyle.fill,
      shape = ItemShape.Circle})
      : painter = DrawCustomeShape(color: color, style: style, shape: shape);
  Widget? child;
  DrawCustomeShape painter;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: painter, child: child);
  }
}

class DrawCustomeShape extends CustomPainter {
  Color color;
  PaintingStyle style;
  late Paint painter;
  ItemShape shape;
  DrawCustomeShape(
      {this.color = Colors.white,
      this.style = PaintingStyle.fill,
      this.shape = ItemShape.Circle}) {
    painter = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = style;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (shape == ItemShape.Triangle) {
      var path = Path();
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo( size.width , size.height);
      path.close();
      canvas.drawPath(path, painter);
    } else if (shape == ItemShape.Circle) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), size.height / 2, painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
