import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkModel {
  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.page,
    required this.createdAt,
    this.label = '',
  });

  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final int page;
  final String label;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'page': page,
      'label': label,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookmarkModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return BookmarkModel(
      id: id,
      userId: (map['userId'] ?? '') as String,
      bookId: (map['bookId'] ?? '') as String,
      bookTitle: (map['bookTitle'] ?? '') as String,
      page: ((map['page'] ?? 1) as num).toInt(),
      label: (map['label'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  BookmarkModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? bookTitle,
    int? page,
    String? label,
    DateTime? createdAt,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      page: page ?? this.page,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
