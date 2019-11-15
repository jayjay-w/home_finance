import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
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

  @override
  void initState() {
    _editCategoryName = "";
    _budget = 0;
    _budgetStart = Timestamp.fromDate(DateTime.now());
    catController.text = widget.parentCategory.name;
    super.initState();
  }

  _showEditDialog(bool isNew, Category cat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Subcategory"),
          content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  initialValue: _editCategoryName,
                  decoration: InputDecoration(labelText: 'Category Name'),
                  validator: (input) => input.length < 2 ? 'Enter a category name' : null,
                  onSaved: (input) => _editCategoryName = input,
                ),
                TextFormField(
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  initialValue: currencyFormatter.format(_budget),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Monthly Budget'),
                  validator: (input) => input.length < 2 ? 'Enter the monthly limit for this item' : null,
                  onSaved: (input) => _budget = double.parse(input),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () { Navigator.pop(context); },
            ),
            FlatButton(
              child: Text("Yes", style: TextStyle(color: Colors.red),),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  DatabaseService.addSubCategory(widget.parentCategory, SubCategory(name: _editCategoryName, budget: _budget), widget.userID);
                  setState(() {
                    _editCategoryName = "";
                  });
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      }
    );
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
              _showEditDialog(true, null);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: catController,
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    widget.parentCategory.name = catController.text;
                    DatabaseService.UpdateCategory(widget.parentCategory);
                  },
                  child: Icon(Icons.check, color: Colors.green,),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: subCategoryRef.where('categoryId', isEqualTo: widget.parentCategory.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) { return Center(child: CircularProgressIndicator(),); }
                return _buildList(context, snapshot.data.documents);
              },
            ),
          ),
        ],
      ),
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

    return  Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(subcat.name, style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),

              // Text(cat.order.toString()),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12,), onPressed: () { /* edit subcategory */ } ,
              )
            ],
          ),
        ),
        Divider(height: 0.2,)
      ],
    );
  }
}