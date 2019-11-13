import 'package:flutter/material.dart';

final primaryColor = Color.fromRGBO(255, 82, 48, 1);

TextStyle boldGrey = TextStyle(color: Colors.black54,
                                          fontWeight: FontWeight.bold);

String clipString(String text, int len) {
  if (text.length <= len ) return text;
  return text.substring(0, len) + "...";
}