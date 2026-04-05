import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/tgfeu_data.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_list_item.dart';
import 'package:unibook/widgets/university_emblem.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _roleLabel(String role) {
    switch (role) {
      case 'teacher':
        return 'Учитель';
      case 'admin':
        return 'Мудири кафедра';
      default:
        return 'Студент';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'teacher':
        return AppColors.success;
      case 'admin':
        return AppColors.gold;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name
            .trim()
            .split(' ')
            .take(2)
            .map((e) => e.substring(0, 1).toUpperCase())
            .join();
    final roleColor = _roleColor(user.role);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.primaryDark],
                        ),
                        border: Border.all(color: AppColors.gold, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _roleLabel(user.role),
                        style: TextStyle(
                          color: user.role == 'admin' ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.departmentId,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                    Text(
                      'ТГФЭУ',
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: Future.wait([
                context.read<FirestoreService>().streamBooksByUploader(user.uid).first,
                context.read<FirestoreService>().getDepartments(),
              ]),
              builder: (context, snapshot) {
                final uploadedBooksCount = snapshot.hasData
                    ? (snapshot.data![0] as List).length
                    : 0;
                final departments =
                    snapshot.hasData ? snapshot.data![1] as List<dynamic> : <dynamic>[];
                final deptNames = departments
                    .where((d) => d.id == user.departmentId)
                    .map((d) => d.name as String)
                    .toList();
                final deptName =
                    deptNames.isEmpty ? user.departmentId : deptNames.first;

                final items = <Widget>[
                  _MenuTile(
                    icon: Icons.edit_outlined,
                    title: 'Редактировать профиль',
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
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, controller.text.trim()),
                              child: const Text('Сохранить'),
                            ),
                          ],
                        ),
                      );
                      if (value != null && value.isNotEmpty) {
                        await context.read<FirestoreService>().updateUserName(user.uid, value);
                        if (context.mounted) showSuccess(context, 'Профиль обновлён');
                      }
                    },
                  ),
                  if (user.isTeacher || user.isAdmin)
                    _MenuTile(
                      icon: Icons.library_books_outlined,
                      title: 'Мои книги',
                      trailing: _Badge(text: '$uploadedBooksCount'),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.myBooks),
                    ),
                  _MenuTile(
                    icon: Icons.bookmark_outline,
                    title: 'Избранные книги',
                  ),
                  _MenuTile(
                    icon: Icons.history_outlined,
                    title: 'История чтения',
                  ),
                  if (user.isAdmin)
                    _MenuTile(
                      icon: Icons.admin_panel_settings,
                      title: 'Панель администратора',
                      iconColor: Colors.red,
                      trailing: const _Badge(text: 'ADMIN', color: Colors.red),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
                    ),
                  _MenuTile(
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            TgfeuLogo(size: 52, textSize: 12),
                            SizedBox(height: 12),
                            Text('Версия 1.0.0'),
                            SizedBox(height: 4),
                            Text('Официальное приложение ТГФЭУ'),
                            SizedBox(height: 4),
                            Text('tgfeu.tj'),
                            SizedBox(height: 4),
                            Text(tgfeuAddress, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.logout,
                    title: 'Выйти',
                    iconColor: Colors.red,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Выйти из аккаунта?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Отмена'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Выйти'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (!confirm) return;
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                      }
                    },
                  ),
                ];

                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                        title: Text(deptName),
                        subtitle: Text(user.email),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      );
                    }
                    return AnimatedListItem(index: index, child: items[index - 1]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
