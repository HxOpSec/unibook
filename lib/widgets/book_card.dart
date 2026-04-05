import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/press_scale_button.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.department,
    this.onFavoriteTap,
    this.onLongPress,
    this.isFavorite = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  final BookModel book;
  final DepartmentModel? department;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final deptColor = department?.colorValue ?? Theme.of(context).colorScheme.primary;

    return PressScaleButton(
      onTap: onTap,
      child: GlassCard(
        margin: margin,
        radius: 20,
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 74,
                    height: 102,
                    child: (book.coverUrl ?? '').isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [deptColor, deptColor.withOpacity(0.7)],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              book.title.trim().isEmpty
                                  ? 'B'
                                  : book.title.trim().substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const ColoredBox(
                              color: Color(0x22000000),
                              child: Center(child: Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _pill(context, '${book.year}'),
                          _pill(context, book.subject, outlined: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.school_outlined, size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              department?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ),
                          if (onFavoriteTap != null)
                            IconButton(
                              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
                              onPressed: onFavoriteTap,
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.pinkAccent : textSecondary,
                              ),
                            ),
                        ],
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

  Widget _pill(BuildContext context, String text, {bool outlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        border: outlined
            ? Border.all(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
                    const Color(0x55000000),
              )
            : null,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: outlined ? Theme.of(context).textTheme.bodyMedium?.color : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
