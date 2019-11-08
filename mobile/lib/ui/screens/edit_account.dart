import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/ui/widgets/currency_dropdown.dart';

class EditAccountScreen extends StatefulWidget {
  final String userId;
  final Account account;

  EditAccountScreen({this.userId, this.account});
  static final String id = 'edit_account';
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  String _accountName, _accountType;
  String _accountBalance;
  DateTime _balanceAsOf;
  String currencyValue = 'USD';


  @override
  void initState() {
    super.initState();
    _accountName = "";
    _accountType = "Cash";
    _accountBalance = "0.00";
    _balanceAsOf = DateTime.now();

    if (widget.account != null) {
      _accountName = widget.account.accountName;
      _accountType = widget.account.accountType;
      _accountBalance = widget.account.balance.toString();
      currencyValue = widget.account.currency;
    }

  }

  _save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Account account;
      account = Account(accountName: _accountName, accountType: _accountType, balance: double.parse(_accountBalance), currency: currencyValue);
      if (widget.account == null) {
         DatabaseService.addAccount(account, widget.userId);
      } else {
         DatabaseService.updateAccount(widget.account.accountId, account, widget.userId);
      }
     
      Navigator.pop(context);
    }
  }
  _onCurrencyChanged(val, symbol) {
    setState(() {
      currencyValue = val;
      print(symbol + ' selected'); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Finance",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        actions: <Widget>[
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () { _save(); },
            child: Text("Save", style: TextStyle(fontSize: 18),),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left:32.0, top: 32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  initialValue: _accountName,
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (input) => _accountName = input,
                ),

                TextFormField(
                  autocorrect: false,
                  initialValue: _accountType,
                  decoration: InputDecoration(labelText: 'Account Type'),
                  onSaved: (input) => _accountType = input,
                ),

                TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  initialValue: _accountBalance.toString(),
                  decoration: InputDecoration(labelText: 'Balance'),
                  onSaved: (input) => _accountBalance = input,
                ),

                Column(
                  children: <Widget>[
                    Text('Currency'),
                    CurrencyDropDown(
                        currencyValue: currencyValue, onChanged: _onCurrencyChanged),
                  ],
                ),
              ]
          )
        ),
      ),
      )
    );
  }
}