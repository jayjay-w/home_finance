import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/ui/screens/home.dart';

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

  static void registerUser(BuildContext context, String fName, String lName, String email, String password, String currency) async {
    try {
        AuthResult result  = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );

      FirebaseUser signedInUser = result.user;

      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'firstName': fName,
          'lastName': lName,
          'email': email,
          'defaultCurrency': currency,
          'secret': password,
          'profileImageUrl': ''
        });
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      }

    } catch(ex) {
      throw (ex);
    }
  }

}