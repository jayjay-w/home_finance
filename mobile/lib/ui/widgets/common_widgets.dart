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
            FlatButton(
                child: Text("Delete Category", style: TextStyle(color: Colors.red),),
                onPressed: () { _deleteCategory(cat, context); },
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