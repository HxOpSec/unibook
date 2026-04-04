import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:unibook/core/utils/file_utils.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/user_model.dart';
import 'package:unibook/services/cloudinary_service.dart';
import 'package:unibook/services/firestore_service.dart';

class UploadProvider extends ChangeNotifier {
  UploadProvider(this._cloudinaryService, this._firestoreService);

  final CloudinaryService _cloudinaryService;
  final FirestoreService _firestoreService;

  bool _isUploading = false;
  double _progress = 0;
  String? _error;

  bool get isUploading => _isUploading;
  double get progress => _progress;
  String? get error => _error;

  Future<bool> uploadBook({
    required UserModel uploader,
    required File pdf,
    required String title,
    required String author,
    required int year,
    required String subject,
    required String departmentId,
    File? cover,
    required String uploadPreset,
  }) async {
    _isUploading = true;
    _progress = 0;
    _error = null;
    notifyListeners();

    try {
      final valid = await FileUtils.isPdfSizeValid(pdf);
      if (!valid) {
        throw Exception('Файл слишком большой. Максимум 50 МБ');
      }

      final upload = await _cloudinaryService.uploadPdf(
        file: pdf,
        uploadPreset: uploadPreset,
        onProgress: (value) {
          _progress = value * 0.9;
          notifyListeners();
        },
      );

      String? coverUrl;
      if (cover != null) {
        coverUrl = await _cloudinaryService.uploadCover(
          file: cover,
          uploadPreset: uploadPreset,
        );
      }

      final now = DateTime.now();
      final book = BookModel(
        id: '',
        title: title.trim(),
        author: author.trim(),
        year: year,
        subject: subject.trim(),
        departmentId: departmentId,
        uploadedBy: uploader.uid,
        uploaderName: uploader.name,
        fileUrl: upload.secureUrl,
        publicId: upload.publicId,
        coverUrl: coverUrl,
        downloadCount: 0,
        createdAt: now,
      );

      await _firestoreService.addBook(book);
      _progress = 1;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
