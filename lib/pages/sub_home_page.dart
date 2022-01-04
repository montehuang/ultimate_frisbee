/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'common.dart';
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/utils/request_util.dart';

class SubHomePage extends ViewPage {
  const SubHomePage({Key? key, content, icon, header})
      : super(key: key, content: content, icon: icon, header: header);

  _getTeamData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var data = await ApiClient().get('/api/teams/$teamId');
      return data;
    }
  }

  _getUserStats() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var userId = Global.currentUser!.id;
      var data =
          await ApiClient().get('/api/teams/$teamId/users/$userId/statsgames');
      return data;
    }
  }

  _getAllDatas() async {
    await _getTeamData();
    await _getUserStats();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<dynamic>(
      future: _getAllDatas(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ListView(
          children: [],
        );
      },
    ));
  }
}
