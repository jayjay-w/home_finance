import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

Reconciliation reconciliationFromJson(String str) {
  final jsonData = json.decode(str);
  return Reconciliation.fromJson(jsonData);
}

String reconciliationToJson(Reconciliation data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Reconciliation {
  String reconciliationId;
  Double balance;
  Timestamp date;

  Reconciliation({
    this.reconciliationId,
    this.balance,
    this.date,
  });

  factory Reconciliation.fromJson(Map<String, dynamic> json) => new Reconciliation(
        reconciliationId: json["reconciliationId"],
        balance: json["balance"],
        date: json["date"]
      );

  Map<String, dynamic> toJson() => {
        "reconciliationId": reconciliationId,
        "balance": date,
        "balance": date,
      };

  factory Reconciliation.fromDocument(DocumentSnapshot doc) {
    return Reconciliation.fromJson(doc.data);
  }
}