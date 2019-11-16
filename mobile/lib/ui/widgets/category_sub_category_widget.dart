import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class CategoryAndSubCategorySelector extends StatefulWidget {
  final String categoryId;
  final String subcategoryId;
  final Function onChanged;
  final String userId;


  CategoryAndSubCategorySelector({
      this.subcategoryId, 
      this.categoryId,
      this.onChanged,
      this.userId
    });

  @override
  _CategoryAndSubCategorySelectorState createState() => _CategoryAndSubCategorySelectorState();
}

class _CategoryAndSubCategorySelectorState extends State<CategoryAndSubCategorySelector> {
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  String categoryID = "";
  String subCategoryID = "";
  String categoryName = "";
  String subCategoryName = "";

  @override
  void initState() {
    categoryID = widget.categoryId;
    subCategoryID = widget.subcategoryId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {  _showCategorySelector(); } ,
          child: Container(
        decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.1),
                borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: <Widget>[
            Visibility(visible: true, child: Center(child: Text("Tap here to select the category/subcategory", textAlign: TextAlign.center,))),
            Visibility(
              visible: true,
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(""),),
                  categoryID == null ? Text("") :
                      categoryID == "" ? Text("") :
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.1),
                              borderRadius: BorderRadius.circular(6)),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: categoryRef.document(categoryID).snapshots(),
                                builder: (context, catDoc) {
                                  String catName = "Select Category";
                                  if (catDoc.hasData) {
                                    catName = catDoc.data["name"];
                                  } 
                                  return Text(catName, style: TextStyle(fontSize: 16, color: Colors.purple),);
                                },
                              ),
                          ),
                          Text("   "),
                  subCategoryID== null ? Text("") :
                      subCategoryID == "" ? Text("") :
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.1),
                              borderRadius: BorderRadius.circular(6)),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: subCategoryRef.document(subCategoryID).snapshots(),
                                builder: (context, subCatDoc) {
                                  String subCatName = "Select Subcategory";
                                  if (subCatDoc.hasData) {
                                    subCatName = subCatDoc.data["name"];
                                  } 
                                  return Text(subCatName, style: TextStyle(fontSize: 16, color: Colors.indigo),);
                                },
                              ),
                          ),
                  Expanded(child: Text(""),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _showSubCategorySelector() {
    showDialog(
        context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text("2. Select a sub category"),
            content: _showSubCategoryList(),
            actions: <Widget>[
              FlatButton(
                child: Text("Add New Sub Category"),
                onPressed: () { 
                      showEditSubCategoryDialog(true, null, categoryID, widget.userId, context);
                  },
              ),
              FlatButton(
                onPressed: () { Navigator.pop(context); },
                child: Text("Cancel"),
              )
            ],
          );
        }
      );
  }

  _showSubCategoryList() {
    return StreamBuilder<QuerySnapshot>(
        stream: subCategoryRef.where('categoryId', isEqualTo: categoryID).snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
          List<DocumentSnapshot> docs = snapshot.data.documents;
          return Container(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              padding: EdgeInsets.all(2.0),
              children: docs.map((data) => Card(
                child: ListTile(
                  //leading:  Icon(Icons.check_circle, size: 24, color: categoryID == data.documentID ? Colors.green : Colors.grey,),
                  onTap: () { 
                    setState(() {
                      subCategoryID = data.documentID;
                      subCategoryName = data.data["name"];
                      widget.onChanged(categoryID, data.documentID, categoryName, subCategoryName);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                   },
                  title: Text(data["name"], style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(currencyFormatter.format(data["budget"]) + " per month"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () { 
                      showEditSubCategoryDialog(false, SubCategory.fromDocument(data), categoryID, widget.userId, context);
                      },
                  ),
                ),
                ) ).toList(),
            ),
          );
        },
      );
  }

  _showCategoryList() {
    return StreamBuilder<QuerySnapshot>(
        stream: categoryRef.where('owner', isEqualTo: widget.userId).snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
          List<DocumentSnapshot> docs = snapshot.data.documents;
          return Container(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              padding: EdgeInsets.all(2.0),
              children: docs.map((data) => Card(
                child: ListTile(
                  //leading:  Icon(Icons.check_circle, size: 24, color: categoryID == data.documentID ? Colors.green : Colors.grey,),
                  onTap: () { 
                    setState(() {
                      categoryID = data.documentID;
                      categoryName = data.data["name"];
                      _showSubCategorySelector();
                    });
                   },
                  title: Text(data["name"], style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: subCategoryRef.where('categoryId', isEqualTo: data.documentID).snapshots(),
                    builder: (ctx, snp) {
                      double budgetTotal = 0;
                      int subCount = 0;
                      if (snp.hasData) {
                        for (DocumentSnapshot dc in snp.data.documents) {
                          budgetTotal += dc["budget"];
                          subCount += 1;
                        }
                      }
                      if (subCount < 1) {
                        return Text("No subcategories");
                      }
                      return Text(currencyFormatter.format(budgetTotal) + " in " + subCount.toString() + " subcategories");
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () { showEditCategoryDialog(false, Category.fromDocument(data), context, widget.userId); },
                  ),
                ),
                ) ).toList(),
            ),
          );
        },
      );
  }

  _showCategorySelector() {
      showDialog(
        context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text("1: Select a category"),
            content: _showCategoryList(),
            actions: <Widget>[
              FlatButton(
                child: Text("Add New Category"),
                onPressed: () { showEditCategoryDialog(true, null, context, widget.userId); },
              ),
              FlatButton(
                onPressed: () { Navigator.pop(context); },
                child: Text("Cancel"),
              )
            ],
          );
        }
      );
  }
}