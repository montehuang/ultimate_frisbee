/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/pages/base_home_page.dart';
import 'package:frisbee/pages/login_page.dart';
import 'package:frisbee/utils/request_util.dart';

// 初始化一个闪屏页
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  final String splashImage = '';

  Future<void> _initData() async {
    await Global.initToken();
  }

  Future _autoLogin() async {
    var data = await ApiClient().get('/api/autologin');
    return data;
  }

  @override
  initState() {
    super.initState();
    _initData().then((value) => {
          if (Global.token.isEmpty)
            {_navigateToLoginPage()}
          else
            {
              _autoLogin().then((value) {
                if (value['success']) {
                  if (value['user']?['teams']?.length > 0 ) {
                    value['user']['teams'].sort((a, b){
                      DateTime aViewed = DateTime.parse(a['viewed']);
                      DateTime bViewd = DateTime.parse(b['viewed']);
                      return bViewd.compareTo(aViewed);
                    });
                  }
                  Global.initUserAndTeam(userData: value['user']).then((v) {
                    Global.currentTeam = Global.teams[0];
                      _navigateToHomePage();
                  });
                } else {
                  
                  _navigateToLoginPage();
                }
              })
            }
        });
  }

  _navigateToLoginPage() {
    // 登录界面
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const LoginPage(
                  title: "登录",
                )),
        // ignore: unnecessary_null_comparison
        (route) => route == null);
  }

  _navigateToHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const HomePage(
                  title: "极限飞盘",
                )),
        // ignore: unnecessary_null_comparison
        (route) => route == null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
