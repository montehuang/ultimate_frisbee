/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookDetailPage extends StatefulWidget {
  BookDetailPage({Key? key, required this.book}) : super(key: key);
  Map book;
  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _BookDetailPageState(book: book);
  }
}

class _BookDetailPageState extends State<BookDetailPage>
    with TickerProviderStateMixin, RestorationMixin {
  _BookDetailPageState({required this.book});
  Map book;
  late TabController _controller;
  final RestorableInt _tabIndex = RestorableInt(0);

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      setState(() {
        _tabIndex.value = _controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['战术', '讨论'];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30,
        titleSpacing: 0,
        title: Text(book['name'],),
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
          for (var tab in tabs) Container(margin:EdgeInsets.symmetric(vertical: 5.r), child: Text(tab), color: Colors.redAccent,)
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
