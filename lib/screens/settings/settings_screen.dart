import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/glass_card.dart';

// Keep this in sync with pubspec.yaml version field.
// For production, use package_info_plus to read this dynamically.
const String _appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const [
            AppColors.darkBackgroundStart,
            AppColors.darkBackgroundMid,
            AppColors.darkBackgroundEnd,
          ]
        : const [
            AppColors.lightBackgroundStart,
            AppColors.lightBackgroundMid,
            AppColors.lightBackgroundEnd,
          ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(settings.t('settings'))),
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
                _SectionHeader(title: settings.t('themeSettings')),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined,
                            color: AppColors.primary),
                        title: Text(settings.t('theme')),
                        subtitle: Text(
                          isDark
                              ? settings.t('darkTheme')
                              : settings.t('lightTheme'),
                        ),
                        trailing: Switch(
                          value: isDark,
                          activeColor: AppColors.primary,
                          onChanged: (_) => settings.toggleTheme(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionHeader(title: settings.t('language')),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _LanguageTile(
                        language: 'ru',
                        label: 'Русский',
                        selected: settings.languageCode == 'ru',
                        onTap: () => settings.setLanguage('ru'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _LanguageTile(
                        language: 'tj',
                        label: 'Тоҷикӣ',
                        selected: settings.languageCode == 'tj',
                        onTap: () => settings.setLanguage('tj'),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _LanguageTile(
                        language: 'en',
                        label: 'English',
                        selected: settings.languageCode == 'en',
                        onTap: () => settings.setLanguage('en'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SectionHeader(title: settings.t('cacheSettings')),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: Text(settings.t('clearCache')),
                    onTap: () => _clearCache(context, settings),
                  ),
                ),
                const SizedBox(height: 10),
                _SectionHeader(title: settings.t('aboutApp')),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline,
                            color: AppColors.primary),
                        title: Text(settings.t('version')),
                        trailing: const Text(
                          _appVersion,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(
      BuildContext context, SettingsProvider settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('last_page_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(settings.t('cacheCleared'))),
        );
      }
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String language;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        language.toUpperCase(),
        style: TextStyle(
          color: selected ? AppColors.primary : null,
          fontWeight: selected ? FontWeight.w700 : null,
        ),
      ),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
