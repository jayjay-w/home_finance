
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homefinance/models/account.dart';
import 'package:homefinance/models/transaction.dart';
import 'package:homefinance/models/user.dart';

final _firestore = Firestore.instance;
final accountsRef = _firestore.collection('accounts');
final usersRef = _firestore.collection('users');
final transactionRef = _firestore.collection('transactions');



class DatabaseService {
  
    static void addAccount(Account acc, String uid) async {
      accountsRef.document().setData(
        acc.toJson()
      );
    }

    static void updateUser(User user) {
    usersRef.document(user.userId).updateData({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'profileImageUrl': user.imageURL
    });
  }

    static void updateAccount(String accountId, Account acc, String uid) async {
      accountsRef.document(accountId).setData(
        acc.toJson()
      );
    }

    static Future<QuerySnapshot> getAccountTransactions(String accountId, String uid) async {
      Future<QuerySnapshot> transactions = transactionRef.where('owner', isEqualTo: uid).getDocuments();
      return transactions;
    }

    static void transferMoney(String uid, String sourceAccountId, String targetAccountId, Timestamp date, double amount) async {
      Trans newTrans = new Trans(owner: uid, currency: "KES", transType: "Transfer", debitAccountId: sourceAccountId, creditAccountId: targetAccountId, transactionAmount: amount, transactionDate: date);
      
      transactionRef.document().setData(newTrans.toJson());
      creditAccount(uid, targetAccountId, amount);
      debitAccount(uid, sourceAccountId, amount);
    }

    static void deleteAccount(String uid, Account acc) async {
      QuerySnapshot creditTransactions = await transactionRef.where('creditAccountId', isEqualTo: acc.accountId).getDocuments();
      for (DocumentSnapshot doc in creditTransactions.documents) {
        deleteTransaction(uid, Trans.fromDocument(doc));
      }
      QuerySnapshot debitTransactions = await transactionRef.where('debitAccountId', isEqualTo: acc.accountId).getDocuments();
      for (DocumentSnapshot doc in debitTransactions.documents) {
        deleteTransaction(uid, Trans.fromDocument(doc));
      }
      await accountsRef.document(acc.accountId).delete();
    }

    static void deleteTransaction(String uid, Trans transaction) async {
      if (transaction.transType == 'Transfer') {
        deleteDebit(uid, transaction.debitAccountId, transaction.transactionAmount);
        deleteCredit(uid, transaction.creditAccountId, transaction.transactionAmount);
      }
      if (transaction.transType == 'Income') {
        deleteCredit(uid, transaction.creditAccountId, transaction.transactionAmount);
      }
      if (transaction.transType == 'Expense') {
        deleteCredit(uid, transaction.debitAccountId, transaction.transactionAmount);
      }
      await transactionRef.document(transaction.id).delete();
    }

    static void receiveMoney(String uid, String description, String notes, Timestamp dateReceived, double amount, String accountId) async {
      Trans newTrans = new Trans(
        owner: uid,
        description: description,
        notes: notes,
        creditAccountId: accountId,
        debitAccountId: "none",
        transactionDate: dateReceived,
        transactionAmount: amount,
        transType: "Income",
        currency: "KES"
        );
      
      transactionRef.document().setData(newTrans.toJson());
      creditAccount(uid, accountId, amount);
    }

    static void spendMoney(String uid, String description, String notes, Timestamp dateReceived, double amount, String accountId) async {
      Trans newTrans = new Trans(
        description: description,
        notes: notes,
        owner: uid,
        creditAccountId: "none",
        debitAccountId: accountId,
        transactionDate: dateReceived,
        transactionAmount: amount,
        transType: "Expense",
        currency: "KES"
        );
      
      transactionRef.document().setData(newTrans.toJson());
      debitAccount(uid, accountId, amount);
    }

    static void creditAccount(String uid, String accId, double amount) {
      accountsRef.document(accId).updateData(
        {
        'currentBalance': FieldValue.increment(amount),
        'allCredits': FieldValue.increment(amount)
        });
    }

    static void deleteCredit(String uid, String accId, double amount) {
      accountsRef.document(accId).updateData(
        {
        'currentBalance': FieldValue.increment(0 - amount),
        'allCredits': FieldValue.increment(0 - amount)
        });
    }

    static void deleteDebit(String uid, String accId, double amount) {
      accountsRef.document(accId).updateData(
        {
        'currentBalance': FieldValue.increment(amount),
        'allDebits': FieldValue.increment(0 - amount)
        });
    }

    static void debitAccount(String uid, String accId, double amount) {
      accountsRef.document(accId).updateData(
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