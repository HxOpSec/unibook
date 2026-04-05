import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/widgets/glass_card.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.department,
    this.onFavoriteTap,
    this.onLongPress,
    this.isFavorite = false,
  });

  final BookModel book;
  final DepartmentModel? department;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final departmentColor = department?.colorValue ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A0030);
    final textSecondary = isDark ? Colors.white70 : const Color(0xB31A0030);
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: 'book_${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 70,
                    height: 95,
                    child: (book.coverUrl ?? '').isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  departmentColor,
                                  departmentColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              book.title.trim().isEmpty
                                  ? 'К'
                                  : book.title.trim().substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.blue.shade100,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${book.year}',
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: textSecondary.withOpacity(0.4)),
                            ),
                            child: Text(
                              book.subject,
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            department?.code ?? '',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onFavoriteTap,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
