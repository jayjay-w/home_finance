import 'package:flutter/material.dart';
import 'package:homefinance/ui/screens/account_summary.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/edit_account.dart';
import 'package:homefinance/ui/screens/user_profile.dart';
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
      title: 'Home Finance',
      theme: buildTheme(),
      //onGenerateRoute: Navigation.router.generator,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/profile': (context) => UserProfileScreen(),
        AccountsScreen.id: (context) => AccountsScreen(user: StateWidget.of(context).state.user,),
        EditAccountScreen.id: (context) => EditAccountScreen(),
        AccountSummaryScreen.id: (context) => AccountSummaryScreen(),
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
