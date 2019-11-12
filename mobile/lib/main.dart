import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/ui/screens/account_summary.dart';
import 'package:homefinance/ui/screens/account_transactions.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/authentication/login_screen.dart';
import 'package:homefinance/ui/screens/authentication/signup_screen.dart';
import 'package:homefinance/ui/screens/edit_account.dart';
import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/home.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/screens/spend_money.dart';
import 'package:homefinance/ui/screens/transfers.dart';

import 'models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getInitialScreen() {
    return StreamBuilder<FirebaseUser>(stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData) {
        return HomeScreen(
          user: User(
            userId: snapshot.data.uid, defaultCurrency: 'KES'
          ),defaultCurrency: 'KES',userId: snapshot.data.uid,fbUser: snapshot.data,);
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
        AccountsScreen.id: (context) => AccountsScreen(),
        EditAccountScreen.id: (context) => EditAccountScreen(),
        AccountSummaryScreen.id: (context) => AccountSummaryScreen(),
        ReceiveMoneyScreen.id: (context) => ReceiveMoneyScreen(),
        IncomeScreen.id: (context) => IncomeScreen(),
        TransfersScreen.id: (context) => TransfersScreen(),
        ExpensesScreen.id: (context) => ExpensesScreen(),
        SpendMoneyScreen.id: (context) => SpendMoneyScreen(),
        AccountTransactions.id: (context) => AccountTransactions(),
      },
    );
 }
}