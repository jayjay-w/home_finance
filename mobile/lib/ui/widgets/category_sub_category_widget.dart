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

  @override
  void initState() {
    categoryID = "";
    subCategoryID = "";
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
            Visibility(visible: widget.categoryId == null, child: Center(child: Text("Tap here to select the category/subcategory", textAlign: TextAlign.center,))),
            Visibility(
              visible: widget.categoryId == null,
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(""),),
                  StreamBuilder<DocumentSnapshot>(
                    stream: categoryRef.document(categoryID).snapshots(),
                    builder: (ctx, doc) {
                      String categoryText = "Category  -  ";
                      if (doc.hasData) {
                        categoryText = doc.data["name"].toString() + " - ";
                      } 
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                        child: Text(categoryText, style: TextStyle(fontSize: 16, color: Colors.purple),),
                    );
                    },
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: subCategoryRef.document(subCategoryID).snapshots(),
                    builder: (ctx, doc) {
                      String subCategoryText = " Sub Category";
                      if (doc.hasData) {
                        subCategoryText = doc.data["name"].toString() + "  ";
                      } 
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                        child: Text(subCategoryText, style: TextStyle(fontSize: 16, color: Colors.purple),),
                    );
                    },
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
            title: Text("Select a sub category"),
            content: _showSubCategoryList(),
            actions: <Widget>[
              FlatButton(
                child: Text("Add New Sub Category"),
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
                      widget.onChanged(categoryID, data.documentID);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                   },
                  title: Text(data["name"], style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(currencyFormatter.format(data["budget"]) + " per month"),
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
                      widget.onChanged(categoryID, null);
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
            title: Text("Select a category"),
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