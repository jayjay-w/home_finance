
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/user.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:homefinance/ui/widgets/currency_dropdown.dart';

class EditAccountScreen extends StatefulWidget {
  final User user;
  final Account account;

  EditAccountScreen({this.user, this.account});
  static final String id = 'edit_account';
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isEditing = false;

  String _accountName, _accountType;
  String _accountBalance;
  String currencyValue;
  List<String> _accountTypes = Account.accountTypes();
  List<DropdownMenuItem<String>> _dropDownMenuItems;



  @override
  void initState() {
    super.initState();
    _accountName = "";
    _accountType = "Cash";
    _accountBalance = "0.00";
    _accountType = _accountTypes[0];
    _dropDownMenuItems = buildAccountTypeDropdown();
    currencyValue = widget.user.defaultCurrency;

    if (widget.account != null) {
      _accountName = widget.account.accountName;
      _accountType = widget.account.accountType;
      _accountBalance = widget.account.openingBalance.toString();
      currencyValue = widget.account.currency;
      isEditing = true;
    }

  }

  List<DropdownMenuItem<String>> buildAccountTypeDropdown() {
    List<DropdownMenuItem<String>> items = List();
    for (String str in _accountTypes) {
        items.add(
          DropdownMenuItem(
            value: str, child: Text(str), 
          ),
        );
    }

    return items;
  }

  _save() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Account account;
      account = Account(uid: widget.user.userId, accountName: _accountName, accountType: _accountType, openingBalance: double.parse(_accountBalance), currency: currencyValue, dateCreated: Timestamp.now());
       if (!isEditing) {
          account.currentBalance = double.parse(_accountBalance);
          account.allDebits = 0.00;
          account.allCredits = 0.00;
          DatabaseService.addAccount(account, widget.user.userId);
       } else {
          widget.account.accountName = _accountName;
          widget.account.accountType = _accountType;
          DatabaseService.updateAccount(widget.account.accountId, widget.account, widget.user.userId);
       }
     
      Navigator.pop(context);
    }
  }
  _onCurrencyChanged(val, symbol) {
    setState(() {
      currencyValue = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Account Details",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        actions: <Widget>[
          FlatButton(
            color: primaryColor,
            textColor: Colors.white,
            onPressed: () { _save(); },
            child: Text("Save", style: TextStyle(fontSize: 18),),
          ),
          FlatButton(
            color: Colors.red,
            textColor: Colors.white,
            onPressed: () { _save(); },
            child: Text("Delete", style: TextStyle(fontSize: 18),),
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
                  textCapitalization: TextCapitalization.words,
                  initialValue: _accountName,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (input) => input.length < 2 ? 'Enter an account name' : null,
                  onSaved: (input) => _accountName = input,
                ),

                Row(
                  children: <Widget>[
                    Text("Account Type: "),
                    DropdownButton(
                  items: _dropDownMenuItems, 
                  elevation: 16,
                  style: TextStyle(
                    color: Colors.blue
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.blueAccent,
                  ),
                  value: _accountType, 
                  onChanged: (string) { setState(() {
                    _accountType = string; 
                  }); },),
                  ],
                ),
              

                Visibility(
                  visible: !isEditing,
                  child: TextFormField(
                    
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    initialValue: _accountBalance.toString(),
                    decoration: InputDecoration(labelText: 'Balance'),
                    onSaved: (input) => _accountBalance = input,
                  ),
                ),

                Visibility(
                  visible: !isEditing,
                  child: Column(
                    children: <Widget>[
                      Text('Currency'),
                      CurrencyDropDown(
                          currencyValue: currencyValue, onChanged: _onCurrencyChanged),
                    ],
                  ),
                ),
              ]
          )
        ),
      ),
      )
    );
  }
}