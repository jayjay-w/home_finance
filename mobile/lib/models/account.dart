import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homefinance/models/reconciliation.dart';


Account accountFromJson(String str) {
  final jsonData = json.decode(str);
  return Account.fromJson(jsonData);
}

String accountToJson(Account data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Account {
  String accountId;
  String accountName;
  String accountNo;
  String accountType;
  String currency;
  int balance;
  List<Reconciliation> reconciliations;

  Account({
    this.accountId,
    this.accountName,
    this.accountNo,
    this.accountType,
    this.currency,
    this.balance,
    this.reconciliations
  });

  factory Account.fromJson(Map<String, dynamic> json) => new Account(
        accountId: json["documentId"],
        accountName: json["accountName"],
        accountNo: json["accountNo"],
        accountType: json["accountType"],
        currency: json["currency"],
        balance: json["balance"],
        reconciliations: json["reconciliations"]
      );

  Map<String, dynamic> toJson() => {
        "documentId": accountId,
        "accountName": accountName,
        "accountNo": accountNo,
        "accountType": accountType,
        "currency": currency,
        "reconciliations": reconciliations,
        "balance": balance
      };

  factory Account.fromDocument(DocumentSnapshot doc) {
    return Account.fromJson(doc.data);
  }

  factory Account.fromMap(Map data) {
    return Account.fromJson(data);
  }
}
