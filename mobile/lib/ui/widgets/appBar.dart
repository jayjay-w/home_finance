import 'package:flutter/material.dart';
import 'package:homefinance/util/state_widget.dart';

AppBar makeAppBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.menu),
      iconSize: 30,
      color: Colors.white, 
      onPressed: () {
      StateWidget.of(context).logOutUser();},
    ),
    title: Text(
      "Home Finance",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 2
      )
      ),
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          iconSize: 30,
          color: Colors.white,
          onPressed: () {},
        )
      ],
  );
}