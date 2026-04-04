import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.bookCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String code;
  final int bookCount;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'bookCount': bookCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DepartmentModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return DepartmentModel(
      id: id,
      name: (map['name'] ?? '') as String,
      code: (map['code'] ?? '') as String,
      bookCount: ((map['bookCount'] ?? 0) as num).toInt(),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    int? bookCount,
    DateTime? createdAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      bookCount: bookCount ?? this.bookCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
