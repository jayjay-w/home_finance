import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BudgetProgressWidget extends StatefulWidget {
  final String categoryId;
  final DateTime monthStart;
  final DateTime monthEnd;
  final String userId;
  final String currencySymbol;
  final bool isCategory;
  final String subCategoryId;


  BudgetProgressWidget({
    this.categoryId,
    this.monthEnd,
    this.monthStart,
    this.currencySymbol,
    this.userId,
    this.isCategory,
    this.subCategoryId
  });

  @override
  _BudgetProgressWidgetState createState() => _BudgetProgressWidgetState();
}

class _BudgetProgressWidgetState extends State<BudgetProgressWidget> {
   final currencyFormatter = new NumberFormat("#,##0.00", "en_US");

    double _transTotal = 0.00;
    double _budgetTotal = 0.00;


    @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LinearPercentIndicator(
                    width: 100,
                      lineHeight: 8.0,
                      percent: 1 - (_getPercValue() / 100),
                      backgroundColor: Colors.black12,
                      progressColor: _getPercValue() > 75 ? Colors.red 
                                    : _getPercValue() > 50 ? Colors.orange
                                    : _getPercValue() > 25 ? Colors.blue
                                    : Colors.green,
                    ),
                  Text("  " + widget.currencySymbol + currencyFormatter.format(_getBalamce())),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                  stream: subCategoryRef.where('categoryId', isEqualTo: widget.categoryId).snapshots()
                  ,
                  builder: (context, subCatSnaps) {
                    double budgetTotal = 0.00;
                    if (subCatSnaps.hasData) {

                      for (DocumentSnapshot doc in subCatSnaps.data.documents) {
                        if (widget.isCategory) { 
                          budgetTotal += doc.data["budget"];
                        } else {
                          if (doc.documentID == widget.subCategoryId) {
                            budgetTotal += doc.data["budget"];
                          }
                        }
                      }
                    }
                    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                     _budgetTotal = budgetTotal;
                   }));
                    
                    return Text(widget.currencySymbol +currencyFormatter.format(budgetTotal),  textAlign: TextAlign.right, );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: widget.isCategory ? transactionRef
                          .where('categoryId', isEqualTo: widget.categoryId)
                          .where('transactionDate', isGreaterThanOrEqualTo: widget.monthStart, isLessThan: widget.monthEnd)
                          .snapshots()
                          
                          :

                          transactionRef
                          .where('subCategoryId', isEqualTo: widget.subCategoryId)
                          .where('transactionDate', isGreaterThanOrEqualTo: widget.monthStart, isLessThan: widget.monthEnd)
                          .snapshots()
                          ,
                    builder: (context, catSnaps) {
                      double transTotal = 0;
                      if (catSnaps.hasData) {
                        for (DocumentSnapshot doc in catSnaps.data.documents) {
                          transTotal += doc.data["transactionAmount"];
                        }
                      }
                     SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                       _transTotal = transTotal;
                     }));
                       
                      return Text(widget.currencySymbol + currencyFormatter.format(transTotal),   textAlign: TextAlign.right );
                    },
                  ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }


  _getBalamce() {
    return _budgetTotal - _transTotal;
  }
  _getPercValue() {
    double perc = 0.00;
    if (_budgetTotal > 0) {
      perc = _transTotal / _budgetTotal * 100;
    }
    return perc.round();
  }

  _getPerc() {
    return _getPercValue().toString() + "%";
  }
}