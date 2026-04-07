import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A read-only star rating indicator.
class RatingIndicator extends StatelessWidget {
  const RatingIndicator({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.color,
    this.showLabel = true,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.warning;
    final stars = List.generate(maxRating, (i) {
      final fill = (rating - i).clamp(0.0, 1.0);
      return Icon(
        fill >= 1.0
            ? Icons.star_rounded
            : fill >= 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
        color: starColor,
        size: size,
      );
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.75,
              color: starColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
