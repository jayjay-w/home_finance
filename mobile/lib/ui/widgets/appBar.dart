import 'package:flutter/material.dart';
import 'package:homefinance/services/theme_service.dart';

AppBar makeAppBar(BuildContext context, String userId, String title, onActionPressed, IconData actionIcon) {
  return AppBar(
    backgroundColor: primaryColor,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 2
      )
      ),
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(actionIcon),
          iconSize: 30,
          color: Colors.white,
          onPressed: () {  onActionPressed; },
        )
      ],
  );
}
