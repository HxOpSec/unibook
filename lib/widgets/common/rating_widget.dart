import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// Displays a book rating as stars with a numeric label.
class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
    this.showCount = true,
  });

  final double rating;
  final int? reviewCount;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.warning, size: size),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
          ),
        ),
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.78,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ],
    );
  }
}
