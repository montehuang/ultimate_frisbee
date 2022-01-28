/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frisbee/common/events.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/pages/user.dart';
import 'package:frisbee/utils/event_util.dart';
import 'sub_home_page.dart';
import 'player.dart';
import 'playbook.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_picker/flutter_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String showTeamName = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List tabs = [
    {'page': SubHomePage, 'icon': Icons.home, 'header': '主页'},
    {'page': BookPage, 'icon': Icons.book, 'header': '战术'},
    {'page': PlayerPage, 'icon': Icons.card_membership, 'header': '成员'}
  ];
  int _selectedIndex = 1;
  @override
  void initState() {
    if (Global.teams.isNotEmpty) {
      showTeamName = Global.teams[0]!.name ?? "";
    }
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    EventBusUtil.listen((BottomBarSelectIndexEvent event) {
      setState(() {
        _selectedIndex = event.index;
      });
    });
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(390, 844),
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          showTeamName,
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showPicker(context);
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        if (_selectedIndex == 0) {
          return SubHomePage(teamId: Global.currentTeam!.id.toString());
        } else if (_selectedIndex == 1) {
          return BookPage(teamId: Global.currentTeam!.id.toString());
        } else {
          return PlayerPage(teamId: Global.currentTeam!.id.toString());
        }
      },),
      bottomNavigationBar: BottomNavigationBar(
        items: tabs
            .map((e) =>
                BottomNavigationBarItem(icon: Icon(e['icon']), label: e['header']))
            .toList(),
        onTap: _onTap,
        currentIndex: _selectedIndex,
      ),
      drawer: const UserDrawer(),
    );
  }

  _showPicker(BuildContext context) {
    List names = [];
    var index = 0;
    for (var teamWithKey in Global.teams.asMap().entries) {
      var team = teamWithKey.value;
      names.add(team?.name);
      if (team?.name == showTeamName) {
        index = teamWithKey.key;
      }
    }
    Picker(
        adapter: PickerDataAdapter<String>(pickerdata: names),
        changeToFirst: false,
        selecteds: [index],
        hideHeader: false,
        height: 120,
        title: const Text("选择队伍"),
        confirmText: '确定',
        cancelText: '取消',
        itemExtent: 38,
        cancelTextStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 20.0,
        ),
        confirmTextStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 20.0,
        ),
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(10.0),
        onConfirm: (Picker picker, List value) {
          var newTeamName = picker.getSelectedValues()[0];
          if (newTeamName != showTeamName) {
            showTeamName = newTeamName;
            for (var team in Global.teams) {
              var teamName = team!.name ?? "";
              if (showTeamName == teamName) {
                Global.currentTeam = team;
                break;
              }
            }
            setState(() {});
          }
        }).showModal(context);
  }

  @override
  void dispose() {
    // 释放资源
    _tabController.dispose();
    super.dispose();
  }
}
