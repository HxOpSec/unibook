import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.page,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final int page;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'page': page,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return NoteModel(
      id: id,
      userId: (map['userId'] ?? '') as String,
      bookId: (map['bookId'] ?? '') as String,
      bookTitle: (map['bookTitle'] ?? '') as String,
      page: ((map['page'] ?? 1) as num).toInt(),
      text: (map['text'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  NoteModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? bookTitle,
    int? page,
    String? text,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      page: page ?? this.page,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
