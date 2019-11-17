import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/category_list.dart';
import 'package:homefinance/ui/screens/subcategory_list.dart';
import 'package:homefinance/ui/widgets/budget_progress.dart';
import 'package:homefinance/ui/widgets/common_widgets.dart';
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
          FlatButton(child: Icon(Icons.add, size: 32, color: Colors.white,), onPressed: () {
             showEditCategoryDialog(true, null, context, widget.userID);
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
              child: StreamBuilder<QuerySnapshot> (
                stream: categoryRef.where('owner', isEqualTo: widget.userID).snapshots(),
                builder: (context, snapshot) {
                if (!snapshot.hasData) { return Center(child: CircularProgressIndicator(),); }
                 return _buildList(context, snapshot.data.documents);
                },
              )
            )
          ]
        )
      );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {    
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
          ),
        ),
      ],
    );
  }

  

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final cat = Category.fromDocument(data);
    return  Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                                          builder: (BuildContext context) => SubCategoryListScreen(userID: widget.userID, currency: widget.currency, parentCategory: cat),
                                        ));
          },
          title: Text(cat.name),
          subtitle: BudgetProgressWidget(monthStart: _startDate, monthEnd: _endDate, categoryId: cat.id, userId: widget.userID, currencySymbol: widget.currency,),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () { showEditCategoryDialog(false, cat, context, widget.userID); }),
        ),
      ),
    );    
  }
}