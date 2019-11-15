import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/screens/subcategory_list.dart';

class CategoryListScreen extends StatefulWidget {
   static String id = "category_list_screen";
  final String currency;
  final String userID;

  CategoryListScreen({@required this.currency, this.userID});
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _editCategoryName;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _editCategoryName = "";
    super.initState();
  }

  _showEditDialog(bool isNew, Category cat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Category"),
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
                  DatabaseService.AddCategory(Category(name: _editCategoryName), widget.userID);
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
        title: Text("Categories"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showEditDialog(true, null);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryRef.where('owner', isEqualTo: widget.userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) { return Center(child: CircularProgressIndicator(),); }
          return _buildList(context, snapshot.data.documents);
        },
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
    final cat = Category.fromDocument(data);

    return  GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SubCategoryListScreen(userID: widget.userID, currency: widget.currency, parentCategory: cat,)
                      ));
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold),),
                        StreamBuilder<QuerySnapshot> (
                          stream: subCategoryRef.where('categoryId', isEqualTo: cat.id).snapshots(),
                          builder: (context, snapshot) {
                            int subCategoryCount = 0;
                            if (snapshot.hasData) {
                              subCategoryCount = snapshot.data.documents.length;
                            }
                            return Text("$subCategoryCount subcategories", style: TextStyle(fontSize: 12));
                          },
                        ),
                      ],
                    ),
                  ),

                  // Text(cat.order.toString()),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12,)
                ],
              ),
            ),
            Divider(height: 0.2,)
          ],
        ),
    );
  }
}