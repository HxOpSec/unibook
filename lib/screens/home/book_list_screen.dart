import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/books_provider.dart';
import 'package:unibook/widgets/book_card.dart';
import 'package:unibook/widgets/search_bar_widget.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _initialized = false;

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
      appBar: AppBar(title: Text(dept.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBarWidget(
              hintText: AppStrings.searchBooks,
              onChanged: provider.setQuery,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Все'),
                    selected: provider.subjectFilter == null,
                    onSelected: (_) => provider.setSubject(null),
                  ),
                  const SizedBox(width: 8),
                  ...provider.subjects.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: provider.subjectFilter == s,
                        onSelected: (_) => provider.setSubject(s),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Сортировка:'),
                const SizedBox(width: 8),
                DropdownButton<BookSort>(
                  value: provider.sort,
                  items: const [
                    DropdownMenuItem(
                      value: BookSort.byDate,
                      child: Text('По дате'),
                    ),
                    DropdownMenuItem(
                      value: BookSort.byTitle,
                      child: Text('По названию'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSort(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: provider.loading ? 0.4 : 1,
                child: ListView.builder(
                  itemCount: provider.books.length,
                  itemBuilder: (context, index) {
                    final book = provider.books[index];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.reader,
                        arguments: book,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
