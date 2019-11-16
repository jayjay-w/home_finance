import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:intl/intl.dart';

class BudgetProgressWidget extends StatefulWidget {
  final String categoryId;
  final DateTime monthStart;
  final DateTime monthEnd;
  final String userId;
  final String currencySymbol;


  BudgetProgressWidget({
    this.categoryId,
    this.monthEnd,
    this.monthStart,
    this.currencySymbol,
    this.userId
  });

  @override
  _BudgetProgressWidgetState createState() => _BudgetProgressWidgetState();
}

class _BudgetProgressWidgetState extends State<BudgetProgressWidget> {
   final currencyFormatter = new NumberFormat("#,##0.00", "en_US");

    double _transTotal;
    double _budgetTotal;
   bool isLoading = true;

    @override
    void initState() {
    _transTotal = 0.00;
    _budgetTotal = 0.00;
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(widget.currencySymbol + " "),
          StreamBuilder<QuerySnapshot>(
            stream: transactionRef
                  .where('categoryId', isEqualTo: widget.categoryId)
                  .where('transactionDate', isGreaterThanOrEqualTo: widget.monthStart, isLessThan: widget.monthEnd)
                  .snapshots(),
            builder: (context, catSnaps) {
              double transTotal = 0;
              if (catSnaps.hasData) {
                for (DocumentSnapshot doc in catSnaps.data.documents) {
                  transTotal += doc.data["transactionAmount"];
                }
              }
               if (!isLoading) {
              // setState(() {
              //   _transTotal = transTotal;
              // });
               }
              return Text(currencyFormatter.format(transTotal));
            },
          ),
          Text("/"),
          StreamBuilder<QuerySnapshot>(
            stream: subCategoryRef.where('categoryId', isEqualTo: widget.categoryId).snapshots(),
            builder: (context, subCatSnaps) {
              double budgetTotal = 0.00;
              if (subCatSnaps.hasData) {
                for (DocumentSnapshot doc in subCatSnaps.data.documents) {
                  budgetTotal += doc.data["budget"];
                }
              }
              if (!isLoading) {
              // setState(() {
              //    _budgetTotal = budgetTotal;
              // });
              }
              return Text(currencyFormatter.format(budgetTotal));
            },
          ),
          Text(" "),
        ],
      ),
    );
  }

  _getPerc() {
    double perc = 0;
    if (_budgetTotal > 0) {
      perc = _transTotal / _budgetTotal * 100;
    }
    return perc.toString() + "%";
  }
}