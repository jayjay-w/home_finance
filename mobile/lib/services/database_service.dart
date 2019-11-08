
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homefinance/models/account.dart';

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

    static Future<QuerySnapshot> getAccountTransactions(String accountId, String uid) {
      Future<QuerySnapshot> transactions = usersRef.document(uid).collection('transactions').where('accountId', isEqualTo: accountId).getDocuments();
      return transactions;
    }
}