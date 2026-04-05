import 'package:flutter/material.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/press_scale_button.dart';

class DepartmentCard extends StatelessWidget {
  const DepartmentCard({super.key, required this.department, required this.onTap});

  final DepartmentModel department;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = department.colorValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A0030);

    return Hero(
      tag: 'dept_${department.id}',
      child: PressScaleButton(
        onTap: onTap,
        child: GlassCard(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.34), color.withOpacity(0.16)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.88) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${department.bookCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(department.iconData, color: textColor, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        department.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${department.building} · ${department.room}',
                        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
