import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyDropDown extends StatefulWidget {
  final String currencyValue;
  final Function onChanged;
  final String loadingText;

  CurrencyDropDown(
      {@required this.currencyValue,
      @required this.onChanged,
      this.loadingText = "Loading"});

  @override
  _CurrencyDropDownState createState() => _CurrencyDropDownState();
}

class _CurrencyDropDownState extends State<CurrencyDropDown> {
  List<dynamic> currencyList;
  bool listLoading = true;

  getCurrencyList() async {
    String jsonRes = await rootBundle.loadString('assets/data/currencies.json');
    var res = json.decode(jsonRes);

    setState(() {
      currencyList = res;
      listLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    currencyList = [
      {'cc': widget.loadingText, 'name': widget.loadingText, 'symbol': ''}
    ];
    getCurrencyList();
  }

  @override
  Widget build(BuildContext context) {
    return new DropdownButton<String>(
      isExpanded: true,
      items: currencyList.map((value) {
        return new DropdownMenuItem<String>(
          value: value['cc'],
          child: Align(
              child: new Text(value['cc'] + " (" + (value['name'] + ")"))),
        );
      }).toList(),
      value: listLoading ? widget.loadingText : widget.currencyValue,
      onChanged: (val) {
        setState(() {
          var selected = currencyList.firstWhere((c) => c['cc'] == val);
          widget.onChanged(val, selected['symbol'] ?? '');
        });
      },
    );
  }
}
