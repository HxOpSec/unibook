import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/utils/helpers.dart';

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
        getInitials(name),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.55,
        ),
      ),
    );
  }
}
