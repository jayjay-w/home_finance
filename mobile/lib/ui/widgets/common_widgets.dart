import 'package:flutter/material.dart';
import 'package:homefinance/models/category.dart';
import 'package:homefinance/services/database_service.dart';

showEditCategoryDialog(bool isNew, Category cat, BuildContext context, String userId) {
    String _editCategoryName;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Category"),
          content: Container(
            height: 100,
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    initialValue: isNew ? "" : cat.name,
                    decoration: InputDecoration(labelText: 'Category Name'),
                    validator: (input) => input.length < 2 ? 'Enter a category name' : null,
                    onSaved: (input) { isNew? _editCategoryName = input : cat.name = input; _editCategoryName = input; },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Visibility(
              visible: !isNew,
              child: FlatButton(
                  child: Text("Delete Category", style: TextStyle(color: Colors.red),),
                  onPressed: () { _deleteCategory(cat, context); },
              ),
            ), 
            FlatButton(
              child: Text("Cancel"),
              onPressed: () { Navigator.pop(context); },
            ),
            FlatButton(
              child: Text("Save", style: TextStyle(color: Colors.green),),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  isNew ? DatabaseService.AddCategory(Category(name: _editCategoryName), userId) : 
                     DatabaseService.UpdateCategory(cat) ;
                    _editCategoryName = "";
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      }
    );
  }

  _deleteCategory(Category cat, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete " + cat.name + "?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () { Navigator.pop(context); },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                DatabaseService.DeleteCategory(cat);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }


  _deleteSubcategory(SubCategory subcat, BuildContext context) {
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

  showEditSubCategoryDialog(bool isNew, SubCategory subcat, String parentCategoryId, String userId, BuildContext context) {
    String _editCategoryName = "";
    final _formKey = GlobalKey<FormState>();
    double _budget = 0.00;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: isNew ? Text("New Subcategory") : Text(subcat.name),
          content: Container(
            height: 150,
            child: Form(
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
          ),
          actions: <Widget>[
            Visibility(
              visible: !isNew,
              child: FlatButton(
                  child: Text("Delete Subcategory"),
                  onPressed: () { _deleteSubcategory(subcat, context); },
              ),
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
                    DatabaseService.addSubCategory(parentCategoryId, SubCategory(name: _editCategoryName, budget: _budget), userId);
                  } else {
                    subcat.name = _editCategoryName;
                    subcat.budget = _budget;
                    DatabaseService.updateSubCategory(subcat);
                  }
                    _editCategoryName = "";
                    _budget = 0.00;
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      }
    );
  }
