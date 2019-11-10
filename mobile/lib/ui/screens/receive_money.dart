import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homefinance/services/database_service.dart';
import 'package:homefinance/util/state_widget.dart';
import 'package:homefinance/util/validator.dart';
import 'package:intl/intl.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  static final String id = 'receive_money';
  @override
  _ReceiveMoneyScreenState createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description = "Test";
  String _accountId = "";
  DateTime _incomeDate = DateTime.now();
  String _notes = "Notes";
  double _amount = 0.00;

  @override
  void initState() {
    super.initState();
  }

  _save() {
    if (!_formKey.currentState.validate()) return;

    _formKey.currentState.save();
    DatabaseService.receiveMoney(
        StateWidget.of(context).state.user.userId,
        _description,
        _notes,
        Timestamp.fromDate(_incomeDate),
        _amount,
        "-LtL_NdAXrtGvXctcj0_");
        Navigator.pop(context);
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
          title: Text("Receive Money"),
          actions: <Widget>[
            FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: Text("Save"),
            onPressed: () {
              _save();
            })
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Income Description'),
                  validator: (input) => input.length < 2
                      ? 'Enter an description for this income'
                      : null,
                  onSaved: (input) => _description = input,
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: <Widget>[
                      Text("Date:"),
                      Expanded(
                          child: Text(
                              DateFormat("dd MMM yyyy").format(_incomeDate))),
                      FlatButton(
                        child: Icon(Icons.calendar_today, color: Colors.blue,),
                        onPressed: () => _selectDate(context),
                      )
                    ],
                  ),
                ),
                Divider(),
                TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (input) { setState(() {
                        _amount = double.parse(input);
                      }); },
                      //validator: (value) => Validator.validateNumber(value),
                      decoration: InputDecoration(hintText: "Amount"),
                    ),
              ],
            ),
          ),
        ));
  }
}
