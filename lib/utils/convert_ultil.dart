/*
 * @Author: Monte
 * @Date: 2022-01-05
 * @Description: 
 */

import 'dart:convert';

String bytesToStringAsString(String data) {
  List<int> bytes = base64Decode(data);
  String result = utf8.decode(bytes);
  return result;
}
