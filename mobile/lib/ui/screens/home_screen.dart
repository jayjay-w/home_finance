import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/auth_service.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/accounts.dart';
import 'package:homefinance/ui/screens/budget.dart';
import 'package:homefinance/ui/screens/expenses.dart';
import 'package:homefinance/ui/screens/income.dart';
import 'package:homefinance/ui/screens/transfers.dart';
import 'package:homefinance/ui/screens/user_profile.dart';
import 'package:homefinance/ui/widgets/charts.dart';
import 'package:homefinance/ui/widgets/currency_dropdown.dart';
import 'package:homefinance/ui/widgets/month_selector_widget.dart';
import 'package:homefinance/ui/widgets/user_profile_widget.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  static final String id = 'my_home_screen';
  final User user;

  MyHomePage({this.user});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, 1).add(Duration(days: 30));
  String _setupCurrency;
  String _setupCurrencySymbol;
  bool stateLoading = true;
  BannerAd bottomBanner = BannerAd(
      adUnitId: "ca-app-pub-6470490276899852/5330132357", // TEST Ad: "ca-app-pub-3940256099942544/6300978111",//
      size: AdSize.smartBanner,
      // targetingInfo:
      listener: (MobileAdEvent evt) {
        print("BannerAd event is $evt");
      } ,
    );


  @override
  void initState() {
    super.initState();
    stateLoading = false;
    _setupCurrency = widget.user.defaultCurrency;
    _setupCurrencySymbol = widget.user.currencySymbol;
  }
  

  @override
  Widget build(BuildContext context) {
    

    if (widget.user == null) {
      return Container(color: Colors.white, child: Center(child: CircularProgressIndicator(),));
    }

    if (widget.user.setUpComplete == null || !widget.user.setUpComplete) {
      //Show a popup for the user to set up their name and currency
      return Scaffold(
        appBar: _makeAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Center(
            
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    UserProfileWidget(user: widget.user,),
                    SizedBox(height: 40,),
                    Text("Please select your default currency:"),
                    CurrencyDropDown(currencyValue: _setupCurrency, onChanged: (cur, sym) {
                       SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                            _setupCurrency = cur;
                            _setupCurrencySymbol = sym;
                      }));
                      widget.user.defaultCurrency = cur;
                      widget.user.currencySymbol = sym;

                      DatabaseService.updateUser(widget.user);

                      

                    },),
                    OutlineButton(
                      splashColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        highlightElevation: 0,
                        borderSide: BorderSide(color: Colors.grey),
                        onPressed: () { 
                          widget.user.setUpComplete = true;
                          DatabaseService.updateUser(widget.user);
                         },
                        child: Text(
                          "Finish Account Setup",
                          style: TextStyle(color: primaryColor),
                        ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    showBottomAd(); 
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 244, 244, 1),
      drawer: _makeDrawer(),
      appBar: _makeAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                            stream: accountsRef.where('uid', isEqualTo: widget.user.userId).snapshots(),
                            builder: (context, snapshot) {                              
                              double accountTotals = 0;
                              if (snapshot.hasData) {
                                for (DocumentSnapshot doc in snapshot.data.documents) {
                                    accountTotals += doc['currentBalance'];
                                }
                              }
                              return Text(
                                  widget.user.currencySymbol + " " + currencyFormatter.format(accountTotals),
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
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20, top: 20.0, bottom: 20),
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
                                      builder: (BuildContext context) => TransfersScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
                                    ));
                                      }
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Transfer',
                                      style: boldGrey)
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
                                      builder: (BuildContext context) => IncomeScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
                                    ));
                                      }),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Income',
                                      style: boldGrey)
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
                                      builder: (BuildContext context) => ExpensesScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
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
                     
                        //Divider(),
                        //SizedBox(height: 15.0),
                        Container(
                          child: MonthSelectorWidget(onChanged: (val) { 
                                try {
                                  if (!stateLoading) {
                                setState(() {
                                  _startDate = val; 
                                  _endDate = _startDate.add(Duration(days: 30));
                              }); 
                            }
                                } catch(ex) { print(''); }
                          },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: transactionRef.where('owner', isEqualTo: widget.user.userId).where('transactionDate', isGreaterThanOrEqualTo: _startDate, isLessThan: _endDate).snapshots(),
                            builder: (context, snapshot) {
                              
                              double transfers = 0;
                              double income = 0;
                              double expenses = 0;

                              if (snapshot.hasData) {
                                for (DocumentSnapshot doc in snapshot.data.documents) {
                                  Trans trans = Trans.fromDocument(doc);
                                  if (trans.transType == 'Transfer') { transfers += trans.transactionAmount; }
                                  if (trans.transType == 'Income') { income += trans.transactionAmount; }
                                  if (trans.transType == 'Expense') { expenses += trans.transactionAmount; }
                                }
                              }

                              return Column(
                                children: <Widget>[
                                  dashboardListWidget("Transfers", widget.user.currencySymbol + " " + currencyFormatter.format(transfers), Icons.refresh, Colors.blue, () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => TransfersScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
                                    ));
                                  }),
                                  dashboardListWidget("Income", widget.user.currencySymbol + " " + currencyFormatter.format(income), Icons.arrow_upward, Colors.green, () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => IncomeScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
                                    ));
                                  }),
                                  dashboardListWidget("Expenses", widget.user.currencySymbol + " " + currencyFormatter.format(expenses), Icons.arrow_downward, Colors.red, () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => ExpensesScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency),
                                    ));
                                  }),                                  
                                ],
                              );
                            },                          
                          ),                          
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: StreamBuilder<QuerySnapshot>(
                                    stream: subCategoryRef.where('owner', isEqualTo: widget.user.userId).snapshots(),
                                  builder: (context, snapshot) {
                                    double budget = 0;

                                    if (snapshot.hasData) {
                                      for (DocumentSnapshot doc in snapshot.data.documents) {
                                          budget += doc["budget"];
                                      }
                                    }

                                   return dashboardListWidget("Budget", widget.user.currencySymbol + " " + currencyFormatter.format(budget), Icons.change_history, Colors.purple, () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => BudgetScreen(userID: widget.user.userId, currency: widget.user.currencySymbol),
                                    ));
                                  });
                                }
                        ),
                        )
                        ],
                    ),
                  ),
                ),
              ],
            ),
             Padding(
                  padding: EdgeInsets.only(top: 20.0, right: 25.0, left: 25.0),
                  child: Container(
                    width: double.infinity,
                    height: 250.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0.0, 3.0),
                              blurRadius: 15.0)
                        ]),
                    child: ExpenseProgressWidget(_startDate, _endDate, widget.user.userId),
                  )
             ),
            Padding(
              padding: EdgeInsets.only(left: 25.0, top: 30.0),
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionRef.where('owner', isEqualTo: widget.user.userId).where('transType').orderBy('transactionDate', descending: true).limit(10).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return _buildList(context, snapshot.data.documents);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

    Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: snapshot.map((data) => _buildListItem(context, data)).toList(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Trans trans = Trans.fromDocument(data);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TransactionCard
      (
        transaction: trans, user: widget.user,
      ),
    );
  }

  _makeAppBar() {
    return AppBar(
        elevation: 0.0,
        actions: <Widget>[
           IconButton(
                      icon: Icon(Icons.supervised_user_circle),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userID: widget.user.userId , user: widget.user,)),);},
                    )
        ],
        title: Row(
          children: <Widget>[
            Expanded(child: Text("")),
            Text("Expense Tracker",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold)),
             Expanded(child: Text("")),
          ],
        ),
      );
  }

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

  void showBottomAd() async {
       bottomBanner
      ..load()
      ..show(
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
        anchorType: AnchorType.bottom
      );
  }
  _makeDrawer() {
    return Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 250,
                child: DrawerHeader(
                  child: Column(
                    children: <Widget>[
                      UserProfileWidget(user: widget.user),
                       Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.user.firstName + ' ' + widget.user.lastName, 
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                             widget.user.email,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                    ],
                  ),
                  decoration: BoxDecoration(color: Colors.black12),
                ),
              ),
              ListTile(
                title: Text("Accounts"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => AccountsScreen(user: widget.user,)
                                    ));
                  
                },
              ),
               ListTile(
                title: Text("Transfers"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => TransfersScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)
                                    ));
                  
                },
              ),
               ListTile(
                title: Text("Income"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => IncomeScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)
                                    ));
                  
                },
              ),
               ListTile(
                title: Text("Expenses"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => ExpensesScreen(userID: widget.user.userId, currency: widget.user.defaultCurrency,)
                                    ));
                  
                },
              ),
               ListTile(
                title: Text("Budget"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => BudgetScreen(userID: widget.user.userId, currency: widget.user.currencySymbol,)
                                    ));
                  
                },
              ),
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
  final Trans transaction;
  final User user;

  TransactionCard({this.transaction, this.user});

  @override
  Widget build(BuildContext context) {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
    return Padding(
      padding: EdgeInsets.only(right: 15.0),
      child: Container(
        width: 130.0,
        decoration: BoxDecoration(
            color: transaction.getColor(),
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(transaction.transType,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 5.0),
              Text(clipString(transaction.description, 13)),
              Text(clipString(transaction.notes, 13)),
              Text(DateFormat("dd MMM yyyy").format(transaction.transactionDate.toDate()), style: TextStyle(color: Colors.white),),
              SizedBox(height: 5.0),
              Text(user.currencySymbol + currencyFormatter.format(transaction.transactionAmount),
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
      ),
    );
  }
}

