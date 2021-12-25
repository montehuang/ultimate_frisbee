/*
 * @Author: Monte
 * @Date: 2021-12-19
 * @Description: 
 */

class User {
  User({Map? data}) {
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
    dateCreated = data['dateCreated'];
  }
  late String? id = '';
  late String? name = '';
  late String? firstName = '';
  late String? picture = '';
  late String? email = '';
  late bool? hasPassword = false;
  late String? provider = '';
  late String? dateCreated = '';

  Map toMap() {
    return {
      '_id': id,
      'name': name,
      'firstName': firstName,
      'picture': picture,
      'email': email,
      'hasPassword': hasPassword,
      'provider': provider,
      'dateCreated': dateCreated,
    };
  }
}

class Team {
  Team({Map? data}) {
    // ignore: unnecessary_null_comparison
    if (data == null) {
      return;
    }
    id = data['id'];
    name = data['name'];
  }
  late String? id = '';
  late String? name = '';

  Map toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
