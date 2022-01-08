/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frisbee/common/global.dart';

class BookDetailPage extends StatefulWidget {
  BookDetailPage({Key? key, required this.book}) : super(key: key);
  Map book;
  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _BookDetailPageState();
  }
}

class _BookDetailPageState extends State<BookDetailPage>
    with TickerProviderStateMixin, RestorationMixin {
  _BookDetailPageState();
  late TabController _controller;
  final RestorableInt _tabIndex = RestorableInt(0);

  var _futureGetMessage;
  var _futureGetBook;
  @override
  void initState() {
    super.initState();
    _futureGetMessage = _getMessageData();
    _futureGetBook = _getBookData();
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      setState(() {
        _tabIndex.value = _controller.index;
      });
    });
  }

  Future _getMessageData() async {
    if (widget.book['team'] != null) {
      var data = await ApiClient().get('/api/teams/${widget.book['team']}/messages');
      return data;
    }
  }

  Future _getBookData() async {
    if (widget.book['_id'] != null && widget.book['team'] != null) {
      var data = await ApiClient()
          .get('/api/teams/${widget.book['team']}/games/${widget.book['_id']}');
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['战术', '讨论'];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30,
        titleSpacing: 0,
        title: Text(
          widget.book['name'],
        ),
        bottom: TabBar(
          // padding: EdgeInsets.symmetric(horizontal: 20),
          controller: _controller,
          tabs: [
            for (var tab in tabs)
              Center(
                child: Text(tab),
              )
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          FutureBuilder(
              future: _futureGetBook,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('获取战术出错'),
                    );
                  } else {
                    return const Center(
                      child: Text('获取战术成功'),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          FutureBuilder(
              future: _futureGetMessage,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('获取消息出错'),
                    );
                  } else {
                    return const Center(
                      child: Text('获取消息成功'),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
        ],
      ),
    );
  }

  @override
  String? get restorationId => 'book_details';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_tabIndex, 'tab_index');
    _controller.index = _tabIndex.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabIndex.dispose();
    super.dispose();
  }
}
