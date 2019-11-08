
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
      Trans newTrans = new Trans(debitAccountId: sourceAccountId, creditAccountId: targetAccountId, transactionAmount: amount, transactionDate: date);
      print('Saving ' + newTrans.toString());
      usersRef.document(uid).collection('transactions').document().setData(newTrans.toJson());
    }

    
  static Future<QuerySnapshot> getCreditTransactionsForAccount(String uid, String accId) async {
    Future<QuerySnapshot> transactions = usersRef.document(uid).collection('transactions').where('accountId', isEqualTo: accId).getDocuments();
    return transactions;
  }
}