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

  _deleteSubcategory(SubCategory subcat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete " + subcat.name + "?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () { Navigator.pop(context); },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                DatabaseService.deleteSubCategory(subcat);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  _showEditDialog(bool isNew, SubCategory subcat) {
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
                  initialValue: isNew ? "" : subcat.name,
                  decoration: InputDecoration(labelText: 'Subcategory Name'),
                  validator: (input) => input.length < 2 ? 'Enter a category name' : null,
                  onSaved: (input) => _editCategoryName = input,
                ),
                TextFormField(
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  initialValue: isNew ? "0.00" : subcat.budget.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Monthly Budget'),
                  validator: (input) => double.parse(input) < 0 ? 'Enter the monthly limit for this item' : null,
                  onSaved: (input) { _budget = double.parse(input); },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text("Delete Subcategory"),
                onPressed: () { _deleteSubcategory(subcat); },
            ),           
            FlatButton(
              child: Text("Cancel"),
              onPressed: () { Navigator.pop(context); },
            ),
            FlatButton(
              child: Text("Save", style: TextStyle(color: Colors.red),),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  if (isNew) {
                    DatabaseService.addSubCategory(widget.parentCategory, SubCategory(name: _editCategoryName, budget: _budget), widget.userID);
                  } else {
                    subcat.name = _editCategoryName;
                    subcat.budget = _budget;
                    DatabaseService.updateSubCategory(subcat);
                  }
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

    return  ListTile(
      onTap: () {
        _showEditDialog(false, subcat);
      },
      title: Text(subcat.name),
      subtitle: Text(widget.currency + currencyFormatter.format(subcat.budget) + "/month"),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}