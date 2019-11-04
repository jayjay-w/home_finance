import 'package:flutter/material.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:homefinance/ui/theme.dart';
import 'package:homefinance/ui/screens/home.dart';
import 'package:homefinance/ui/screens/sign_in.dart';
import 'package:homefinance/ui/screens/sign_up.dart';
import 'package:homefinance/ui/screens/forgot_password.dart';

class MyApp extends StatelessWidget {
  MyApp() {
    //Navigation.initPaths();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp Title',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}

void main() {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  runApp(stateWidget);
}
