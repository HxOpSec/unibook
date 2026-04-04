import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.subject,
    required this.departmentId,
    required this.uploadedBy,
    required this.uploaderName,
    required this.fileUrl,
    required this.publicId,
    required this.downloadCount,
    required this.createdAt,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String author;
  final int year;
  final String subject;
  final String departmentId;
  final String uploadedBy;
  final String uploaderName;
  final String fileUrl;
  final String publicId;
  final String? coverUrl;
  final int downloadCount;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'subject': subject,
      'departmentId': departmentId,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'fileUrl': fileUrl,
      'publicId': publicId,
      'coverUrl': coverUrl,
      'downloadCount': downloadCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    return BookModel(
      id: id,
      title: (map['title'] ?? '') as String,
      author: (map['author'] ?? '') as String,
      year: ((map['year'] ?? 0) as num).toInt(),
      subject: (map['subject'] ?? '') as String,
      departmentId: (map['departmentId'] ?? '') as String,
      uploadedBy: (map['uploadedBy'] ?? '') as String,
      uploaderName: (map['uploaderName'] ?? '') as String,
      fileUrl: (map['fileUrl'] ?? '') as String,
      publicId: (map['publicId'] ?? '') as String,
      coverUrl: map['coverUrl'] as String?,
      downloadCount: ((map['downloadCount'] ?? 0) as num).toInt(),
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    int? year,
    String? subject,
    String? departmentId,
    String? uploadedBy,
    String? uploaderName,
    String? fileUrl,
    String? publicId,
    String? coverUrl,
    int? downloadCount,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      year: year ?? this.year,
      subject: subject ?? this.subject,
      departmentId: departmentId ?? this.departmentId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      fileUrl: fileUrl ?? this.fileUrl,
      publicId: publicId ?? this.publicId,
      coverUrl: coverUrl ?? this.coverUrl,
      downloadCount: downloadCount ?? this.downloadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
