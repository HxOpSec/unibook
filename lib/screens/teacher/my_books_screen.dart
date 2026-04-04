import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/book_card.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мои книги')),
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('У вас пока нет загруженных книг'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                            FilledButton(
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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Книга удалена'),
                      ),
                    );
                  }
                },
                child: BookCard(
                  book: book,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.reader,
                    arguments: book,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
