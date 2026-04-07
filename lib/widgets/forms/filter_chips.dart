import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A group of filter/sort chips.
class FilterChipsBar<T> extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scrollable = true,
  });

  final List<FilterChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final chips = options.map((opt) {
      final isSelected = opt.value == selected;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(opt.label),
          selected: isSelected,
          onSelected: (_) => onSelected(opt.value),
          avatar: opt.icon != null
              ? Icon(opt.icon, size: 16,
                  color: isSelected ? AppColors.primary : null)
              : null,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.lightGlassBorder,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : null,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }
    return Wrap(spacing: 0, runSpacing: 8, children: chips);
  }
}

class FilterChipOption<T> {
  const FilterChipOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}
