import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 24,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.shadowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? radius;
    final effectiveColor = color ?? (isDark ? AppColors.darkGlassCard : AppColors.lightGlassCard);
    final effectiveBorder = borderColor ?? (isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder);
    final effectiveShadow = shadowColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.16);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveRadius),
              color: effectiveColor,
              border: Border.all(color: effectiveBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: effectiveShadow,
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
