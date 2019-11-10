import 'package:flutter/material.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  static final String id = 'receive_money';
  @override
  _ReceiveMoneyScreenState createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receive Money"),
      ),
      body: Center(child: Text("Receive Money"),)
    );
  }
}