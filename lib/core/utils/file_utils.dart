import 'dart:io';

import 'package:file_picker/file_picker.dart';

abstract final class FileUtils {
  static const maxPdfBytes = 50 * 1024 * 1024;

  static Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  static Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  static Future<bool> isPdfSizeValid(File file) async {
    final bytes = await file.length();
    return bytes <= maxPdfBytes;
  }
}
