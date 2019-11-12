import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/ui/screens/authentication/login_screen.dart';
import 'package:homefinance/ui/screens/authentication/signup_screen.dart';
import 'package:homefinance/ui/screens/home.dart';

import 'models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getInitialScreen() {
    return StreamBuilder<FirebaseUser>(stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData) {
        print ('Signed in');
        return HomeScreen(
          user: User(
            userId: snapshot.data.uid, defaultCurrency: 'KES'
          ),defaultCurrency: 'KES',userId: snapshot.data.uid,);
      } else {
        return LoginScreen();
      }
    },
    );
  }
  
 @override
 Widget build(BuildContext context) {
    return MaterialApp(
        title: "Home Finance",
        debugShowCheckedModeBanner: true,
       theme: ThemeData(
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
          color: Colors.black
        )
      ),
      home: _getInitialScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        UserRegistrationScreen.id: (context) => UserRegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
      },
    );
 }
}