import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/services/firestore_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Панель администратора')),
      body: FutureBuilder<Map<String, int>>(
        future: context.read<FirestoreService>().getStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? const {'books': 0, 'users': 0, 'departments': 0};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(title: 'Книги', value: stats['books'] ?? 0),
                  _StatCard(title: 'Пользователи', value: stats['users'] ?? 0),
                  _StatCard(title: 'Кафедры', value: stats['departments'] ?? 0),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Управление пользователями'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminUsers),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_tree_outlined),
                  title: const Text('Управление кафедрами'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.adminDepartments),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Код учителя'),
                  subtitle: const Text('Изменить код верификации для регистрации учителей'),
                  onTap: () async {
                    final controller = TextEditingController();
                    final newCode = await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Новый код учителя'),
                        content: TextField(controller: controller),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, controller.text),
                            child: const Text('Сохранить'),
                          ),
                        ],
                      ),
                    );
                    if (newCode == null || newCode.trim().isEmpty) return;
                    await context.read<FirestoreService>().setTeacherCode(newCode);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Код учителя обновлён'),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Недавняя активность',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('Обновите данные для просмотра последних действий'),
                  trailing: IconButton(
                    onPressed: () => (context as Element).markNeedsBuild(),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
