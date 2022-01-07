/*
 * @Author: Monte
 * @Date: 2022-01-07
 * @Description: 
 */
import 'package:flutter/material.dart';

class BookDetailPage extends StatefulWidget {
  BookDetailPage({Key? key, required this.book}) : super(key: key);
  Map book;
  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _BookDetailPageState(book: book);
  }

}

class _BookDetailPageState extends State<BookDetailPage> with TickerProviderStateMixin {
  _BookDetailPageState({required this.book});
  Map book;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(book['name']),
      ),
      body: const Center(child: CircularProgressIndicator(),),
    );
  }

}