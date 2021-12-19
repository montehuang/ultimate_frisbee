/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataType {
  tInt,
  tDouble,
  tBool,
  tString,
  tStringList,
  tMap,
}

class DbClient extends StatelessWidget {
  const DbClient({Key? key}):super(key: key);

  write(String name, dynamic object) async {
    var prefs = await SharedPreferences.getInstance();
    if (object is int) {
      await prefs.setInt(name, object);
    } else if (object is double) {
      await prefs.setDouble(name, object);
    } else if (object is bool) {
      await prefs.setBool(name, object);
    } else if (object is String) {
      await prefs.setString(name, object);
    } else {
      try {
        String raw = jsonEncode(object.toMap());
        await prefs.setString(name, raw);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  dynamic get(String name, DataType type) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic data;
    if (type == DataType.tInt) {
      data = prefs.getInt(name);
    } else if (type == DataType.tDouble) {
      data = prefs.getDouble(name);
    } else if (type == DataType.tBool) {
      data = prefs.getBool(name);
    } else if (type == DataType.tString) {
      data = prefs.getString(name);
    } else if (type == DataType.tMap || type == DataType.tStringList) {
      String? raw = prefs.getString(name);
      try {
        data = jsonDecode(raw ?? '');
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    } else {
      throw Error();
    }
    // ignore: void_checks
    return data;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
