import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/state.dart';
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
      String title, String value, IconData icon, Color color) {
    return Padding(
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
                        dashboardListWidget("Expenses", "Kes 102,328.00",
                            Icons.arrow_downward, Colors.red),
                        dashboardListWidget("Income", "Kes 163,000.00",
                            Icons.arrow_upward, Colors.green),
                        dashboardListWidget("Bills", "Kes 93,452.00",
                            Icons.payment, Colors.blue),
                        dashboardListWidget("Budget", "Kes 96,109.00",
                            Icons.queue_play_next, Colors.black),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AccountsScreen.id);
                          },
                          child: StreamBuilder<QuerySnapshot>(
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
                                  totalBalance += double.parse(snapshot.data.documents[i]['amount']);
                                }

                                return dashboardListWidget("Accounts", "Kes " + totalBalance.toString(), Icons.account_box, Colors.green);

                              }
                            }
                          ),
                        ),
                        dashboardListWidget("Transfers", "Kes 0.00",
                            Icons.refresh, Colors.indigo),
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
