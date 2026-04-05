import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/book_card.dart';
import 'package:unibook/widgets/empty_state.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои книги'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: context.read<FirestoreService>().streamBooksByUploader(user.uid),
        builder: (context, snapshot) {
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Нет книг',
              subtitle: 'Добавьте первую книгу в библиотеку',
            );
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: () async {
              final departments = await context.read<FirestoreService>().getDepartmentsMap();
              return {'departments': departments};
            }(),
            builder: (context, depSnapshot) {
              final depMap =
                  depSnapshot.data?['departments'] as Map<String, dynamic>? ?? {};
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Dismissible(
                    key: ValueKey(book.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Удалить книгу?'),
                              content: const Text('Действие нельзя отменить.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Отмена'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) async {
                      await context.read<FirestoreService>().deleteBook(book);
                      if (context.mounted) showSuccess(context, 'Книга удалена');
                    },
                    child: BookCard(
                      book: book,
                      department: depMap[book.departmentId],
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
    );
  }
}
