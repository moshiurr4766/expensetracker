import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String uid;
  final String name;
  final String type;
  final String icon;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.icon,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return CategoryModel(
      id: id,
      uid: data['uid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'expense',
      icon: data['icon'] as String? ?? 'category',
      colorValue: data['colorValue'] as int? ?? 0xFF607D8B,
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'type': type,
      'icon': icon,
      'colorValue': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? type,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
