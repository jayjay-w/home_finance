import 'package:flutter/material.dart';

class TransfersScreen extends StatefulWidget {
  static String id = "transfers";
  @override
  _TransfersScreenState createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Money Transfers"),
      ),
      body: Center(child: Text("Transfer Money"),)
    );
  }
}