import 'package:flutter/material.dart';

/// Convenience extensions on [String].
extension StringExtensions on String {
  /// Returns `true` if the string is empty or only whitespace.
  bool get isBlank => trim().isEmpty;

  /// Returns `true` if the string is not empty and not only whitespace.
  bool get isNotBlank => !isBlank;

  /// Capitalises the first letter of the string.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncates the string to [maxLength] characters, appending [ellipsis].
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

/// Convenience extensions on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Returns a short relative time string in Russian (e.g. "2д", "3ч", "только что").
  ///
  /// Note: This intentionally uses Russian abbreviations to match the default
  /// app locale. Use the settings provider's `t()` method for fully-localised
  /// output in production screens.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}г';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}мес';
    if (diff.inDays > 0) return '${diff.inDays}д';
    if (diff.inHours > 0) return '${diff.inHours}ч';
    if (diff.inMinutes > 0) return '${diff.inMinutes}м';
    return 'только что';
  }

  /// Returns a formatted date string "dd.MM.yyyy".
  String get formatted {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
  }
}

/// Convenience extensions on [BuildContext].
extension ContextExtensions on BuildContext {
  /// Returns `true` when the current brightness is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Returns the screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns the screen height.
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Convenience extensions on [List].
extension ListExtensions<T> on List<T> {
  /// Returns `null` if the list is empty, otherwise returns the list.
  List<T>? get nullIfEmpty => isEmpty ? null : this;
}
