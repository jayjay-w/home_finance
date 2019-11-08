import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/user.dart';
import 'package:intl/intl.dart';

class AccountSummaryScreen extends StatefulWidget {
  final Account account;
  final User user;

  AccountSummaryScreen({this.account, this.user});
  static final String id = 'edit_account';
  @override
  _AccountSummaryScreenState createState() => _AccountSummaryScreenState();
}

class _AccountSummaryScreenState extends State<AccountSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.accountName),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.edit),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.delete),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 1),
        child: Column(
          children: <Widget>[
            Text("ALL TRANSACTIONS"),
            Padding(
              padding: EdgeInsets.only(left: 20.0, top: 10, right: 20),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                      Expanded(child: Text("As Of " + DateFormat("dd MMM yyyy").format(widget.account.dateCreated.toDate()) )), Text("0.00 CHF")
                    ],),
                  Row(children: <Widget>[
                      Expanded(child: Text("   + Funds In")), Text("0.00 CHF", style: TextStyle(color: Colors.green),)
                    ],),
                  Row(children: <Widget>[
                      Expanded(child: Text("   +Funds Out")), Text("0.00 CHF", style: TextStyle(color: Colors.red))
                    ],),
                  Row(children: <Widget>[
                      Expanded(child: Text("Current Balance")), Text("0.00 CHF")
                    ],),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}