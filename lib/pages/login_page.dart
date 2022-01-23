/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:frisbee/pages/base_home_page.dart';

class LoginPage extends StatefulWidget {
  final String title;

  const LoginPage({Key? key, required this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey _globalKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _userPwd = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          autovalidateMode: AutovalidateMode.always, key: _globalKey, //自动校验
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _userName,
                decoration: const InputDecoration(
                    labelText: "邮箱",
                    hintText: "输入你的邮箱",
                    icon: Icon(Icons.person)),
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : "邮箱不能为空";
                },
              ),
              TextFormField(
                controller: _userPwd,
                decoration: const InputDecoration(
                  labelText: "密码",
                  hintText: "输入你的密码",
                  icon: Icon(Icons.lock),
                ),
                validator: (v) {
                  return v!.trim().length > 5 ? null : "密码不低于6位";
                },
                obscureText: true,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
              SizedBox(
                width: 120.0,
                height: 50.0,
                // ignore: deprecated_member_use
                child: RaisedButton(
                  onPressed: () {
                    if ((_globalKey.currentState as FormState).validate()) {
                      _login();
                    }
                  },
                  child: const Text(
                    "登录",
                    style: TextStyle(color: Colors.white), //字体白色
                  ),
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _changeUserInfo(Map? responseData) {
    var showStr = '';
    bool success = false;
    if (responseData!.isNotEmpty) {
      var userData = responseData['data'];
      Global.initToken(newToken:responseData['token']);
      Global.initUserAndTeam(userData: userData);
      showStr = "登录成功 \n";
      success = true;
    } else {
      showStr = "登录失败 \n 账号或密码错误";
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(showStr),
          );
        });
    return success;
  }

  void _login() async {
    var postBody = {"email": _userName.text, "password": _userPwd.text};
    var data = await ApiClient().post('api/signup', postBody);
    var success = _changeUserInfo(data);
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const HomePage(
                    title: "极限飞盘",
                  )),
          // ignore: unnecessary_null_comparison
          (route) => route == null);
    }
  }
}
