import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/account_summary.dart';
import 'package:homefinance/ui/screens/edit_account.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/screens/spend_money.dart';
import 'package:homefinance/ui/screens/transfer.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends StatefulWidget {
  final User user;

  AccountsScreen({this.user});

  static final String id = 'accounts';
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
          title: Text("Accounts",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          actions: <Widget>[
            FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EditAccountScreen(user: widget.user,)
              ));
            },)
          ],
                  ),
      body: StreamBuilder<QuerySnapshot>(
        stream: accountsRef.where('uid', isEqualTo: widget.user.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildList(context, snapshot.data.documents);
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: BottomNavigationBar(
          onTap: (index) {
            if (index == 0) {
              //Transfer button clicked
              Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TransferScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)
                ));
            } else if (index == 1) {
              //Expense button clicked
              Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SpendMoneyScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency)
                ));
            } else if (index == 2) {
              //Income button clicked
              Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ReceiveMoneyScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency)
                ));
            }
          },
          items: [
            BottomNavigationBarItem(
              title: Text("Transfer"),
              icon: Icon(Icons.swap_horiz, color: Colors.blue,)
            ),
            BottomNavigationBarItem(
              title: Text("Add Expense"),
              icon: Icon(Icons.arrow_downward, color: Colors.red)
            ),
            BottomNavigationBarItem(
              title: Text("Add Income"),
              icon: Icon(Icons.arrow_upward, color: Colors.green,)
            ),
          ],
        ),
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
                      Text(widget.user.defaultCurrency + " " + currencyFormatter.format(account.currentBalance), style: account.currentBalance >= 0 ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red)),
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
