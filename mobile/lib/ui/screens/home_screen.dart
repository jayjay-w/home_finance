import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/transfers.dart';
import 'package:homefinance/ui/screens/user_profile.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  static final String id = 'my_home_screen';
  final User user;
  final String defaultCurrency;
  final String userId;
  final FirebaseUser fbUser;

  MyHomePage({this.user, this.defaultCurrency,this.userId,this.fbUser});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");

  
  Widget dashboardListWidget(
      String title, String value, IconData icon, Color color, Function tapped) {
    return GestureDetector(
      onTap: tapped,
      child: Padding(
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
                size: 24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 12, top: 4),
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 10, top: 4),
                child: Text(
                  value,
                  style: TextStyle(color: color, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: primaryColor, border: Border.all(color: primaryColor)),
              child: Padding(
                padding: EdgeInsets.only(top: 30.0, right: 15.0, left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: () {},
                    ),
                    Text("Family Budget",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold)
                    ),
                    IconButton(
                      icon: Icon(Icons.supervised_user_circle),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userID: widget.userId ,)),);},
                    )
                  ],
                ),
              ),
            ),
            Stack(
              children: <Widget>[
                ClipPath(
                  clipper: CustomShapeClipper(),
                  child: Container(
                    height: 350.0,
                    decoration: BoxDecoration(color: primaryColor),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                            stream: accountsRef.where('uid', isEqualTo: widget.userId).snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(child: CircularProgressIndicator(),);
                              }
                              double accountTotals = 0;
                              for (DocumentSnapshot doc in snapshot.data.documents) {
                                  accountTotals += doc['currentBalance'];
                              }
                              return Text(
                                  widget.user.defaultCurrency + " " + currencyFormatter.format(accountTotals),
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold),
                                );
                            }
                          ),
                          
                          SizedBox(height: 15.0),
                          Text(
                            'Available Balance (All Accounts)',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
                          )
                        ],
                      ),
                      Material(
                        elevation: 1.0,
                        borderRadius: BorderRadius.circular(100.0),
                        color: Colors.blue[300],
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => AccountsScreen(user: widget.user,)
                                  ));
                          },
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 30.0),
                          child: Text(
                            'Accounts',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 120.0, right: 25.0, left: 25.0),
                  child: Container(
                    width: double.infinity,
                    height: 370.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0.0, 3.0),
                              blurRadius: 15.0)
                        ]),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.purple.withOpacity(0.1),
                                    child: IconButton(
                                      padding: EdgeInsets.all(15.0),
                                      icon: Icon(Icons.sync),
                                      color: Colors.blue,
                                      iconSize: 30.0,
                                      onPressed: () {
                                        //Transfer pressed
                                         Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => TransfersScreen(userID: widget.userId, currency: widget.defaultCurrency),
                                    ));
                                      }
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Transfer',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.blue.withOpacity(0.1),
                                    child: IconButton(
                                      padding: EdgeInsets.all(15.0),
                                      icon: Icon(Icons.add_circle),
                                      color: Colors.green,
                                      iconSize: 30.0,
                                      onPressed: () {
                                        //Income pressed
                                         Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => IncomeScreen(userID: widget.userId, currency: widget.defaultCurrency),
                                    ));
                                      }),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Income',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Material(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: Colors.orange.withOpacity(0.1),
                                    child: IconButton(
                                      padding: EdgeInsets.all(15.0),
                                      icon: Icon(Icons.credit_card),
                                      color: Colors.red,
                                      iconSize: 30.0,
                                      onPressed: () {
                                        //Expense pressed
                                         Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => ExpensesScreen(userID: widget.userId, currency: widget.defaultCurrency),
                                    ));
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Expense',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold))
                                ],
                              )
                            ],
                          ),
                        ),
                     
                        Divider(),
                        SizedBox(height: 15.0),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: transactionRef.where('owner', isEqualTo: widget.userId).snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) { return Center(child: CircularProgressIndicator()); }
                              double transfers = 0;
                              double income = 0;
                              double expenses = 0;

                              for (DocumentSnapshot doc in snapshot.data.documents) {
                                Trans trans = Trans.fromDocument(doc);
                                if (trans.transType == 'Transfer') { transfers += trans.transactionAmount; }
                                if (trans.transType == 'Income') { income += trans.transactionAmount; }
                                if (trans.transType == 'Expense') { expenses += trans.transactionAmount; }
                              }

                              return Column(
                                children: <Widget>[
                                  dashboardListWidget("Transfers", widget.defaultCurrency + currencyFormatter.format(transfers), Icons.refresh, Colors.blue, () {}),
                                  dashboardListWidget("Income", widget.defaultCurrency + currencyFormatter.format(income), Icons.arrow_upward, Colors.green, () {}),
                                  dashboardListWidget("Expenses", widget.defaultCurrency + currencyFormatter.format(expenses), Icons.arrow_downward, Colors.red, () {}),
                                ],
                              );
                            },

                          
                          ),
                        )
                         //Empty row after icons
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: Container(
                height: 150.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    TransactionCard(
                      title: 'Rent',
                      value: 25000.00,
                      color: Colors.purple,
                    ),
                    TransactionCard(
                      title: 'Cable/Internet',
                      value: 4000.0,
                      color: Colors.blue,
                    ),
                    TransactionCard(
                      title: 'Electricity',
                      value: 3000.0,
                      color: Colors.orange,
                    ),
                    TransactionCard(
                      title: 'Loan Repayment',
                      value: 15000.0,
                      color: Colors.pink,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0.0, 390.0 - 200);
    path.quadraticBezierTo(size.width / 2, 280, size.width, 390.0 - 200);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TransactionCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  TransactionCard({this.title, this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 15.0),
      child: Container(
        width: 130.0,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 30.0),
              Text('$value',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}
