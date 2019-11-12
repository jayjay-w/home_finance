import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/transfers.dart';
import 'package:homefinance/ui/widgets/month_selector_widget.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/state.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/widgets/appBar.dart';
import 'package:homefinance/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  static final String id = 'home_screen';
  final User user;
  final String defaultCurrency;
  final String userId;
  final FirebaseUser fbUser;

  HomeScreen({this.user, this.defaultCurrency,this.userId,this.fbUser});

  _HomeScreenState createState() => _HomeScreenState();

  static _HomeScreenState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_HomeScreenState)
    as _HomeScreenState);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;
  String defaultCurrency = "";

  Stream _transStream;
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now().add(Duration(days: 30));
  bool stateLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _startDate = DateTime(DateTime.now().year, DateTime.now().month,  1);
    _endDate = _startDate.add(Duration(days: 30));
    if (appState == null) appState = new StateModel(user: widget.user, firebaseUserAuth: widget.fbUser);
    appState.user = widget.user;
    stateLoaded = true;
  }

  Widget dashboardListWidget(
      String title, String value, IconData icon, Color color, Function tapped) {
    return GestureDetector(
      onTap: tapped,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 36,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 12),
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(Icons.arrow_right, size: 32),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: LoadingScreen(
            child: Scaffold(
              appBar: makeAppBar(context, widget.user.userId),
              body: Column(
                children: <Widget>[
                  // CategorySelector(),
                  Column(
                    children: <Widget>[
                      MonthSelectorWidget(onChanged: (val) {
                        try {
                          if (stateLoaded)  {
                                  setState(() {
                                    _startDate = val;
                                    _endDate = _startDate.add(Duration(days: 30));
                                  });
                          }
                        } catch(ex) { print (ex); }
                      },),
                      Divider(thickness: 2, height: 10, color: Colors.blueGrey,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            StreamBuilder<QuerySnapshot>(
                           stream: accountsRef.where('uid', isEqualTo: widget.user.userId).snapshots(),
                           builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator(),);
                            }
                            else if (snapshot.data.documents == null) {
                              return Center(child: CircularProgressIndicator(),);
                            } else {
                              double totalBalance = 0;
                              for (int i = 0; i< snapshot.data.documents.length; i++) {
                                Account acc = Account.fromDocument(snapshot.data.documents[i]);
                                totalBalance += (acc.currentBalance ?? 0);
                              }

                              return dashboardListWidget(
                                "Accounts", defaultCurrency + " " + currencyFormatter.format(totalBalance), 
                                Icons.account_box, 
                                Colors.green, 
                                (){ 
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => AccountsScreen(user: widget.user,)
                                  ));
                                 });

                            }
                          }
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: StreamBuilder<QuerySnapshot>(
                            stream:  transactionRef.where('owner', isEqualTo: widget.userId)
                                    .where('transactionDate', isGreaterThanOrEqualTo: _startDate, isLessThan: _endDate)
                                    .snapshots()
                                    ,
                            builder: (context, snapshot) {       
                              defaultCurrency = widget.defaultCurrency;
                              double income = 0.00;
                              double expenses = 0.00;
                              double transfers = 0.00;

                              if (snapshot == null || snapshot.hasError || !snapshot.hasData) {
                               return Center(child: CircularProgressIndicator(),);
                              } else {                                
                                for (int i = 0; i < snapshot.data.documents.length; i++) {
                                  Trans trans = Trans.fromDocument(snapshot.data.documents[i]);
                                  if (trans.transType == "Income") income += trans.transactionAmount;
                                  if (trans.transType == "Expense") expenses += trans.transactionAmount;
                                  if (trans.transType == "Transfer") transfers += trans.transactionAmount;
                                }
                              }
                              return Column(
                                  children: <Widget>[
                                    dashboardListWidget("Transfers", defaultCurrency + " " + currencyFormatter.format(transfers), Icons.sync, Colors.blue, (){ { Navigator.push(context, MaterialPageRoute(builder: (_) => TransfersScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)));} }),
                                  
                                  dashboardListWidget("Expenses", defaultCurrency + " " + currencyFormatter.format(expenses), Icons.arrow_downward, Colors.red, (){ { Navigator.push(context, MaterialPageRoute(builder: (_) => ExpensesScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)));} }),
                                  dashboardListWidget("Income", defaultCurrency + " " + currencyFormatter.format(income), Icons.arrow_upward, Colors.green, (){ { Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)));} }),
                                  ],
                                );
                            },
                          ),
                        ),
                       // dashboardListWidget("Budget", defaultCurrency + " " + "0.00", Icons.assessment, Colors.blue, null),
                          ],
                        ),
                      )
                    ],
                    
                  ),
                  Text("Latest transactions..."),
                  Row(
                    children: <Widget>[
                      // ListView.builder(
                        
                      // )
                    ],
                  )
                ],
                
              ),
              
            ),
            inAsyncCall: _loadingVisible),
      );
    }
  
  getTransactions() {
    return [
      {'transType': 'Income', 'amount': 2500, 'transactionDate': DateTime.now()},
      {'transType': 'Expense', 'amount': 500, 'transactionDate': DateTime.now()},
      {'transType': 'Transfer', 'amount': 2400, 'transactionDate': DateTime.now()},
    ];
  }
}
