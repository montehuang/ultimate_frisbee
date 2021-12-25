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

  write(String name, dynamic value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(name, value);
    } else if (value is double) {
      await prefs.setDouble(name, value);
    } else if (value is bool) {
      await prefs.setBool(name, value);
    } else if (value is String) {
      await prefs.setString(name, value);
    } else if (value is Map) {
      try {
        String raw = jsonEncode(value);
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

  dynamic delete(String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(name)) {
      prefs.remove(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
