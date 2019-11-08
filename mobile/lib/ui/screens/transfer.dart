import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/util/state_widget.dart';

class TransferScreen extends StatefulWidget {
  static final String id = 'transfer';
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer Money"),
        actions: <Widget>[
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              DatabaseService.transferMoney(StateWidget.of(context).state.user.userId, '-LtAHnVYAfdey2gXyw4V', '-LtAHqM2PycFUZdCbphq', Timestamp.now(), 2);
            }, 
            child: Text("Save", style: TextStyle(fontSize: 18),),
          )
        ],
      ),
    );
  }
}