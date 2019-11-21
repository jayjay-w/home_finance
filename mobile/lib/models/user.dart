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
  String currencySymbol;
  String defaultCurrency;
  bool isGoogleUser;
  bool setUpComplete;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.defaultCurrency,
    this.currencySymbol,
    this.imageURL,
    this.isGoogleUser
  });

  factory User.fromJson(Map<String, dynamic> json) => new User(
        userId: json["userId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        defaultCurrency: json["defaultCurrency"] ?? "USD",
        currencySymbol: json["currencySymbol"] ?? "\$",
        imageURL: json["profileImageUrl"] ?? "",
        isGoogleUser: json["isGoogleUser"] ?? false
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "defaultCurrency": defaultCurrency ?? "USD",
        "currencySymbol": currencySymbol ?? "\$",
        "profileImageUrl": imageURL,
        "isGoogleUser": isGoogleUser ?? false
      };

  factory User.fromDocument(DocumentSnapshot doc) {
    if (doc == null || doc.data == null) {
      return null;
    }
    User ret = User(
      userId: doc.documentID,
      firstName: doc["firstName"],
      lastName: doc["lastName"],
      email: doc["email"],
      defaultCurrency: doc["defaultCurrency"] ?? "USD",
      currencySymbol: doc["currencySymbol"] ?? "\$",
      imageURL: doc["profileImageUrl"] ?? "",
      isGoogleUser: doc["isGoogleUser"] ?? false
    );
    ret.setUpComplete = doc["setupComplete"];
    return ret;
  }
}
