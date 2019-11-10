
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/transaction.dart';

final _firestore = Firestore.instance;
final accountsRef = _firestore.collection('accounts');
final usersRef = _firestore.collection('users');



class DatabaseService {
  
    static void addAccount(Account acc, String uid) async {
      usersRef.document(uid).collection('accounts').document().setData(
        acc.toJson()
      );
    }

    static void updateAccount(String accountId, Account acc, String uid) async {
      usersRef.document(uid).collection('accounts').document(accountId).setData(
        acc.toJson()
      );
    }

    static Future<QuerySnapshot> getAccountTransactions(String accountId, String uid) async {
      Future<QuerySnapshot> transactions = usersRef.document(uid).collection('transactions').getDocuments();
      return transactions;
    }

    static void transferMoney(String uid, String sourceAccountId, String targetAccountId, Timestamp date, double amount) async {
      Trans newTrans = new Trans(transType: "Transfer", debitAccountId: sourceAccountId, creditAccountId: targetAccountId, transactionAmount: amount, transactionDate: date);
      
      usersRef.document(uid).collection('transactions').document().setData(newTrans.toJson());
      creditAccount(uid, targetAccountId, amount);
      debitAccount(uid, sourceAccountId, amount);
    }

    static void creditAccount(String uid, String accId, double amount) {
      usersRef.document(uid).collection('accounts').document(accId).updateData(
        {
        'currentBalance': FieldValue.increment(amount),
        'allCredits': FieldValue.increment(amount)
        });
    }

    static void debitAccount(String uid, String accId, double amount) {
      usersRef.document(uid).collection('accounts').document(accId).updateData(
        {
          'currentBalance': FieldValue.increment(0 - amount),
          'allDebits' : FieldValue.increment(amount)
        });
    }
    
  static Future<QuerySnapshot> getCreditTransactionsForAccount(String uid, String accId) async {
    Future<QuerySnapshot> transactions = usersRef.document(uid).collection('transactions').where('accountId', isEqualTo: accId).getDocuments();
    return transactions;
  }
}