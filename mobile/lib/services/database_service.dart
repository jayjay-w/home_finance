
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
final accountsRef = _firestore.collection('accounts');