import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/home.dart';
import 'package:homefinance/ui/screens/home_screen.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;

  static void loginUser(BuildContext context, String email, String password) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);      
    } catch (ex) {
      throw (ex);
    }
  }

  static void logOutUser(BuildContext context) {
    _auth.signOut();
  }

  static Future<FirebaseUser> currentUser() async {
    return await FirebaseAuth.instance.currentUser().then((onValue) {
      return onValue;
    });
  }

  Future<User> getUser(String uid) async {
    DocumentSnapshot doc = await usersRef.document(uid).get();
    User user = User.fromDocument(doc);
    return user;
  }

  static void registerUser(BuildContext context, String fName, String lName, String email, String password, String currency, String currencySymbol) async {
    try {
        AuthResult result  = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );

      FirebaseUser signedInUser = result.user;
      User newUser = User(
        firstName: fName,
        lastName: lName,
        email: email,
        defaultCurrency: currency,
        currencySymbol: currencySymbol,
        imageURL: ""
      );
      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData(newUser.toJson());
        newUser.userId = result.user.uid;
        Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (_) => MyHomePage(user: newUser, currencySymbol: currencySymbol, defaultCurrency: currency,)
                  ));
      }

    } catch(ex) {
      throw (ex);
    }
  }

}