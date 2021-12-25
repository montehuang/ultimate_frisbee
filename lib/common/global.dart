/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */

import 'package:frisbee/models/user.dart';
import 'package:frisbee/utils/db_utils.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/services.dart';

class Global {
  static User? currentUser = User();
  static List<Team?> teams = [];
  static DbClient dbClient = const DbClient();
  static String? token = '';
  static String userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36';

  static dynamic _initUserAgentAsync() async {
    await FkUserAgent.init();
    try {
      userAgent = FkUserAgent.userAgent!;
    } on PlatformException {
      userAgent = 'Failed to get platform version.';
    }
  }

  static initUserAgentAsync() async {
    if (userAgent == "") {
      await _initUserAgentAsync();
    }
  }

  static dynamic _getDatarFromFile(String keyName) async {
    var data = await dbClient.get(keyName, DataType.tMap);
    return data;
  }

  static void _writeDataToFile(String keyName, dynamic object) async {
    await dbClient.write('user', object);
  }

  static void _deleteDataToFile(String keyName) async {
    await dbClient.delete('user');
  }

  static void initUserAndTeam({Map? userData}) async {
    if (userData == null || userData.isEmpty) {
      userData = await _getDatarFromFile('user');
    } else {
      // userData.remove(key)
      _writeDataToFile('user', userData);
    }
    if (userData != null) {
      currentUser = User(data: userData);
      for (var teamData in userData['teams']) {
        var team = Team(data: teamData);
        teams.add(team);
      }
    }
  }

  static void initToken(String? newToken) {
    if (newToken!.isEmpty) {
      token = _getDatarFromFile('token');
    } else {
      token = newToken;
      _writeDataToFile('token', newToken);
    }
  }

  static void clearUser() async {
    currentUser = null;
    _deleteDataToFile('user');
    _deleteDataToFile('teams');
    _deleteDataToFile('token');
  }
}
