import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/ddmit_logo.dart';
import 'package:unibook/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const [AppColors.darkBackgroundStart, AppColors.darkBackgroundMid, AppColors.darkBackgroundEnd]
        : const [AppColors.lightBackgroundStart, AppColors.lightBackgroundMid, AppColors.lightBackgroundEnd];

    String roleLabel() {
      if (user?.isAdmin == true) return settings.t('administrator');
      if (user?.isTeacher == true) return settings.t('teacher');
      return settings.t('student');
    }

    return Scaffold(
      appBar: AppBar(title: Text(settings.t('profile'))),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      DdmitLogo(
                        size: 74,
                        text: settings.languageCode == 'en' ? 'DDMIT' : 'ДДМИТ',
                        textSize: settings.languageCode == 'en' ? 14 : 12,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? settings.t('notAuthorized'),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? settings.t('signInToAdmin'),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          roleLabel(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.color_lens_outlined,
                  title: settings.t('changeTheme'),
                  subtitle: isDark ? settings.t('darkTheme') : settings.t('lightTheme'),
                  onTap: settings.toggleTheme,
                ),
                _SettingTile(
                  icon: Icons.language_outlined,
                  title: settings.t('changeLanguage'),
                  subtitle: settings.languageCode.toUpperCase(),
                  onTap: () => _showLanguagePicker(context, settings),
                ),
                if (!auth.isAdminOrTeacher)
                  _SettingTile(
                    icon: Icons.lock_outline,
                    title: settings.t('adminLogin'),
                    subtitle: settings.t('adminOnlyLoginHint'),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.login),
                  ),
                if (auth.isAdminOrTeacher)
                  _SettingTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: settings.t('openAdminPanel'),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
                  ),
                _SettingTile(
                  icon: Icons.logout,
                  title: settings.t('logout'),
                  danger: true,
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                settings.setLanguage('ru');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Тоҷикӣ'),
              onTap: () {
                settings.setLanguage('tj');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                settings.setLanguage('en');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
