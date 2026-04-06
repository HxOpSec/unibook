import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/books_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_list_item.dart';
import 'package:unibook/widgets/book_card.dart';
import 'package:unibook/widgets/empty_state.dart';
import 'package:unibook/widgets/shimmer_loader.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _initialized = false;
  final _searchCtrl = TextEditingController();
  final Set<String> _favorites = <String>{};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final dept = ModalRoute.of(context)!.settings.arguments as DepartmentModel;
    context.read<BooksProvider>().subscribeDepartment(dept.id);
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final dept = ModalRoute.of(context)!.settings.arguments as DepartmentModel;
    final provider = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(dept.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(dept.iconData, size: 40, color: dept.colorValue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dept.facultyName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${dept.building} · ${dept.room}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (dept.head.trim().isNotEmpty)
                        Text(
                          dept.head,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: provider.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Поиск книг и авторов...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.setQuery('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _showFilterSheet(context, provider),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Фильтр'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.loading) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: 6,
                    itemBuilder: (_, __) => const ShimmerLoader(
                      child: Card(
                        child: SizedBox(height: 116),
                      ),
                    ),
                  );
                }

                final books = provider.books;
                if (books.isEmpty) {
                  return const EmptyState(
                    icon: Icons.menu_book,
                    title: 'Нет книг в этой кафедре',
                    subtitle: 'Добавьте первую книгу для этой кафедры',
                  );
                }

                return FutureBuilder<Map<String, DepartmentModel>>(
                  future: context.read<FirestoreService>().getDepartmentsMap(),
                  builder: (context, snapshot) {
                    final departmentMap = snapshot.data ?? {};
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return AnimatedListItem(
                          index: index,
                          child: BookCard(
                            book: book,
                            department: departmentMap[book.departmentId],
                            isFavorite: _favorites.contains(book.id),
                            onFavoriteTap: () {
                              setState(() {
                                if (!_favorites.add(book.id)) {
                                  _favorites.remove(book.id);
                                }
                              });
                            },
                            onLongPress: () => _showBookActions(context, book),
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.reader,
                              arguments: book,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, BooksProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Сортировать по', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Дате'),
                    selected: provider.sort == BookSort.byDate,
                    onSelected: (_) => provider.setSort(BookSort.byDate),
                  ),
                  ChoiceChip(
                    label: const Text('Названию'),
                    selected: provider.sort == BookSort.byTitle,
                    onSelected: (_) => provider.setSort(BookSort.byTitle),
                  ),
                  ChoiceChip(
                    label: const Text('Автору'),
                    selected: provider.sort == BookSort.byAuthor,
                    onSelected: (_) => provider.setSort(BookSort.byAuthor),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Предмет', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                value: provider.subjectFilter,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Все', overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
                  ...provider.subjects.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                  ),
                ],
                onChanged: (value) => provider.setSubject(value),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookActions(BuildContext context, BookModel book) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.chrome_reader_mode),
                  title: const Text('Читать'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(AppRoutes.reader, arguments: book);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Поделиться'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Инфо'),
                  subtitle: Text('${book.title} · ${book.author}'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
      },
    );
  }
}
