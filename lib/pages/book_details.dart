/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frisbee/custom_widgets/strategy_board.dart';
import 'package:frisbee/utils/request_util.dart';
import 'package:flutter_svg/svg.dart';
import 'package:date_format/date_format.dart';

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
    with TickerProviderStateMixin, RestorationMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  final RestorableInt _tabIndex = RestorableInt(0);
  final RestorableDouble _currentStep = RestorableDouble(0);
  Timer? _customTimer;
  var _futureGetBook;
  bool showLines = false;
  @override
  void initState() {
    super.initState();
    _futureGetBook = _getBookData();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        showLines = false;
      } else if (status == AnimationStatus.completed) {
        showLines = true;
        setState(() {});
      }
    });
  }

  Future _getBookData() async {
    if (widget.book['_id'] != null && widget.book['team'] != null) {
      var data = await ApiClient()
          .get('/api/teams/${widget.book['team']}/games/${widget.book['_id']}');
      return data;
    }
  }

  late Map bookData;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // centerTitle: false,
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (bookData['steps'].length - 1 >=
                          _currentStep.value.toInt()) {
                        _showStepDescriptionBottomSheet(
                            context,
                            bookData['steps'][_currentStep.value.toInt()]
                                    ['descr'] ??
                                "");
                      }
                    },
                    icon: const Icon(Icons.description)),
                IconButton(
                    onPressed: () async {
                      _showDiscussBottomSheet(
                          context, widget.book['team'], widget.book['_id']);
                    },
                    icon: const Icon(Icons.speaker_notes))
              ],
            )
          ],
          title: Tooltip(
              message: widget.book['name']??"",
              child: Text(
                widget.book['name']??'',
              )),
        ),
        body: FutureBuilder(
            future: _futureGetBook,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('??????????????????'),
                  );
                } else {
                  bookData = snapshot.data;
                  return Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            showLines: showLines),
                      )),
                      IconButton(
                          onPressed: () {
                            _currentStep.value = 0;
                            _customTimer?.cancel();
                            _customTimer = Timer.periodic(
                                const Duration(seconds: 2), (timer) {
                              if (_currentStep.value >=
                                  snapshot.data['steps'].length - 1) {
                                timer.cancel();
                                return;
                              }
                              _playAnimation();
                              _currentStep.value++;
                              setState(() {});
                            });
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            size: 50,
                            color: Colors.blue,
                          )),
                      Stack(
                        children: [
                          Builder(builder: (BuildContext context) {
                            if (snapshot.data['steps'].length > 1) {
                              return Positioned(
                                  child: SliderTheme(
                                data: SliderThemeData(
                                    thumbShape: SliderComponentShape.noOverlay),
                                child: Slider(
                                  value: _currentStep.value,
                                  min: 0,
                                  max:
                                      snapshot.data['steps'].length.toDouble() -
                                          1,
                                  divisions: snapshot.data['steps'].length - 1,
                                  label: _currentStep.value.round().toString(),
                                  onChanged: (value) {
                                    _customTimer?.cancel();
                                    _currentStep.value = value;
                                    _playAnimation();
                                    setState(() {});
                                  },
                                ),
                              ));
                            } else {
                              return const SizedBox();
                            }
                          }),
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

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_tabIndex, 'tab_index');
    registerForRestoration(_currentStep, 'current_step');
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void _showDiscussBottomSheet(
      BuildContext context, String teamId, String bookId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _BottomSheetContent(
          teamId: teamId,
          bookId: bookId,
        );
      },
    );
  }

  void _showStepDescriptionBottomSheet(
      BuildContext context, String description) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 300.r,
              child: Column(children: [
                SizedBox(
                  height: 40.r,
                  child: Center(
                    child: Text(
                      "???${_currentStep.value.toInt()}?????????",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(thickness: 1),
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.r, right: 20.r, bottom: 20.r),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                )
              ]));
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class _BottomSheetContent extends StatelessWidget {
  _BottomSheetContent({required this.teamId, required this.bookId});
  late List discussList;
  String teamId;
  String bookId;
  _createAvatar(avatar, radius) {
    return avatar == null
        ? SvgPicture.asset(
            "assets/player.svg",
            width: 20,
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(
              avatar,
            ),
            radius: radius.toDouble(),
          );
  }

  Widget _createListView() {
    Map<String, dynamic> discussMap = {};
    for (var discuss in discussList) {
      var entityId = discuss['_id'];
      var parentId = discuss['parentId'];
      if (parentId != null) {
        if (discussMap.containsKey(parentId)) {
          if (discussMap[parentId]?['children'] == null) {
            discussMap[parentId]['children'] = [discuss];
          } else {
            discussMap[parentId]['children'].add(discuss);
          }
        } else {
          discussMap[parentId] = {
            'detail': {},
            'children': [discuss]
          };
        }
      } else if (!discussMap.containsKey(entityId)) {
        discussMap[entityId] = {'detail': discuss, 'children': []};
      } else {
        discussMap[entityId]['detail'] = discuss;
      }
    }
    List<Widget> tiles = [];
    for (var discuss in discussList) {
      var discussId = discuss['_id'];
      var created = DateTime.parse(discuss['dateCreated']);
      var createTime = formatDate(
          created, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
      var tile = ListTile(
        dense: false,
        leading: _createAvatar(discuss['userPicture'], 15),
        title: Text(discuss['userName'] + '    ' + createTime),
        subtitle: Text(discuss['text']),
      );
      tiles.add(tile);
      if (discussMap.containsKey(discussId)) {
        var detail = discussMap[discussId]['detail'];
        if (!discussMap[discussId]['children'].isEmpty) {
          for (var subDis in discussMap[discussId]['children']) {
            var subCreated = DateTime.parse(subDis['dateCreated']);
            var subCreateTime = formatDate(subCreated,
                [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
            var subTile = ListTile(
              contentPadding: const EdgeInsets.only(left: 50),
              dense: true,
              leading: _createAvatar(subDis['userPicture'], 10),
              title: Text(subDis['userName'] + '    ' + subCreateTime),
              subtitle: Text(subDis['text']),
            );
            tiles.add(subTile);
          }
        }
      }
    }
    return ListView(
      children: tiles,
    );
  }

  Future _getMessageData() async {
    if (teamId != null) {
      var params = {'entityId': '$bookId', 'sort': 'desc'};
      var data =
          await ApiClient().get('/api/teams/$teamId/messages', params: params);
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700.r,
      child: Column(
        children: [
          SizedBox(
            height: 40.r,
            child: const Center(
              child: Text(
                "??????",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
              child: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('????????????????????????');
                } else {
                  discussList = snapshot.data;
                  if (discussList.isEmpty) {
                    return const Text('?????????????????????');
                  } else {
                    return _createListView();
                  }
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
            future: _getMessageData(),
          )),
        ],
      ),
    );
  }
}
