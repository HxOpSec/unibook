import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// Shows an error dialog with a message and optional retry action.
Future<void> showErrorDialog(
  BuildContext context, {
  required String message,
  String? title,
  VoidCallback? onRetry,
}) {
  return showDialog(
    context: context,
    builder: (_) => ErrorDialog(
      message: message,
      title: title,
      onRetry: onRetry,
    ),
  );
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.error_outline, color: AppColors.error, size: 28),
      ),
      title: Text(
        title ?? 'Error',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Retry'),
          ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
