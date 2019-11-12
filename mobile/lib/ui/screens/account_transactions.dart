import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:intl/intl.dart';

class AccountTransactions extends StatefulWidget {
  static String id = "account_transactions";
  final Account account;
  final String currency;
  final String userID;


  AccountTransactions({this.account,this.currency, this.userID});

  @override
  _AccountTransactionsState createState() => _AccountTransactionsState();
}

class _AccountTransactionsState extends State<AccountTransactions> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions: " + widget.account.accountName),
      ),
       body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.document(widget.userID).collection('transactions').orderBy('transactionDate').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              List<DocumentSnapshot> docs = [];

              for (DocumentSnapshot doc in snapshot.data.documents) {
                Trans transaction = new Trans.fromDocument(doc);
                if (transaction.creditAccountId == widget.account.accountId || transaction.debitAccountId == widget.account.accountId)
                  docs.add(doc);
              }

              return _buildList(context, docs);//snapshot.data.documents);
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

    if (trans.transType == 'Transfer') {
      if (trans.creditAccountId == widget.account.accountId) trans.comment = 'TransferTo';
      if (trans.debitAccountId == widget.account.accountId) trans.comment = 'TransferFrom';
    }

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
                            trans.transType == 'Transfer' ? StreamBuilder(
                              stream: usersRef.document(widget.userID).collection('accounts').document(trans.comment == 'TransferFrom' ? trans.creditAccountId : trans.debitAccountId).snapshots(),
                              builder: (context, snap) {
                                if (!snap.hasData) return Center(child: CircularProgressIndicator(),);
                                return Text((trans.comment == 'TransferFrom' ? 'Transfer To ' : 'Transfer From ') + snap.data["accountName"].toString(), style: TextStyle(fontWeight: FontWeight.bold),);
                              },
                            ) 
                            : 
                            Text(trans.description, style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(DateFormat("dd MMM yyyy").format(trans.transactionDate.toDate()))
                          ],
                        ),
                      ),
                      Text( "KES " + currencyFormatter.format(trans.transactionAmount), style: trans.transType == 'Income' || trans.comment == 'TransferTo' ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red)),
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