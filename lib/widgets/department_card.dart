import 'package:flutter/material.dart';
import 'package:unibook/models/department_model.dart';

class DepartmentCard extends StatelessWidget {
  const DepartmentCard({super.key, required this.department, required this.onTap});

  final DepartmentModel department;
  final VoidCallback onTap;

  static const Map<String, IconData> _iconMap = {
    'dept_finance': Icons.account_balance,
    'dept_accounting': Icons.receipt_long,
    'dept_economics': Icons.trending_up,
    'dept_banking': Icons.credit_card,
    'dept_tax': Icons.payments,
    'dept_math': Icons.calculate,
    'dept_law': Icons.gavel,
    'dept_lang': Icons.language,
    'dept_tjru': Icons.translate,
    'dept_history': Icons.history_edu,
    'dept_sport': Icons.sports_soccer,
    'dept_stat': Icons.bar_chart,
  };

  static const Map<String, List<Color>> _gradientMap = {
    'dept_finance': [Color(0xFF1E88E5), Color(0xFF1565C0)],
    'dept_accounting': [Color(0xFF26A69A), Color(0xFF00897B)],
    'dept_economics': [Color(0xFF7E57C2), Color(0xFF5E35B1)],
    'dept_banking': [Color(0xFF42A5F5), Color(0xFF1976D2)],
    'dept_tax': [Color(0xFFEF5350), Color(0xFFE53935)],
    'dept_math': [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    'dept_law': [Color(0xFFFFA726), Color(0xFFFB8C00)],
    'dept_lang': [Color(0xFF66BB6A), Color(0xFF43A047)],
    'dept_tjru': [Color(0xFF8D6E63), Color(0xFF6D4C41)],
    'dept_history': [Color(0xFFAB47BC), Color(0xFF8E24AA)],
    'dept_sport': [Color(0xFFFF7043), Color(0xFFF4511E)],
    'dept_stat': [Color(0xFF26C6DA), Color(0xFF00ACC1)],
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[department.id] ?? Icons.school;
    final colors =
        _gradientMap[department.id] ?? const [Color(0xFF1976D2), Color(0xFF1565C0)];

    return Hero(
      tag: 'department-${department.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    department.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Книг: ${department.bookCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
