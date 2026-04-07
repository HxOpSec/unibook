import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A circular avatar that shows the user's initials as a fallback
/// when no image URL is available.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  String get _initials {
    final parts = name.trim().split(' ');
    final chars = parts.map((p) => p.isNotEmpty ? p[0] : '').take(2).join();
    return chars.isEmpty ? '?' : chars.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor:
            AppColors.primary.withValues(alpha: 0.12),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.55,
        ),
      ),
    );
  }
}
