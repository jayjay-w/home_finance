import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homefinance/models/reconciliation.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/services/database_service.dart';


Account accountFromJson(String str) {
  final jsonData = json.decode(str);
  return Account.fromJson(jsonData);
}

String accountToJson(Account data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Account {
  String uid;
  String accountId;
  String accountName;
  String accountNo;
  String accountType;
  String currency = "";
  double openingBalance = 0.00;
  double currentBalance = 0.00;
  double allCredits = 0;
  double allDebits = 0;
  DateTime balanceAsOf;
  Timestamp dateCreated;
  
  List<Reconciliation> reconciliations;


  Account({
    this.accountName,
    this.accountNo,
    this.accountType,
    this.currency,
    this.openingBalance,
    this.balanceAsOf,
    this.dateCreated,
    this.uid,
    this.currentBalance,
    this.allDebits,
    this.allCredits
  });

  factory Account.fromJson(Map<String, dynamic> json) => new Account(
        accountName: json["accountName"],
        accountNo: json["accountNo"],
        accountType: json["accountType"],
        currency: json["currency"],
        uid: json['uid'],
        balanceAsOf: json["balanceAsOf"],
        openingBalance: double.parse(json["openingBalance"].toString()),
        dateCreated: json["createdOn"],
        currentBalance: json["currentBalance"] ?? 0,
        allCredits: json['allCredits'] ?? 0.00,
        allDebits: json['allDebits'] ?? 0.00
      );

  void getBalance() async {
    await DatabaseService.getAccountTransactions(accountId, uid).then((userTransactions) {
        for (DocumentSnapshot doc in userTransactions.documents) {
          
          Trans trans = Trans.fromDocument(doc);
            if (trans != null) {
              if (trans.creditAccountId == accountId)
                allCredits += trans.transactionAmount;

              if (trans.debitAccountId == accountId)
                allDebits += trans.transactionAmount;
            }
        }
        
        double bal = openingBalance + allCredits + allDebits;
        if (currentBalance != bal) {
          currentBalance = openingBalance + allCredits - allDebits;
          DatabaseService.updateAccount(accountId, this, uid);
        }
    });
  }

  double getTotalCredits()  {
    double credits = 0;
    return credits;
  }

  double getTotalDebits() {
    double debits = 0;
    return debits;
  }

  Map<String, dynamic> toJson() => {
        "accountName": accountName ?? '',
        "accountNo": accountNo ?? '',
        "accountType": accountType ?? 'Cash',
        "uid": uid ?? '',
        "currency": currency ?? 'USD',
        "balanceAsOf": balanceAsOf ?? null,
        "openingBalance": openingBalance.toString() ?? "0.00",
        "createdOn": dateCreated ?? DateTime.now(),
        "currentBalance" : currentBalance ?? 0.00,
        "allCredits" : allCredits ?? 0.00,
        "allDebits" : allDebits ?? 0.00
      };

  factory Account.fromDocument(DocumentSnapshot doc) {
    Account ret = Account.fromJson(doc.data);
    ret.accountId = doc.documentID;
    //ret.getBalance();
    return ret;
  }

  factory Account.fromMap(Map data) {
    return Account.fromJson(data);
  }
}
