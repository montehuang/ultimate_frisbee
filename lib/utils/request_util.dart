/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */
import 'dart:convert';

import 'package:frisbee/common/global.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  get(path) async {
    var client = http.Client();
    Map<String, String> requestHeaders = {
      'Cookie': 'token=$Global.token;',
    };
    var url = Uri.https('www.ultiplays.com', path);
    var response = await client.get(url, headers: requestHeaders);
    var _content = response.body;
    var data = jsonDecode(_content);
    return data;
  }

  getNoData(path) async {
    var client = http.Client();
    Map<String, String> requestHeaders = {
      'Cookie': 'token=$Global.token;',
    };
    var url = Uri.https('www.ultiplays.com', path);
    var _ = await client.get(url, headers: requestHeaders);
  }

  post(path, Map<String, String> postBody) async {
    var header = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Referer': 'https://www.ultiplays.com/',
      'Origin': 'https://www.ultiplays.com',
      'Cookie': 'uvts=3726f53d-3b48-445e-46ca-ffcbbcbf7f51',
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.37 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'
    };
    var url = Uri.https('www.ultiplays.com', path);
    var client = http.Client();
    var response = await client.post(
        url,
        headers: header,
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
