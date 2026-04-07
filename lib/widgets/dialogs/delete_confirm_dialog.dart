import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A Material 3 delete confirmation dialog.
///
/// Returns `true` when the user confirms deletion.
Future<bool> showDeleteConfirmDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => DeleteConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
  return result ?? false;
}

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String? title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
      ),
      title: Text(
        title ?? 'Delete?',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      content: Text(
        message ?? 'This action cannot be undone.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? 'Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel ?? 'Delete'),
        ),
      ],
    );
  }
}
