/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frisbee/common/events.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/utils/event_util.dart';
import 'package:frisbee/utils/request_util.dart';


class SubHomePage extends StatefulWidget {
  SubHomePage({Key? key, required this.icon, required this.header})
      : super(key: key);
  final IconData icon;
  final String header;

  @override
  State<StatefulWidget> createState() {
    return _SubHomePageState();
  }
}

class _SubHomePageState extends State<SubHomePage>
    with TickerProviderStateMixin {
  Future _getTeamData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var data = await ApiClient().get('/api/teams/$teamId');
      data['type'] = 'team';
      return data;
    }
  }

  Future _getUserStats() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var userId = Global.currentUser!.id;
      var data =
          await ApiClient().get('/api/teams/$teamId/users/$userId/statsgames');
      data['type'] = 'stat';
      return data;
    }
  }

  Future _getAllDatas() async {
    return Future.wait([_getTeamData(), _getUserStats()]);
  }

  var _getAllData;
  late AnimationController _animationController;
  late AnimationController _backAnimationController;
  @override
  void initState() {
    _getAllData = _getAllDatas();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _backAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    super.initState();
  }

  _createCircleIndicator(current, total) {
    var totalAngle = current / total * 1.6 * pi;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _backAnimationController,
          builder: (BuildContext context, Widget? child) {
            return GradientCircularProgressIndicator(
              // No gradient
              colors: [Colors.grey.shade300, Colors.grey.shade300],
              radius: 70.0,
              strokeWidth: 5.0,
              strokeCapRound: true,
              startAngle: -0.8 * pi,
              totalAngle: 1.6 * pi,
              value: _animationController.value, stops: [],
            );
          },
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) {
            return GradientCircularProgressIndicator(
              // No gradient
              colors: const [Colors.blue, Colors.blue],
              radius: 70.0,
              strokeWidth: 5.0,
              strokeCapRound: true,
              startAngle: -0.8 * pi,
              totalAngle: totalAngle,
              value: _animationController.value, stops: [],
            );
          },
        ),
      ],
    );
  }

  _buildWidgets(team, stat) {
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _backAnimationController.forward();
    });
    var total = stat['total'];
    var seen = stat['seen'];
    var unseen = total - seen;
    var adminCount = 0;
    var playerCount = 0;
    for (var player in team['users']) {
      var admin = player['admin'];
      if (admin != null && admin == true) {
        adminCount += 1;
      }
      playerCount += 1;
    }
    return Center(
      child: ListView(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 40),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _createCircleIndicator(seen, total),
                  Positioned(
                    top: 30.0,
                    child: Column(
                      children: [
                        Text(
                          "$total",
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "战术",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 17,
                        ),
                        TextButton(
                            onPressed: () {
                              BottomBarSelectIndexEvent event =
                                  BottomBarSelectIndexEvent(1);
                              EventBusUtil.fire(event);
                            },
                            child: Text('$unseen未看'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 30),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _createCircleIndicator(adminCount, playerCount),
                  Positioned(
                    top: 30.0,
                    child: Column(
                      children: [
                        Text(
                          "$playerCount",
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '队员',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$adminCount管理员',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                        ),
                        TextButton(
                            onPressed: () {
                              BottomBarSelectIndexEvent event =
                                  BottomBarSelectIndexEvent(2);
                              EventBusUtil.fire(event);
                            },
                            child: const Text('查看所有'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<dynamic>(
      future: _getAllData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 请求已结束
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 请求失败，显示错误
            return Text("Error: ${snapshot.error}");
          } else {
            var team, stat;
            for (var one in snapshot.data) {
              if (one['type'] == 'team') {
                team = one;
              } else {
                stat = one;
              }
            }
            return Container(
              child: Builder(
                builder: (BuildContext context) {
                  return _buildWidgets(team, stat);
                },
              ),
            );
            // 请求成功，显示数据
          }
        } else {
          // 请求未结束，显示loading
          return const CircularProgressIndicator();
        }
      },
    ));
  }
}

class GradientCircularProgressIndicator extends StatelessWidget {
  GradientCircularProgressIndicator(
      {this.strokeWidth = 2.0,
      required this.radius,
      required this.colors,
      required this.stops,
      this.strokeCapRound = false,
      this.backgroundColor = const Color(0xFFEEEEEE),
      this.totalAngle = 2 * pi,
      this.startAngle = 0.0,
      required this.value});

  ///粗细
  final double strokeWidth;

  /// 圆的半径
  final double radius;

  ///两端是否为圆角
  final bool strokeCapRound;

  /// 当前进度，取值范围 [0.0-1.0]
  final double value;

  /// 进度条背景色
  final Color backgroundColor;

  /// 进度条的总弧度，2*PI为整圆，小于2*PI则不是整圆
  final double totalAngle;

  /// 进度条的起始弧度，2*PI为整圆，小于2*PI则不是整圆
  final double startAngle;

  /// 渐变色数组
  final List<Color> colors;

  /// 渐变色的终止点，对应colors属性
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    double _offset = .0;
    // 如果两端为圆角，则需要对起始位置进行调整，否则圆角部分会偏离起始位置
    // 下面调整的角度的计算公式是通过数学几何知识得出，读者有兴趣可以研究一下为什么是这样
    if (strokeCapRound) {
      _offset = asin(strokeWidth / (radius * 2 - strokeWidth));
    }
    var _colors = colors;
    if (_colors == null) {
      Color color = Theme.of(context).accentColor;
      _colors = [color, color];
    }
    return Transform.rotate(
      angle: -pi / 2.0 - _offset,
      child: CustomPaint(
          size: Size.fromRadius(radius),
          painter: _GradientCircularProgressPainter(
            strokeWidth: strokeWidth,
            strokeCapRound: strokeCapRound,
            backgroundColor: backgroundColor,
            value: value,
            total: totalAngle,
            startAngle: startAngle,
            radius: radius,
            colors: _colors,
            stops: [],
          )),
    );
  }
}

//实现画笔
class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter(
      {this.strokeWidth = 10.0,
      this.startAngle = 0.0,
      this.strokeCapRound = false,
      this.backgroundColor = const Color(0xFFEEEEEE),
      required this.radius,
      this.total = 2 * pi,
      required this.colors,
      required this.stops,
      required this.value});

  final double strokeWidth;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final List<Color> colors;
  final double total;
  final double radius;
  final List<double> stops;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius != null) {
      size = Size.fromRadius(radius);
    }
    double _offset = strokeWidth / 2.0;
    double _value = (value);
    _value = _value.clamp(.0, 1.0) * total;
    double _start = startAngle;

    if (strokeCapRound) {
      _start = _start + asin(strokeWidth / (size.width - strokeWidth));
    }

    Rect rect = Offset(_offset, _offset) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    var paint = Paint()
      ..strokeCap = strokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;

    // 先画背景
    if (backgroundColor != Colors.transparent) {
      paint.color = backgroundColor;
      canvas.drawArc(rect, _start, total, false, paint);
    }
    // 再画前景，应用渐变
    if (_value > 0) {
      paint.shader = SweepGradient(
        startAngle: 0.0,
        endAngle: _value,
        colors: colors,
        // stops: stops,
      ).createShader(rect);

      canvas.drawArc(rect, _start, _value, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
