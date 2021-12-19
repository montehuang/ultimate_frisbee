/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  _request(path, Function f) async {
    var client = http.Client();
    Map<String, String> requestHeaders = {
       'Cookie': 'token=eyJpZCI6IjYxODEzYjdkYmUyYjFmMDAxNDQzOTkwMyIsIiRlIjoxNjcxMzc5MTY3MzYwfQrDj3vCnTs7w5TDs2nDkTrCmMKqw4lhT8On;',
     };
    var url =
        Uri.https('www.ultiplays.com', path);
    var response = await client.get(url, headers: requestHeaders);
    var _content = response.body;
    // ignore: avoid_print
    var data = jsonDecode(_content);
    print(data);
    f(data);
  }

  get(path, Function f) {
    return _request(path, f);
  }
}
