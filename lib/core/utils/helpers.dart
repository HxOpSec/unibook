import 'package:flutter/material.dart';

/// Opens a [SnackBar] with an informational message.
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Returns a human-readable file size string (e.g. "2.4 MB").
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

/// Clamps [value] between [min] and [max].
T clamp<T extends num>(T value, T min, T max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// Returns the initials for a given [name] (up to 2 characters).
String getInitials(String name) {
  final parts = name.trim().split(' ');
  final chars = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join();
  return chars.isEmpty ? '?' : chars.toUpperCase();
}

/// Returns a colour that is safely legible on top of the given [background].
Color contrastColor(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.4 ? Colors.black87 : Colors.white;
}
