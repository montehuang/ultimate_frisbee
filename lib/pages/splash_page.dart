/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/pages/base_home_page.dart';
import 'package:frisbee/pages/login_page.dart';

// 初始化一个闪屏页
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  final String splashImage = '';

  Future<void> _initData() async {
    await Global.initUserAndTeam();
    await Global.initToken();
  }

  @override
  initState() {
    super.initState();
    _initData().then((value) => {
          if (Global.token.isEmpty)
            {
              // 登录界面
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const LoginPage(
                            title: "登录",
                          )),
                  // ignore: unnecessary_null_comparison
                  (route) => route == null)
            }
          else
            {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const HomePage(
                            title: "极限飞盘",
                          )),
                  // ignore: unnecessary_null_comparison
                  (route) => route == null)
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
