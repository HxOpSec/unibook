import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A custom bottom navigation bar with purple university branding.
class UniBottomNav extends StatelessWidget {
  const UniBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<UniBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundMid : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          key: ValueKey(selected),
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.mediumGray),
                          size: 24,
                        ),
                      ),
                      if (item.label != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.label!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.mediumGray),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class UniBottomNavItem {
  const UniBottomNavItem({
    required this.icon,
    IconData? activeIcon,
    this.label,
  }) : activeIcon = activeIcon ?? icon;

  final IconData icon;
  final IconData activeIcon;
  final String? label;
}
