import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/transfer.dart';
import 'package:intl/intl.dart';

class TransfersScreen extends StatefulWidget {
  static final String id = "transfers";
  final String currency;
  final String userID;

  TransfersScreen({this.currency, this.userID});
  @override
  _TransfersScreenState createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Transfers"),
        actions: <Widget>[
          FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => TransferScreen(userID: widget.userID, currency: widget.currency,)
              ));
            },)
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: transactionRef.where('owner', isEqualTo: widget.userID).where('transType', isEqualTo: 'Transfer').orderBy('transactionDate').snapshots(),
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
                  Navigator.push(context, MaterialPageRoute(
                  builder: (_) => TransferScreen(userID: widget.userID, transaction: trans, currency: widget.currency,)
              ));
                },
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                 StreamBuilder(
                                  stream: accountsRef.document(trans.debitAccountId).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
                                    return Text("From " + snapshot.data["accountName"].toString());
                                  },
                                ),
                                StreamBuilder(
                                  stream: accountsRef.document(trans.creditAccountId).snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
                                    return Text("To " + snapshot.data["accountName"].toString());
                                  },
                                ),
                              ],
                            ),
                            Text(DateFormat("dd MMM yyyy").format(trans.transactionDate.toDate()))
                          ],
                        ),
                      ),
                      Text( widget.currency + " " + currencyFormatter.format(trans.transactionAmount), style: trans.transactionAmount >= 0 ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red)),
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