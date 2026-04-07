import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_list_item.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = context.read<FirestoreService>().getStats();
  }

  void _refresh() {
    setState(() {
      _statsFuture = context.read<FirestoreService>().getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.admin_panel_settings))],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          final stats = snapshot.data ?? const {'books': 0, 'users': 0, 'departments': 0};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AdminStatCard(
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                    label: 'Всего книг',
                    value: stats['books'] ?? 0,
                  ),
                  _AdminStatCard(
                    icon: Icons.people_alt_outlined,
                    color: AppColors.success,
                    label: 'Всего пользователей',
                    value: stats['users'] ?? 0,
                  ),
                  _AdminStatCard(
                    icon: Icons.school_outlined,
                    color: Colors.purple,
                    label: 'Кафедры',
                    value: stats['departments'] ?? 0,
                  ),
                  _AdminStatCard(
                    icon: Icons.calendar_month_outlined,
                    color: Colors.orange,
                    label: 'Книг за месяц',
                    value: stats['books'] ?? 0,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Быстрые действия',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.people_outline,
                title: 'Управление пользователями',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminUsers),
              ),
              _ActionTile(
                icon: Icons.account_tree_outlined,
                title: 'Управление кафедрами',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminDepartments),
              ),
              _ActionTile(
                icon: Icons.vpn_key_outlined,
                title: 'Установить код учителя',
                onTap: () async {
                  final controller = TextEditingController();
                  final code = await showDialog<String>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Код учителя'),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Сохранить')),
                      ],
                    ),
                  );
                  if (code == null || code.trim().isEmpty) return;
                  if (!context.mounted) return;
                  await context.read<FirestoreService>().setTeacherCode(code);
                  if (context.mounted) showSuccess(context, 'Код учителя обновлён');
                },
              ),
              _ActionTile(
                icon: Icons.library_books_outlined,
                title: 'Все книги',
                onTap: _refresh,
              ),
              const SizedBox(height: 14),
              const Text(
                'Последние книги',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<BookModel>>(
                stream: context.read<FirestoreService>().streamRecentBooks(limit: 10),
                builder: (context, snapshot) {
                  final books = snapshot.data ?? [];
                  if (books.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Нет последних поступлений'),
                      ),
                    );
                  }
                  return Column(
                    children: List.generate(books.length, (index) {
                      final book = books[index];
                      return AnimatedListItem(
                        index: index,
                        child: Card(
                          child: ListTile(
                            title: Text(book.title),
                            subtitle: Text('${book.author} · ${book.uploaderName}'),
                            trailing: Text(
                              _timeAgo(book.createdAt),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}д';
    if (diff.inHours > 0) return '${diff.inHours}ч';
    if (diff.inMinutes > 0) return '${diff.inMinutes}м';
    return 'только что';
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1000),
            builder: (_, v, __) => Text(
              v.round().toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
