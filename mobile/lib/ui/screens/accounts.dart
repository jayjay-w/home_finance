import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/screens/account_summary.dart';
import 'package:homefinance/ui/screens/edit_account.dart';

class AccountsScreen extends StatefulWidget {
  final User user;

  AccountsScreen({this.user});

  static final String id = 'home_screen';
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Home Finance",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          actions: <Widget>[
            FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EditAccountScreen(userId: widget.user.userId,)
              ));
            },)
          ],
                  ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.document(widget.user.userId).collection('accounts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildList(context, snapshot.data.documents);
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
    final account = Account.fromDocument(data);

    return 
        Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AccountSummaryScreen(user: widget.user, account: account,)
                  ));
                },
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(child: Text(account.accountName, style: TextStyle(fontWeight: FontWeight.bold),)),
                      Text(account.currency + " " + account.balance.toString(), style: account.balance >= 0 ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red)),
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
