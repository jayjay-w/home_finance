import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/widgets/budget_progress.dart';
import 'package:homefinance/ui/widgets/common_widgets.dart';
import 'package:homefinance/ui/widgets/month_selector_widget.dart';
import 'package:intl/intl.dart';

class SubCategoryListScreen extends StatefulWidget {
   static String id = "subcategory_list_screen";
  final String currency;
  final String userID;
  final Category parentCategory;

  SubCategoryListScreen({@required this.currency, this.userID, this.parentCategory});
  @override
  _SubCategoryListScreenState createState() => _SubCategoryListScreenState();
}

class _SubCategoryListScreenState extends State<SubCategoryListScreen> {
  String _editCategoryName;
  double _budget;
  Timestamp _budgetStart;
  final _formKey = GlobalKey<FormState>();
  final catController = TextEditingController();
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
   DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, 1).add(Duration(days: 30));

  @override
  void initState() {
    _editCategoryName = "";
    _budget = 0;
    _budgetStart = Timestamp.fromDate(DateTime.now());
    catController.text = widget.parentCategory.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.parentCategory.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showEditSubCategoryDialog(true, null, widget.parentCategory.id, widget.userID, context);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
              child: MonthSelectorWidget(onChanged: (val) { 
                    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                     _startDate = val; 
                      _endDate = _startDate.add(Duration(days: 30));
                   }));
              },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot> (
                stream: subCategoryRef.where('categoryId', isEqualTo: widget.parentCategory.id).snapshots(),
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
    final subcat = SubCategory.fromDocument(data);

    return  Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: ListTile(
          onTap: () {
            showEditSubCategoryDialog(false, subcat, widget.parentCategory.id, widget.userID, context);
          },
          title: Text(subcat.name),
          subtitle: BudgetProgressWidget(subCategoryId: subcat.id, isCategory: false, monthStart: _startDate, monthEnd: _endDate, categoryId: subcat.categoryId, userId: widget.userID, currencySymbol: widget.currency,),
        ),
      ),
    );
  }
}