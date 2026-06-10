import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final String uid;
  final String categoryId;
  final String categoryName;
  final double amount;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IncomeModel({
    required this.id,
    required this.uid,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncomeModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return IncomeModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      amount: (data['amount'] as num? ?? 0).toDouble(),
      note: data['note'] as String? ?? '',
      date: readDate(data['date']),
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
