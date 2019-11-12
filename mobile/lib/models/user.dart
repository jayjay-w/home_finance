import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class User {
  String userId;
  String firstName;
  String lastName;
  String email;
  String imageURL;
  String defaultCurrency;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.defaultCurrency,
    this.imageURL
  });

  factory User.fromJson(Map<String, dynamic> json) => new User(
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        defaultCurrency: json["defaultCurrency"],
        imageURL: json["profileImageUrl"] ?? ""
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "defaultCurrency": defaultCurrency,
        "profileImageUrl": imageURL
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      userId: doc.documentID,
      firstName: doc["firstName"],
      lastName: doc["lastName"],
      email: doc["email"] ?? "",
      imageURL: doc["profileImageUrl"]
    );
  }
}
