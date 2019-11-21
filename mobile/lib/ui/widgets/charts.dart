import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_charts/flutter_charts.dart' as chart;
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ExpenseProgressWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String userId;

  ExpenseProgressWidget(
    this.startDate, 
    this.endDate, 
    this.userId
    );
  @override
  _ExpenseProgressWidgetState createState() => _ExpenseProgressWidgetState();
}

class _ExpenseProgressWidgetState extends State<ExpenseProgressWidget> {
  double _totalExpenses = 0.00;

  void getTotalExpenses() async {
    double val = 0.00;
    val = await DatabaseService.getTotalExpensesInDateRange(widget.userId, widget.startDate, widget.endDate);
     SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
        _totalExpenses = val;
     }));
  }

  @override
  void initState()  {
    super.initState();    
    getTotalExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text("Expenses by category", style: boldGrey,),
        ),
        Expanded(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: categoryRef.where('owner', isEqualTo: widget.userId).snapshots(),
                  builder: (context, catSnap) {
                    if (!catSnap.hasData) {
                      return Center(child: CircularProgressIndicator(),);
                    }  else {
                      return 
                      _buildList(context, catSnap.data.documents);
                    }
                  },
                ),
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final cat = Category.fromDocument(data);
    final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
    
    return Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: transactionRef.where('owner', isEqualTo: widget.userId)
                                      .where('categoryId', isEqualTo: cat.id)
                                      .where('transactionDate', isGreaterThanOrEqualTo: widget.startDate, isLessThan: widget.endDate)
                                      .snapshots(),
                builder: (context, transSnap) {
                  if (!transSnap.hasData) { return Center(child: CircularProgressIndicator(),); }
                  double catTotal = 0.00;
                  for (DocumentSnapshot doc in transSnap.data.documents) {
                    catTotal += doc.data["transactionAmount"];
                  }
                  double perc = 0.00;
                  if (_totalExpenses > 0) {
                    perc = (((catTotal / _totalExpenses) * 100));
                  } 
                  return LinearPercentIndicator(
                      percent: perc / 100,
                      lineHeight: 40,
                      center: Text(cat.name + " " + (catTotal > 0 ? perc.roundToDouble().toString() + "% ("  + currencyFormatter.format(catTotal) + ")": " 0%"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    );
                },
              )
              // child: 
            ),
          )
        ],
    );
  }
}