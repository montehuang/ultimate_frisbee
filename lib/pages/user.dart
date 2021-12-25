/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */

import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frisbee/pages/login_page.dart';
import 'package:frisbee/utils/request_util.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  void initState() {
    super.initState();
  }


  void _loginout() async {
    var _ = await ApiClient().getNoData('api/logout');
    Global.clearUser();
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
                              child: Global.currentUser?.picture == ''
                                  ? SvgPicture.asset("assets/player.svg")
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        Global.currentUser?.picture ?? '',
                                      ),
                                      radius: 60,
                                    )),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(Global.currentUser?.name ?? '')
                        ],
                      ),
                    );
                  }),
              // padding: const EdgeInsets.only(right: 10, bottom: 50),
            ),
            ListTile(
              title: const Text('我的数据'),
              onTap: () {
                if (Global.currentUser != null) {
                  Navigator.pop(context);
                  // ApiClient().get('/api/autologin', _changeUserInfo);
                  // 获取自己的数据
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
                _loginout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) =>  const LoginPage(title: "登录",)),
                  // ignore: unnecessary_null_comparison
                  (route) => route == null);
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
