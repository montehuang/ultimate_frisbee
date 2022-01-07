/*
 * @Author: Monte
 * @Date: 2021-12-24
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/events.dart';
import 'package:frisbee/pages/user.dart';
import 'package:frisbee/utils/event_util.dart';
import 'sub_home_page.dart';
import 'player.dart';
import 'playbook.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = [
    const SubHomePage(icon: Icons.home, header: "主页"),
    const BookPage(icon: Icons.book, header: "战术"),
    const PlayerPage(icon: Icons.card_membership, header: "成员"),
  ];
  int _selectedIndex = 1;
  @override
  void initState() {
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
      appBar: AppBar(
          title: const Text(
        'Ultimate Frisbee',
      )),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: tabs
            .map((e) =>
                BottomNavigationBarItem(icon: Icon(e.icon), label: e.header))
            .toList(),
        onTap: _onTap,
        currentIndex: _selectedIndex,
      ),
      drawer: const UserDrawer(),
    );
  }

  @override
  void dispose() {
    // 释放资源
    _tabController.dispose();
    super.dispose();
  }
}
