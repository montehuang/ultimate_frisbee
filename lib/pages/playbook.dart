/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:frisbee/common/global.dart';
import 'package:frisbee/utils/request_util.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key, this.icon, this.header}) : super(key: key);
  final IconData? icon;
  final String? header;

  @override
  State<StatefulWidget> createState() {
    return _BookPageState();
  }
}

class _BookPageState extends State<BookPage>
    with SingleTickerProviderStateMixin {
  bool _hasLoadData = false;
  var _getAllData;
  late final List<Map<String, dynamic>> _showTagInfos = [];
  late final Map<String, String> _tagMap = {};
  late bool hasNotSeen = false;
  late final Map<String, dynamic> _bookMap = {};
  @override
  void initState() {
    _getAllData = _getAllDatas();

    super.initState();
  }

  Future _getTeamData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var data = await ApiClient().get('/api/teams/$teamId');
      return data;
    }
  }

  Future _getGamesData() async {
    if (Global.teams.isNotEmpty) {
      var teamId = Global.teams[0]!.id;
      var data = await ApiClient().get('/api/teams/$teamId/games');
      return data;
    }
  }

  Future _getAllDatas() async {
    return Future.wait([_getTeamData(), _getGamesData()]);
  }

  List<Widget> _createTabs() {
    if (_showTagInfos.isEmpty) {
      return [
        const SizedBox(
          width: 1,
        )
      ];
    } else {
      var tagInfos = List.from(_showTagInfos);
      List<Widget> tabs = [];
      for (var tagInfo in tagInfos) {
        Widget tab;
        if (tagInfo['name'] == '未看' && hasNotSeen) {
          tab = Tab(
              child: Stack(
            children: [
              const Positioned(
                  right: -5,
                  top: -5,
                  child: Icon(
                    Icons.bookmark,
                    size: 10,
                    color: Colors.red,
                  )),
              Text(tagInfo['name']),
            ],
          ));
        } else {
          tab = Tab(
            child: Text(tagInfo['name']),
          );
        }
        tabs.add(tab);
      }
      return tabs;
    }
  }

  _assignBookMap(key, book) {
    if (book == null) {
      return;
    }
    if (_bookMap[key] == null) {
      _bookMap[key] = [book];
    } else {
      _bookMap[key]!.add(book);
    }
  }

  _processData(data) {
    if (_hasLoadData) {
      return;
    }
    for (var one in data) {
      if (one is List) {
        for (var book in one) {
          _assignBookMap('total', book);
          if (!book['seen']) {
            _assignBookMap('unseen', book);
          }
          for (var tagId in book['tags']??[]) {
            _assignBookMap(tagId, book);
          }
        }
      } else {
        for (var tagInfo in one['tags']) {
          _tagMap[tagInfo['id']] = tagInfo['name'];
          _showTagInfos.add(tagInfo);
        }
      }
    }
    _showTagInfos.insert(0, {'name': '未看', 'id': 'unseen'});
    _showTagInfos.insert(0, {'name': '全部', 'id': 'total'});
    hasNotSeen = _bookMap['unseen']?.isNotEmpty ?? false;
    _hasLoadData = true;
  }

  List<Widget> _createBookBodies() {
    List<Widget> widgets = [];
    _showTagInfos.forEach((tagInfo) {
      var books = _bookMap[tagInfo['id']];
      List<Widget> cards = [];
      for (var book in books) {
        var card = Card(child: Text(book['name']));
        cards.add(card);
      }
      var listView = ListView(children: cards,);
      widgets.add(listView);
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _getAllData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else {
              var data = snapshot.data;
              if (data == null) {
                return Text('获取数据错误');
              }
              _processData(data);
              return DefaultTabController(
                  length: _showTagInfos.length,
                  child: Scaffold(
                      appBar: AppBar(
                          toolbarHeight: 18,
                          bottom: PreferredSize(
                              preferredSize: Size.fromHeight(30.0),
                              child: TabBar(
                                isScrollable: true,
                                unselectedLabelColor:
                                    Colors.white.withOpacity(0.3),
                                indicatorColor: Colors.white,
                                tabs: _createTabs(),
                              ))),
                      body: TabBarView(
                        children: _createBookBodies(),
                      )));
            }
          } else {
            // 请求未结束，显示loading
            return const CircularProgressIndicator();
          }
        });
  }
}
