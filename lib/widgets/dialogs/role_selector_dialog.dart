import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// Shows a role selector dialog.
///
/// Returns the selected role string (e.g. 'student', 'teacher', 'admin').
Future<String?> showRoleSelectorDialog(
  BuildContext context, {
  required String currentRole,
  String? title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => RoleSelectorDialog(currentRole: currentRole, title: title),
  );
}

class RoleSelectorDialog extends StatelessWidget {
  const RoleSelectorDialog({
    super.key,
    required this.currentRole,
    this.title,
  });

  final String currentRole;
  final String? title;

  static const _roles = [
    ('student', 'Student', Icons.school_outlined),
    ('teacher', 'Teacher', Icons.co_present_outlined),
    ('admin', 'Admin', Icons.admin_panel_settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Select Role'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _roles.map((r) {
          final (role, label, icon) = r;
          final selected = role == currentRole;
          return ListTile(
            leading: Icon(
              icon,
              color: selected ? AppColors.primary : null,
            ),
            title: Text(label),
            trailing: selected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(role),
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
