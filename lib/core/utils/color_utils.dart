import 'package:flutter/material.dart';

Color parseHexColor(String hexColor, {Color fallback = const Color(0xFF1565C0)}) {
  final hex = hexColor.replaceFirst('#', '');
  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}
