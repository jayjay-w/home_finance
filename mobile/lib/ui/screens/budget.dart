import 'package:flutter/material.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/category_list.dart';
import 'package:homefinance/ui/widgets/month_selector_widget.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  static String id = "budget_screen";
  final String currency;
  final String userID;

  BudgetScreen({@required this.currency, this.userID});
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
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
        title: Text("Budget"),
        actions: <Widget>[
          FlatButton(child: Icon(Icons.edit, size: 32, color: Colors.white,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CategoryListScreen(userID: widget.userID, currency: widget.currency,)
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
            Expanded(child: Center(child: Text("Budget")),)
          ]
        )
      );
  }
}