import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String transactionDate;
  final String accountId;
  final bool isCredit;
  final double transactionAmount;
  final String id;

  Transaction({
    this.id,
    this.transactionDate,
    this.accountId,
    this.transactionAmount,
    this.isCredit
  });

  factory Transaction.fromDocument(DocumentSnapshot doc) {
    return Transaction(
      id: doc.documentID,
      accountId: doc['accountId'],
      isCredit: doc['isCredit'],
      transactionAmount: doc["transactionAmount"],
      transactionDate: doc["transactionDate"]
    );
  }


}