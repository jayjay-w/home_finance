import 'package:flutter/material.dart';
import 'package:homefinance/services/theme_service.dart';
import 'package:intl/intl.dart';

class MonthSelectorWidget extends StatefulWidget {
  final Function onChanged;

  MonthSelectorWidget({this.onChanged});

  @override
  _MonthSelectorWidgetState createState() => _MonthSelectorWidgetState();
}

class _MonthSelectorWidgetState extends State<MonthSelectorWidget> {
  String _monthName;
  int _month, _year;

  _decreaseMonth() {
    int nMonth = _month - 1;
    if (nMonth < 1) { nMonth = 12; _year = _year - 1;}
    _month = nMonth;
    _triggerChange();
  }

  _increaseMonth() {
    int nMonth = _month + 1;
    if (nMonth > 12) { nMonth = 1; _year = _year + 1;}
    _month = nMonth;
    _triggerChange();
  }

  _triggerChange() {
    setState(() {
    _monthName =  DateFormat("MMMM yyyy").format(DateTime(_year, _month)); 
     widget.onChanged(new DateTime(_year, _month));
    });
  }

  @override
  void initState() {
    _month = DateTime.now().month;
    _year = DateTime.now().year;

    _triggerChange();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            _decreaseMonth();
          },
          child: Icon(Icons.arrow_back_ios, size: 12,),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              _monthName,
              textAlign: TextAlign.center,
              style: TextStyle(color: boldGrey.color, fontWeight: boldGrey.fontWeight, fontSize: 20),
            ),
          ),
        ),
        FlatButton(onPressed: () { _increaseMonth(); }, child: Icon(Icons.arrow_forward_ios, size: 12,)),
      ],
    );
  }
}