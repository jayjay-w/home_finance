import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/util/state_widget.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  static final String id = 'receive_money';
  @override
  _ReceiveMoneyScreenState createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  String _description = "Test";
  String _accountId = "";
  DateTime _incomeDate = DateTime.now();
  String _notes = "Notes";

  _save() {
    DatabaseService.receiveMoney(StateWidget.of(context).state.user.userId, "Test", "Test", Timestamp.fromDate(DateTime.now()), 20, "-LtKMFA1ryIwz_Zg35fF");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receive Money"),
      ),
      body: Center(child: RaisedButton(onPressed: () {_save();}, child: Text("Receive Money")),)
    );
  }
}