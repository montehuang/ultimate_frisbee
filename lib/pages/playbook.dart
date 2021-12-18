/*
 * @Author: Monte
 * @Date: 2021-12-18
 * @Description: 
 */
import 'common.dart';
import 'package:flutter/material.dart';

class BookPage extends ViewPage {
  const BookPage({Key ? key, content, icon, header}): 
    super(key: key, content: content, icon: icon, header: header);
  @override
  Widget build(BuildContext context) {
    return Text(content);
  }
}