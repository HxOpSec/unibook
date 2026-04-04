import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _roleLabel(String role) {
    switch (role) {
      case 'teacher':
        return 'Учитель';
      case 'admin':
        return 'Администратор';
      default:
        return 'Студент';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                user.name.isEmpty ? '?' : user.name.trim()[0].toUpperCase(),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(user.email),
            const SizedBox(height: 8),
            Chip(label: Text(_roleLabel(user.role))),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Изменить имя'),
              onTap: () async {
                final controller = TextEditingController(text: user.name);
                final value = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Изменить имя'),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                );
                if (value != null && value.isNotEmpty) {
                  await context.read<FirestoreService>().updateUserName(user.uid, value);
                }
              },
            ),
            const SizedBox(height: 8),
            if (user.isTeacher || user.isAdmin)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Мои книги'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.myBooks),
              ),
            if (user.isTeacher || user.isAdmin) const SizedBox(height: 8),
            if (user.isAdmin)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Панель администратора'),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
              ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Выйти из аккаунта?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Выйти'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (!confirmed) return;
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                }
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
