import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:intl/intl.dart';

class TransferScreen extends StatefulWidget {
  static final String id = 'transfer';
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  User user;
  final currencyFormatter = new NumberFormat("#,##0.00", "en_US");
  
  Account sourceAccount, destAccount;
  String sourceAccId, destAccId;
  double amount;
  DateTime transferDate;

  @override
  void initState() {
    super.initState();
    amount = 0;
    transferDate = DateTime.now();
    sourceAccId = '';
    destAccId = '';
    //user = StateWidget.of(context).state.user;
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: transferDate,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2100, 12));

    if (picked != null && picked != transferDate) {
      setState(() {
        transferDate = picked;
      });
    }
  }

  _save() {
     if (sourceAccId == destAccId) {
                Flushbar(
                  title: "Error",
                  message: "Source and destination accounts should be different",
                  duration: Duration(seconds: 5),
                )..show(context);
                return;
              }

              DatabaseService.transferMoney(StateWidget.of(context).state.user.userId, sourceAccId, destAccId, Timestamp.fromDate(transferDate), amount);
              Navigator.pop(context);
              Flushbar(
                  title: "Transfer complete",
                  message: "Transferred " + currencyFormatter.format(amount) + ".",
                  duration: Duration(seconds: 5),
                )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer Money"),
        actions: <Widget>[
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () { _save(); }, 
            child: Text("Save", style: TextStyle(fontSize: 18),),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.document(StateWidget.of(context).state.user.userId).collection('accounts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          } else {
            List<DropdownMenuItem> accountItems = [];
            for (int i = 0; i< snapshot.data.documents.length; i++) {
              Account acc = Account.fromDocument(snapshot.data.documents[i]);
              
              accountItems.add(
                DropdownMenuItem(
                  child: Text(
                    acc.accountName,
                  ),
                  value: acc.accountId,
                )
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  DropdownButton(
                      items: accountItems,
                      hint: Text('Source Account'),
                      value: sourceAccId.isEmpty ? null : sourceAccId,
                      isExpanded: true,
                      onChanged: (index) { 
                        setState(() {
                          sourceAccId = index;
                        });
                       }, 
                    ),
                    DropdownButton(
                      items: accountItems,
                      hint: Text('Target Account'),
                      value: destAccId.isEmpty ? null : destAccId,
                      isExpanded: true,
                      onChanged: (index) { 
                        setState(() {
                          destAccId = index;
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
                                      .format(transferDate))),
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
                    TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (input) { setState(() {
                        amount = double.parse(input);
                      }); },
                      decoration: InputDecoration(hintText: "Amount"),
                    ),
                ],
              ),
            );

          }
        },
      )
    );
  }
}