// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

User userDataFromJson(String str) => User.fromJson(json.decode(str));

String userDataToJson(User data) => json.encode(data.toJson());

class User {
  final String? email;
  final String? provider;
  final String? uid;
  final int? id;
  final bool? allowPasswordChange;
  final dynamic name;
  final String? username;
  final dynamic image;
  final bool? admin;

  User({
    this.email,
    this.provider,
    this.uid,
    this.id,
    this.allowPasswordChange,
    this.name,
    this.username,
    this.image,
    this.admin,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json["email"],
        provider: json["provider"],
        uid: json["uid"],
        id: json["id"],
        allowPasswordChange: json["allow_password_change"],
        name: json["name"],
        username: json["username"],
        image: json["image"],
        admin: json["admin"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "provider": provider,
        "uid": uid,
        "id": id,
        "allow_password_change": allowPasswordChange,
        "name": name,
        "username": username,
        "image": image,
        "admin": admin,
      };
}
