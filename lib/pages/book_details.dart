/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'dart:async';
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
  late TabController _controller;
  late AnimationController _animationController;
  final RestorableInt _tabIndex = RestorableInt(0);
  final RestorableDouble _currentStep = RestorableDouble(0);
  Timer? _customTimer;
  var _futureGetMessage;
  var _futureGetBook;
  @override
  void initState() {
    super.initState();
    _futureGetMessage = _getMessageData();
    _futureGetBook = _getBookData();
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _controller.addListener(() {
      setState(() {
        _tabIndex.value = _controller.index;
      });
    });
  }

  Future _getMessageData() async {
    if (widget.book['team'] != null) {
      var data =
          await ApiClient().get('/api/teams/${widget.book['team']}/messages');
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
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // centerTitle: false,
          actions: [
            Row(
              children: [
                Text('讨论'),
                IconButton(
                    onPressed: () {
                      _showModalBottomSheet(context);
                    },
                    icon: Icon(Icons.mouse_sharp))
              ],
            )
          ],
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                          child: Padding(
                        padding: EdgeInsets.only(
                            left: 0.r, right: 0.r, top: 0.r, bottom: 0.r),
                        child: StrategyBoard(
                          cort: snapshot.data['cort'],
                          playerMap: snapshot.data['players'],
                          stepIndex: _currentStep.value.toInt(),
                          currentStepMap: snapshot.data['steps']
                              [_currentStep.value.toInt()],
                          controller: _animationController.view,
                        ),
                      )),
                      Row(
                        children: [
                          Flexible(
                            child: Slider(
                              value: _currentStep.value,
                              min: 0,
                              max: snapshot.data['steps'].length.toDouble() - 1,
                              divisions: snapshot.data['steps'].length - 1,
                              label: _currentStep.value.round().toString(),
                              onChanged: (value) {
                                _customTimer?.cancel();
                                  _currentStep.value = value;
                                  _playAnimation();
                                setState(() {
                                });
                              },
                            ),
                            flex: 9,
                          ),
                          Flexible(
                            child: IconButton(
                                onPressed: () {
                                  _currentStep.value = 0;
                                  _customTimer?.cancel();
                                  _customTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
                                    if (_currentStep.value >=
                                        snapshot.data['steps'].length - 1) {
                                      timer.cancel();
                                      return;
                                    }
                                    setState(() {
                                      _playAnimation();
                                      _currentStep.value++;
                                    });
                                  });
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Colors.blue,
                                )),
                            flex: 1,
                          )
                        ],
                      )
                    ],
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  @override
  String? get restorationId => 'book_details';

  runTick() {}
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_tabIndex, 'tab_index');
    registerForRestoration(_currentStep, 'current_step');
    _controller.index = _tabIndex.value;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _tabIndex.dispose();
    _customTimer?.cancel();
    _currentStep.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      _animationController.reset();
      await _animationController.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
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
