import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart' as prefix0;
import 'package:homefinance/ui/screens/account_summary.dart';
import 'package:homefinance/ui/screens/account_transactions.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/authentication/login_screen.dart';
import 'package:homefinance/ui/screens/authentication/signup_screen.dart';
import 'package:homefinance/ui/screens/budget.dart';
import 'package:homefinance/ui/screens/category_list.dart';
import 'package:homefinance/ui/screens/edit_account.dart';
import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/home.dart';
import 'package:homefinance/ui/screens/home_screen.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/screens/spend_money.dart';
import 'package:homefinance/ui/screens/subcategory_list.dart';
import 'package:homefinance/ui/screens/transfers.dart';

import 'models/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget _getInitialScreen() {
    return StreamBuilder<FirebaseUser>(stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.hasData) {
        print(snapshot.data.uid + '...logged in');

        return StreamBuilder<DocumentSnapshot> (
          stream: usersRef.document(snapshot.data.uid).snapshots(),
          builder: (context, document) {
            User user = User.fromDocument(document.data);
            return MyHomePage(user: user);
          },
        );

        
      } else {
        print('not logged in');
        return LoginScreen();
      }
    },
    );
  }
  
 @override
 Widget build(BuildContext context) {
    return MaterialApp(
        title: "Home Finance",
        debugShowCheckedModeBanner: false,
       theme: ThemeData(
         primaryColor: prefix0.primaryColor,
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
          color: Colors.white
        )
      ),
      home: _getInitialScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        UserRegistrationScreen.id: (context) => UserRegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        MyHomePage.id: (context) => MyHomePage(),
        AccountsScreen.id: (context) => AccountsScreen(),
        EditAccountScreen.id: (context) => EditAccountScreen(),
        AccountSummaryScreen.id: (context) => AccountSummaryScreen(user: null,),
        ReceiveMoneyScreen.id: (context) => ReceiveMoneyScreen(currency: null,),
        IncomeScreen.id: (context) => IncomeScreen(currency: null,),
        TransfersScreen.id: (context) => TransfersScreen(),
        ExpensesScreen.id: (context) => ExpensesScreen(currency: null,),
        SpendMoneyScreen.id: (context) => SpendMoneyScreen(currency: null,),
        AccountTransactions.id: (context) => AccountTransactions(),
        BudgetScreen.id: (context) => BudgetScreen(currency: null,),
        CategoryListScreen.id: (context) => CategoryListScreen(currency: null,),
        SubCategoryListScreen.id: (context) => SubCategoryListScreen(currency: null,)
      },
    );
 }
}