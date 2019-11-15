import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String name;
  final String id;
  String owner;
  String icon;
  int order;

  Category({
    this.id,
    this.name,
    this.owner,
    this.icon,
    this.order,
  });


  factory Category.fromDocument(DocumentSnapshot doc) {
    return Category(
      id: doc.documentID,
      name: doc['name'] ?? 'No_Name',
      owner: doc['owner'] ?? '',
      icon: doc["icon"] ?? '',
      order: doc["order"] ?? 0
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name ?? '',
        "owner": owner,
        "icon": icon ?? '',
        "order": order ?? 999
      };
}

class SubCategory {
  String name;
  final String id;
  String categoryId;
  String owner;
  String icon;
  int order;
  double budget;
  Timestamp budgetStart;

  SubCategory({
    this.id,
    this.categoryId,
    this.name,
    this.owner,
    this.icon,
    this.order,
    this.budget,
    this.budgetStart
  });


  factory SubCategory.fromDocument(DocumentSnapshot doc) {
    return SubCategory(
      id: doc.documentID,
      categoryId: doc["categoryId"],
      name: doc['name'] ?? 'No_Name',
      owner: doc['owner'] ?? '',
      icon: doc["icon"] ?? '',
      order: doc["order"] ?? 0,
      budget: double.parse(doc["budget"].toString()) ?? 0.00,
      budgetStart: doc["budgetStart"]
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name ?? '',
        "categoryId": categoryId,
        "owner": owner,
        "icon": icon ?? '',
        "order": order ?? 999,
        "budget": budget ?? 0.00,
        "budgetStart": budgetStart
      };
}