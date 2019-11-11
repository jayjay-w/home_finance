import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/screens/transfers.dart';
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
import 'package:homefinance/util/state_widget.dart';
import 'package:homefinance/ui/screens/sign_in.dart';
import 'package:homefinance/ui/widgets/loading.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
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
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }
      final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
      return Scaffold(
        backgroundColor: Colors.white,
        body: LoadingScreen(
            child: Scaffold(
              appBar: makeAppBar(context),
              body: Column(
                children: <Widget>[
                  // CategorySelector(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 20, left: 16, right: 10),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "November 2019",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                           stream: usersRef.document(StateWidget.of(context).state.user.userId).collection('accounts').snapshots(),
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
                                "Accounts", "Kes " + currencyFormatter.format(totalBalance), 
                                Icons.account_box, 
                                Colors.green, 
                                (){ Navigator.pushNamed(context, AccountsScreen.id); });

                            }
                          }
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: StreamBuilder<QuerySnapshot>(
                            stream: usersRef.document(StateWidget.of(context).state.user.userId).collection('transactions').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator(),);
                              }
                              double income = 0.00;
                              double expenses = 0.00;
                              double transfers = 0.00;
                              for (int i = 0; i < snapshot.data.documents.length; i++) {
                                Trans trans = Trans.fromDocument(snapshot.data.documents[i]);

                                if (trans.transType == "Income") income += trans.transactionAmount;
                                if (trans.transType == "Expense") expenses += trans.transactionAmount;
                                if (trans.transType == "Transfer") transfers += trans.transactionAmount;
                              }
                              return Column(
                                  children: <Widget>[
                                    dashboardListWidget("Transfers", "Kes " + currencyFormatter.format(transfers), Icons.sync, Colors.blue, (){ Navigator.pushNamed(context, TransfersScreen.id); }),
                                  
                                  dashboardListWidget("Expenses", "Kes " + currencyFormatter.format(expenses), Icons.arrow_downward, Colors.red, (){ Navigator.pushNamed(context, ExpensesScreen.id); }),
                                  dashboardListWidget("Income", "Kes " + currencyFormatter.format(income), Icons.arrow_upward, Colors.green, (){ Navigator.pushNamed(context, IncomeScreen.id);}),
                                  ],
                                );
                            },
                          ),
                        ),
                        dashboardListWidget("Budget", "0.00", Icons.assessment, Colors.blue, null),
                      ],
                      
                    ),
                    
                  ),
                  
                ],
                
              ),
              
            ),
            inAsyncCall: _loadingVisible),
      );
    }
  }
}
