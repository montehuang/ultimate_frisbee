/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/custom_widgets/field_item_widget.dart';
import 'package:frisbee/custom_widgets/strategy_board.dart';
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
        // centerTitle: false,
        actions: [Row(children: [Text('讨论'), IconButton(onPressed: (){_showModalBottomSheet(context);}, icon: Icon(Icons.mouse_sharp))],)],
        title: Text(
          widget.book['name'],
        ),
      ),
      body: FutureBuilder(
              future: _futureGetBook,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('获取战术出错'),
                    );
                  } else {
                    return Center(child: Padding(padding: EdgeInsets.only(left: 0.r, right: 0.r, top: 0.r, bottom: 100.r), child: StrategyBoard(data: snapshot.data),)) ;
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
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

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContent();
      },
    );
  }
}


class _BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700.r,
      child: Column(
        children: [
          SizedBox(
            height: 70.r,
            child: Center(
              child: Text(
                "xxxxxxxxxx",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 21,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('yyyyyyy'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}