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
  double balance;
  DateTime balanceAsOf;
  Timestamp dateCreated;
  List<Reconciliation> reconciliations;


  Account({
    this.accountName,
    this.accountNo,
    this.accountType,
    this.currency,
    this.balance,
    this.reconciliations,
    this.balanceAsOf,
    this.dateCreated
  });

  factory Account.fromJson(Map<String, dynamic> json) => new Account(
        accountName: json["accountName"],
        accountNo: json["accountNo"],
        accountType: json["accountType"],
        currency: json["currency"],
        balanceAsOf: json["balanceAsOf"],
        balance: json["balance"],
        dateCreated: json["createdOn"]
      );

  Map<String, dynamic> toJson() => {
        "accountName": accountName ?? '',
        "accountNo": accountNo ?? '',
        "accountType": accountType ?? 'Cash',
        "currency": currency ?? 'USD',
        "balanceAsOf": balanceAsOf ?? null,
        "balance": balance ?? 0.00,
        "createdOn": dateCreated ?? DateTime.now()
      };

  factory Account.fromDocument(DocumentSnapshot doc) {
    Account ret = Account.fromJson(doc.data);
    ret.accountId = doc.documentID;
    return ret;
  }

  factory Account.fromMap(Map data) {
    return Account.fromJson(data);
  }
}
