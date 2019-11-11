import 'package:cloud_firestore/cloud_firestore.dart';

class Trans {
  final Timestamp transactionDate;
  final String debitAccountId;
  final String creditAccountId;
  final String creditorId;
  final String debitorId;
  final double transactionAmount;
  final String transType;
  final String id;
  final String description;
  final String notes;
  final String currency;
  String comment;

  Trans({
    this.id,
    this.transactionDate,
    this.creditAccountId,
    this.debitAccountId,
    this.creditorId,
    this.debitorId,
    this.transactionAmount,
    this.transType,
    this.description,
    this.notes,
    this.currency
  });

  factory Trans.fromDocument(DocumentSnapshot doc) {
    return Trans(
      id: doc.documentID,
      creditAccountId: doc['creditAccountId'],
      debitAccountId: doc['debitAccountId'],
      creditorId: doc['creditorId'],
      debitorId: doc['debitorId'],
      transactionAmount: doc["transactionAmount"],
      transType: doc["transType"],
      transactionDate: doc["transactionDate"],
      description: doc["description"] ?? "",
      notes: doc["notes"] ?? "",
      currency: doc["currency"] ?? "USD"
    );
  }

  Map<String, dynamic> toJson() => {
        "creditAccountId": creditAccountId ?? '',
        "debitAccountId": debitAccountId ?? '',
        "creditorId": creditorId ?? '',
        "debitorId": debitorId ?? '',
        "transactionAmount": transactionAmount ?? 0.00,
        "transactionDate": transactionDate,
        "timestamp": DateTime.now(),
        "transType": transType,
        "description" : description ?? "",
        "notes": notes ?? "",
        "currency": currency ?? "USD"
      };
}