import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.departmentId,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String role;
  final String departmentId;
  final DateTime createdAt;

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'departmentId': departmentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return UserModel(
      uid: uid,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      role: (map['role'] ?? 'student') as String,
      departmentId: (map['departmentId'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? departmentId,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
