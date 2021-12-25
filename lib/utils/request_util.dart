/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */
import 'dart:convert';
import 'package:frisbee/common/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ApiClient {
  _getHeaders() async {
    await Global.initUserAgentAsync();
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Referer': 'https://www.ultiplays.com/',
      'Origin': 'https://www.ultiplays.com',
      'User-Agent': Global.userAgent,
      'Cookie': 'token=$Global.token;'
    };
    if (Global.token != null && Global.token!.isNotEmpty) {
      header['Cookie'] = 'token=$Global.token;';
    }
    return header;
  }
  get(path) async {
    var client = http.Client();
    Map<String, String> headers = await _getHeaders();
    var url = Uri.https('www.ultiplays.com', path);
    var response = await client.get(url, headers: headers);
    var _content = response.body;
    var data = jsonDecode(_content);
    return data;
  }

  getNoData(path) async {
    var client = http.Client();
    Map<String, String> headers = await _getHeaders();
    var url = Uri.https('www.ultiplays.com', path);
    var _ = await client.get(url, headers: headers);
  }

  post(path, Map<String, String> postBody) async {
    var headers = await _getHeaders();
    var url = Uri.https('www.ultiplays.com', path);
    var client = http.Client();
    var response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(postBody));
    if (response.statusCode != 200) {
      return {};
    }
    var _content = response.body;
    var cookieInfo = response.headers['set-cookie'];
    var cookies = cookieInfo!.split(';');
    var token = cookies[0].split('=')[1];
    var data = jsonDecode(_content);
    return {"data": data, "token": token};
  }
}
