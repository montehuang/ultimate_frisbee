/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:frisbee/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frisbee/utils/db_utils.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

User? user = User();
List<Team> teams = [];
var dbClient = const DbClient();

class _UserDrawerState extends State<UserDrawer> {
  @override
  void initState() {
    super.initState();
    _initUser();
  }

  dynamic _getUser() async {
    var key = 'user';
    var userData = await dbClient.get(key, DataType.tMap);
    if (userData != null) {
      user = User(data: userData);
    } 
    return user;
  }

  Future<dynamic> _initUser() async {
    return Future.sync(() => _getUser());
  }

  void _changeUserInfo(data) async {
    Map<String, dynamic> userData = data['user'];
    user = User(data: userData);
    for (var teamData in userData['teams']) {
      teams.add(Team(data: teamData));
    }
    await dbClient.write('user', user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ColoredBox(
        color: Colors.blue,
        child: ListView(
          children: [
            DrawerHeader(
              child: FutureBuilder(
                  future: _initUser(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return SizedBox(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                              width: 50,
                              height: 50,
                              child: user?.picture == ''
                                  ? SvgPicture.asset("assets/player.svg")
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        user?.picture ?? '',
                                      ),
                                      radius: 60,
                                    )),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(user?.name ?? '')
                        ],
                      ),
                    );
                  }),
              // padding: const EdgeInsets.only(right: 10, bottom: 50),
            ),
            ListTile(
              title: const Text('我的数据'),
              onTap: () {
                if (user?.picture.toString() == null) {
                  ApiClient().get('/api/autologin', _changeUserInfo);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: const Text('账号'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('登出'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
