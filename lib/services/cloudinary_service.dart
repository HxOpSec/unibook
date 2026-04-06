import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CloudinaryUploadResult {
  const CloudinaryUploadResult({required this.secureUrl, required this.publicId});

  final String secureUrl;
  final String publicId;
}

class CloudinaryService {
  CloudinaryService({required this.cloudName, Dio? dio}) : _dio = dio ?? Dio();

  final String cloudName;
  final Dio _dio;

  Future<CloudinaryUploadResult> uploadPdf({
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'upload_preset': 'unibook_upload',
        'folder': 'unibook/books',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total <= 0) return;
          onProgress?.call(sent / total);
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Cloudinary upload failed: empty response');
      }

      final secureUrl = data['secure_url'] as String?;
      final publicId = data['public_id'] as String?;

      if (secureUrl == null || secureUrl.isEmpty || publicId == null || publicId.isEmpty) {
        throw Exception('Cloudinary upload failed: invalid response data');
      }

      return CloudinaryUploadResult(
        secureUrl: secureUrl,
        publicId: publicId,
      );
    } on DioException catch (e) {
      debugPrint('Cloudinary uploadPdf error: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String> uploadCover({
    required File file,
    required String uploadPreset,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'upload_preset': uploadPreset,
        'folder': 'unibook/covers',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      final secureUrl = response.data?['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary cover upload failed: missing secure_url');
      }
      return secureUrl;
    } on DioException catch (e) {
      debugPrint('Cloudinary uploadCover error: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> deleteRawByPublicId({
    required String publicId,
    required String apiKey,
    required String signature,
    required int timestamp,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/destroy',
      data: FormData.fromMap({
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
      }),
    );
  }
}