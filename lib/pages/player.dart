/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:frisbee/pages/user_statistics.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key, required this.icon, required this.header})
      : super(key: key);
  final IconData icon;
  final String header;

  @override
  State<StatefulWidget> createState() {
    return _PlayerPageState();
  }
}

class _PlayerPageState extends State<PlayerPage> {
  _getTeamData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var data = await ApiClient().get('/api/teams/$teamId');
      return data;
    }
  }

  _getUserStats(user) async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var userId = user['id'];
      var data =
          await ApiClient().get('/api/teams/$teamId/users/$userId/statsgames');
      return data;
    }
  }

  _processData(user) async {
    var statsData = await _getUserStats(user);
    if (statsData != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserStatsPage(
                statsData: statsData,
              )));
    }
  }

  Widget _buildUserWidgets(List users) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var user in users) {
      List<Widget> infoWidgets = [];
      if (user['name'] != null) {
        infoWidgets.add(Text(user['name']));
      }
      if (user['number'] != null) {
        infoWidgets.add(Text(user['number']));
      }
      if (user['email'] != null) {
        infoWidgets.add(Text(user['email']));
      }
      List<Widget> statusWidgets = [];
      if (user['owner'] != null && user['owner']) {
        statusWidgets.add(const Card(
          color: Colors.green,
          child: Text('拥有者'),
        ));
      } else if (user['admin'] != null && user['admin']) {
        statusWidgets.add(const Card(
          color: Colors.green,
          child: Text('管理员'),
        ));
      }
      statusWidgets.add(const Card(
        child: Text(' ... '),
      ));
      var showCard = GestureDetector(
        onTap: () {
          _processData(user);
        },
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
            child: Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                    width: 50,
                    height: 50,
                    child: user['picture'] == null
                        ? SvgPicture.asset("assets/player.svg")
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                              user['picture'] ?? '',
                            ),
                            radius: 60,
                          )),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: infoWidgets,
                ),
                const Spacer(),
                Container(child: Row(
                  children: statusWidgets,
                ), transform: Matrix4.translationValues(0, -20, 0),)
                
              ],
            ),
          ),
        ),
      );
      tiles.add(showCard);
    }
    content = ListView(
      children: tiles,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<dynamic>(
      future: _getTeamData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 请求已结束
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 请求失败，显示错误
            return Text("Error: ${snapshot.error}");
          } else {
            var data = snapshot.data;
            var name = data['name'];
            var users = data['users'];
            var invite = data['invite'];
            return Column(
              children: [
                Text(
                  "$name",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                ),
                Card(
                  color: Colors.white70,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'https://www.ultiplays.com/invite/$invite',
                          style: const TextStyle(fontSize: 13),
                        ),
                        TextButton(
                            onPressed: () {
                              print('复制');
                            },
                            child: const Text('复制分享')),
                        const SizedBox(
                          height: 2,
                        ),
                        const Text(
                          'Share this invite with your team to let them see all plays.\nPeople following this link will have a profile created and join the team automatically.',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      return _buildUserWidgets(users);
                    },
                  ),
                )
              ],
            );
            // 请求成功，显示数据
          }
        } else {
          // 请求未结束，显示loading
          return CircularProgressIndicator();
        }
      },
    ));
  }
}
