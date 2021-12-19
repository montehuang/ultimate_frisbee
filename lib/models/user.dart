/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */

class User {
  User({Map<String, dynamic>? data}) {
    // ignore: unnecessary_null_comparison
    if (data == null) {
      return;
    }
    id = data['_id'];
    name = data['name'];
    firstName = data['firstName'];
    picture = data['picture'];
    email = data['email'];
    hasPassword = data['hasPassword'];
    provider = data['provider'];
    dateCreate = data['dateCreated'];
  }
  late String? id = '';
  late String? name = '';
  late String? firstName = '';
  late String? picture = '';
  late String? email = '';
  late bool? hasPassword = false;
  late String? provider = '';
  late String? dateCreate = '';
}

class Team {
  Team({Map<String, dynamic>? data}) {
    // ignore: unnecessary_null_comparison
    if (data == null) {
      return;
    }
    id = data['id'];
    name = data['name'];
  }
  late String? id = '';
  late String? name = '';
}
