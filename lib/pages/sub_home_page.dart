/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frisbee/common/events.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/custom_widgets/gradient_circular_progress.dart';
import 'package:frisbee/utils/event_util.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:flutter_svg/svg.dart';

class SubHomePage extends StatefulWidget {
  const SubHomePage({Key? key, required this.teamId})
      : super(key: key);
  final String teamId;

  @override
  State<StatefulWidget> createState() {
    return _SubHomePageState();
  }
}

class _SubHomePageState extends State<SubHomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Future _getTeamData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = widget.teamId;
      var data = await ApiClient().get('/api/teams/$teamId');
      data['type'] = 'team';
      return data;
    }
  }

  Future _getMessageData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = widget.teamId;
      var params = {'limit': '5', 'sort': 'desc'};
      var data =
          await ApiClient().get('/api/teams/$teamId/messages', params: params);
      return data;
    }
  }

  Future _getUserStats() async {
    if (Global.teams.isNotEmpty) {
      var teamId = widget.teamId;
      var userId = Global.currentUser!.id;
      var data =
          await ApiClient().get('/api/teams/$teamId/users/$userId/statsgames');
      data['type'] = 'stat';
      return data;
    }
  }

  Future _getAllDatas() async {
    return Future.wait([_getTeamData(), _getUserStats(), _getMessageData()]);
  }

  late AnimationController _animationController;
  late AnimationController _backAnimationController;
  Timer? _delayTimer;
  @override
  void initState() {
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

  List<Widget> _buildMessages(messages) {
    List<Widget> list = [];
    //i<5, pass your dynamic limit as per your requirment
    for (var message in messages) {
      var messageRow = Row(
        children: [
          message['userPicture'] == null
              ? SvgPicture.asset(
                  "assets/player.svg",
                  width: 20,
                )
              : CircleAvatar(
                  backgroundImage: NetworkImage(
                    message['userPicture'],
                  ),
                  radius: 10,
                ),
          const SizedBox(
            width: 5,
          ),
          Text(
            message['userName'],
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              message['text'],
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ],
      );
      list.add(messageRow);
    }
    return list;
  }

  _buildWidgets(team, stat, messages) {
    if (team == null || stat == null || messages == null) {
      return Center(child: const Text('获取数据错误'));
    }
    _animationController.forward();
    _delayTimer = Timer(Duration(milliseconds: 1000), () {
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
        shrinkWrap: true,
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
          Card(
              child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            height: 130,
            child: Column(
              children: _buildMessages(messages),
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
        child: FutureBuilder<dynamic>(
      future: _getAllDatas(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 请求已结束
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 请求失败，显示错误
            return Text("Error: ${snapshot.error}");
          } else {
            var team, stat, messages;
            for (var one in snapshot.data) {
              if (one == null) {
                break;
              }
              if (one is List) {
                messages = one;
              } else if (one['type'] == 'team') {
                team = one;
              } else {
                stat = one;
              }
            }
            return Container(
              child: Builder(
                builder: (BuildContext context) {
                  return _buildWidgets(team, stat, messages);
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

  @override
  void dispose() {
    _animationController.dispose();
    _backAnimationController.dispose();
    if (_delayTimer != null) {
      _delayTimer!.cancel();
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
