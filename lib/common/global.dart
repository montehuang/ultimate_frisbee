/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */

import 'package:frisbee/models/user.dart';
import 'package:frisbee/utils/db_utils.dart';

class Global {
  static User? currentUser = User();
  static List<Team?> teams = [];
  static DbClient dbClient = const DbClient();
  static String token = '';

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
  }
}
