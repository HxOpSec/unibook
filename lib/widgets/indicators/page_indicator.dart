import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A page counter indicator (e.g. "5 / 120") used in the PDF reader toolbar.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.style,
  });

  final int currentPage;
  final int totalPages;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
    return Text(
      '$currentPage / $totalPages',
      style: textStyle,
    );
  }
}
