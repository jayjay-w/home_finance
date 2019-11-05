import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';

class AccountsScreen extends StatefulWidget {
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}


final dummyAccounts  = [
  {"accountName": "Stanchart", "accountNo": "122342343", "accountType": "checking", "currency": "KES"},
  {"accountName": "Equity", "accountNo": "122342343", "accountType": "checking", "currency": "KES"},
  {"accountName": "KCB", "accountNo": "122342343", "accountType": "checking", "currency": "KES"},
];

class _AccountsScreenState extends State<AccountsScreen> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('accounts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildList(context, snapshot.data.documents);
        },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
        );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final account = Account.fromDocument(data);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       key: ValueKey(account.accountName),
       child: ListTile(
         title: Text(account.accountName),
         trailing: Text(account.currency),
       ),
    );
  }
}
