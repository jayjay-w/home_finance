import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/receive_money.dart';
import 'package:homefinance/ui/widgets/month_selector_widget.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  static final String id = "income";
  final String currency;
  final String userID;

  IncomeScreen({@required this.currency, this.userID});

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
   DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, 1).add(Duration(days: 30));
  bool stateLoading = true;

  @override
  void initState() {
    super.initState();
    stateLoading = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Income"),
        actions: <Widget>[
          FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ReceiveMoneyScreen(userID: widget.userID, currency: widget.currency,)
              ));
            },)
        ],
      ),
      body: Column(
        children: <Widget>[
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
          Expanded(
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                          stream: transactionRef
                            .where('owner', isEqualTo: widget.userID)
                            .where('transType', isEqualTo: 'Income')
                            .where('transactionDate', isGreaterThanOrEqualTo: _startDate,isLessThan:  _endDate)
                            .orderBy('transactionDate').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return _buildList(context, snapshot.data.documents);
                              //return Text("");
                            }
                          },
                      ),
            ),
          ),
         
        ],
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
                  builder: (_) => ReceiveMoneyScreen(userID: widget.userID, transaction: trans, currency: widget.currency,)
              ));
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
                              stream: accountsRef.document(trans.creditAccountId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
                                return Text(" " + snapshot.data["accountName"].toString());
                              },
                            ),
                            Text(" " + trans.notes),
                            Text(DateFormat("dd MMM yyyy").format(trans.transactionDate.toDate()))
                          ],
                        ),
                      ),
                      Text( widget.currency + " " + currencyFormatter.format(trans.transactionAmount), style: TextStyle(color: Colors.green)),
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