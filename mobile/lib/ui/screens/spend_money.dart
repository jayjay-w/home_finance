import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/widgets/category_sub_category_widget.dart';
import 'package:intl/intl.dart';

class SpendMoneyScreen extends StatefulWidget {
  final String currency;
  final String userID;
  Trans transaction;

  SpendMoneyScreen({@required this.currency, this.userID, this.transaction});

  static final String id = 'spend_money';
  @override
  _SpendMoneyScreenState createState() => _SpendMoneyScreenState();
}

class _SpendMoneyScreenState extends State<SpendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description;
  String _accountId;
  DateTime _expenseDate;
  String _notes;
  double _amount;

  String _transactionId;
  bool isEditing = false;

  String _categoryID, _subCategoryId;

  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    _description = "";
    _notes = "";
    _expenseDate = DateTime.now();
    _amount = 0.00;
    _categoryID = "";
    _subCategoryId = "";

    if (widget.transaction != null) {
      isEditing = true;
      _transactionId = widget.transaction.id;
      _accountId = widget.transaction.debitAccountId;
      _description = widget.transaction.description;
      _notes = widget.transaction.notes;
      _expenseDate = widget.transaction.transactionDate.toDate();
      _amount = widget.transaction.transactionAmount;
      _categoryID = widget.transaction.categoryId;
      _subCategoryId = widget.transaction.subCategoryId;
    }

    super.initState();
  }

  _delete() {
    if (isEditing)  {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this transaction? This action cannot be undone"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () { Navigator.pop(context); },
              ),
              FlatButton(
                child: Text("Yes", style: TextStyle(color: Colors.red),),
                onPressed: () {
                  if (isEditing) DatabaseService.deleteTransaction(widget.userID, widget.transaction);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
    }
  }

  _save() {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    if (_accountId.trim().length < 1) {
      Flushbar(
        title: "Error",
        message: "Select an account",
        duration: Duration(seconds: 3),
      ).show(context);
      return;
    }
    if (_description.trim().length < 1) {
      Flushbar(
        title: "Error",
        message: "Please describe this expense",
        duration: Duration(seconds: 3),
      ).show(context);
      return;
    }

    if (isEditing) {
      DatabaseService.deleteTransaction(widget.userID, widget.transaction);
    }

    DatabaseService.spendMoney(
        widget.userID,
        _description,
        _notes,
        Timestamp.fromDate(_expenseDate),
        _amount,
        _accountId,
        widget.currency,
        _categoryID,
        _subCategoryId
        );

    Navigator.pop(context);

    Flushbar(
      title: "Expense recorded",
      message: "Spent " + currencyFormatter.format(_amount) + ".",
      duration: Duration(seconds: 5),
    )..show(context);

  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _expenseDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12));

    if (picked != null && picked != _expenseDate) {
      setState(() {
        _expenseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: primaryColor,
          title: Text("Expense"),
          actions: <Widget>[
            FlatButton(
                color: primaryColor,
                textColor: Colors.white,
                child: Text("Save"),
                onPressed: () {
                  _save();
                }),
                Visibility(
                  visible: isEditing,
                  child: FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("Delete"),
                  onPressed: () {
                    _delete();
                  }),
                )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: accountsRef.where('uid', isEqualTo: widget.userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List<DropdownMenuItem> accountItems = [];
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  Account acc =
                      Account.fromDocument(snapshot.data.documents[i]);

                  accountItems.add(DropdownMenuItem(
                    child: Text(
                      acc.accountName,
                    ),
                    value: acc.accountId,
                  ));
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        CategoryAndSubCategorySelector(
                          categoryId: _categoryID,
                          subcategoryId: _subCategoryId,
                          onChanged: (catId, subCatId, catName, subCatName) {
                            setState(() {
                              _categoryID = catId;
                              _subCategoryId = subCatId;
                              _description = catName + "/" + subCatName;
                            });
                          },
                          userId: widget.userID,
                          ),
                        //  Text(_categoryID),
                        //  Text(_subCategoryId),
                        // TextFormField(
                        //   autocorrect: false,
                        //   initialValue: _description,
                        //   decoration:
                        //       InputDecoration(labelText: 'Description'),
                        //   validator: (input) => input.length < 2
                        //       ? 'Where was this money spent?'
                        //       : null,
                        //   onSaved: (input) {
                        //     setState(() {
                        //       _description = input;
                        //     });
                        //   },
                        // ),
                        TextFormField(
                          autocorrect: false,
                          initialValue: _notes,
                          decoration:
                              InputDecoration(labelText: 'Notes'),
                          onSaved: (input) {
                            setState(() {
                              _notes = input;
                            });
                          },
                        ),
                        DropdownButton(
                          items: accountItems,
                          hint: Text('Source Account'),
                          value: _accountId == null || _accountId.isEmpty
                              ? null
                              : _accountId,
                          isExpanded: true,
                          onChanged: (index) {
                            setState(() {
                              _accountId = index;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Row(
                            children: <Widget>[
                              Text("Date:"),
                              Expanded(
                                  child: Text(DateFormat("dd MMM yyyy")
                                      .format(_expenseDate))),
                              FlatButton(
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _selectDate(context),
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: _amount.toString(),
                          onChanged: (input) {
                            setState(() {
                              _amount = double.parse(input);
                            });
                          },
                          //validator: (value) => Validator.validateNumber(value),
                          decoration: InputDecoration(hintText: "Amount"),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }));
  }
}