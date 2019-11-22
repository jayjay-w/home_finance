import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/home_screen.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;
  static final _googleSignIn = GoogleSignIn();

  static Future<bool>loginUser(BuildContext context, String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);      
      if (result.user == null) {
        //login failed
        print ('authentication failed');
        return false;
      } else {
        return true;
      }
    } catch (ex) {
        print ('authentication failed');
      return false;
    }
  }

  static void logOutUser(BuildContext context) {
    _auth.signOut();
  }

  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount  googleSignInAccount = await _googleSignIn.signIn();
      print('Setting up account for ' + googleSignInAccount.email);
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );


      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user  = authResult.user;

      createFirebaseDbUser(
                null, 
                user, 
                googleSignInAccount.displayName.indexOf(" ") > 0 ? googleSignInAccount.displayName.split(" ")[0] : googleSignInAccount.displayName, 
                googleSignInAccount.displayName.indexOf(" ") > 0 ? googleSignInAccount.displayName.split(" ")[1] : "", 
                googleSignInAccount.email, 
                "", 
                "USD", 
                "\$", 
                true,
                googleSignInAccount.photoUrl);

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      return true;
    } catch (ex) {   print(ex); return false;  }
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
      createFirebaseDbUser(context, signedInUser, fName, lName, email, password, currency, currencySymbol, false, "");

    } catch(ex) {
      throw (ex);
    }
  }

  static Future<User> getUserObjectByUid(String uid) async {
    User user = null;
    await _firestore.collection('/users').document(uid).get().then((userDoc) {
      if (userDoc.data == null) { return null; }
      user = User.fromDocument(userDoc);
    } );
    return user;
  }

  static void createFirebaseDbUser(BuildContext context, FirebaseUser signedInUser, String fName, String lName, String email, String password, String currency, String currencySymbol, bool isGoogleUser, String imageUrl) async {
    print('creating local account for ' + email);

    User existingUser = await AuthService.getUserObjectByUid(signedInUser.uid);
    

    User newUser = User(
        firstName: fName,
        lastName: lName,
        email: email,
        defaultCurrency: currency,
        currencySymbol: currencySymbol,
        imageURL: imageUrl,
        isGoogleUser: isGoogleUser,
      );
      if (existingUser != null) {
      newUser.setUpComplete = existingUser.setUpComplete;
      newUser.currencySymbol = existingUser.currencySymbol;
      newUser.defaultCurrency = existingUser.defaultCurrency;
    }

      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData(newUser.toJson());
        newUser.userId = signedInUser.uid;
        if (context != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => MyHomePage(user: newUser)
                    ));
        }
      }
  }

}