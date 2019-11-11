import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/spend_money.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  static final String id = "expenses";
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expenses"),
        actions: <Widget>[
          FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SpendMoneyScreen()
              ));
            },)
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.document(StateWidget.of(context).state.user.userId).collection('transactions').where('transType', isEqualTo: 'Expense').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _buildList(context, snapshot.data.documents);
              //return Text("");
            }
          },
      ),
    );
  }


  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final trans = Trans.fromDocument(data);

    return 
        Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  
                },
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(trans.description, style: TextStyle(fontWeight: FontWeight.bold),),
                            StreamBuilder(
                              stream: usersRef.document(StateWidget.of(context).state.user.userId).collection('accounts').document(trans.debitAccountId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
                                return Text(" " + snapshot.data["accountName"].toString());
                              },
                            ),
                            Text(DateFormat("dd MMM yyyy").format(trans.transactionDate.toDate()))
                          ],
                        ),
                      ),
                      Text( "KES " + currencyFormatter.format(trans.transactionAmount), style: trans.transactionAmount >= 0 ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing:  GestureDetector(child: Icon(Icons.arrow_forward_ios),),
                ),
              ),
              Divider(height: 1,)
            ],
          ),
        );
  }
}