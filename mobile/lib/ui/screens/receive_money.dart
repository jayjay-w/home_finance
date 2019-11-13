import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:intl/intl.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  static final String id = 'receive_money';

  final String currency;
  final String userID;
  final Trans transaction;

  ReceiveMoneyScreen({this.currency, this.userID, this.transaction});

  @override
  _ReceiveMoneyScreenState createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description;
  String _accountId;
  DateTime _incomeDate;
  String _notes;
  double _amount;
  String _transactionId;

  bool isEditing = false;

  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _description = "";
    _notes = "";
    _incomeDate = DateTime.now();
    _amount = 0.00;

    if (widget.transaction != null) {
      isEditing = true;
      _description = widget.transaction.description;
      _accountId = widget.transaction.creditAccountId;
      _notes = widget.transaction.notes;
      _transactionId = widget.transaction.id;
      _amount = widget.transaction.transactionAmount;
      _incomeDate = widget.transaction.transactionDate.toDate();
      print (widget.transaction.id);
    }
  }

  _delete() {
    if (isEditing) DatabaseService.deleteTransaction(widget.userID, widget.transaction);
    Navigator.pop(context);
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
        message: "Please describe this income",
        duration: Duration(seconds: 3),
      ).show(context);
      return;
    }

    if (isEditing) DatabaseService.deleteTransaction(widget.userID, widget.transaction);

    DatabaseService.receiveMoney(
        widget.userID,
        _description,
        _notes,
        Timestamp.fromDate(_incomeDate),
        _amount,
        _accountId);

    Navigator.pop(context);

    Flushbar(
      title: "Income recorded",
      message: "Received " + currencyFormatter.format(_amount) + ".",
      duration: Duration(seconds: 5),
    )..show(context);

  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _incomeDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12));

    if (picked != null && picked != _incomeDate) {
      setState(() {
        _incomeDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: primaryColor,
          title: Text("Receive Money"),
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
                ),
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
                        TextFormField(
                          autocorrect: false,
                          initialValue: _description,
                          decoration:
                              InputDecoration(labelText: 'Received From...'),
                          validator: (input) => input.length < 2
                              ? 'Enter the source of this income'
                              : null,
                          onSaved: (input) {
                            setState(() {
                              _description = input;
                            });
                          },
                        ),
                        TextFormField(
                          autocorrect: false,
                          initialValue: _notes,
                          decoration:
                              InputDecoration(labelText: 'Description...'),
                          validator: (input) => input.length < 2
                              ? 'Enter a brief description of this income'
                              : null,
                          onSaved: (input) {
                            setState(() {
                              _notes = input;
                            });
                          },
                        ),
                        DropdownButton(
                          items: accountItems,
                          hint: Text('Destination Account'),
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
                                      .format(_incomeDate))),
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