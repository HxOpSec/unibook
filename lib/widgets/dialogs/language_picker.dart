import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// Shows a language picker dialog.
///
/// Returns the selected language code (e.g. 'en', 'ru', 'tj'), or `null`.
Future<String?> showLanguagePicker(
  BuildContext context, {
  required String currentCode,
  String? title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => LanguagePickerDialog(
      currentCode: currentCode,
      title: title,
    ),
  );
}

class LanguagePickerDialog extends StatelessWidget {
  const LanguagePickerDialog({
    super.key,
    required this.currentCode,
    this.title,
  });

  final String currentCode;
  final String? title;

  static const _languages = [
    ('ru', 'Русский', '🇷🇺'),
    ('tj', 'Тоҷикӣ', '🇹🇯'),
    ('en', 'English', '🇺🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Language'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _languages.map((lang) {
          final (code, label, flag) = lang;
          final selected = code == currentCode;
          return ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 20)),
            title: Text(label),
            trailing: selected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(code),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
