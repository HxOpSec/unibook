import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/books_provider.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/book_card.dart';
import 'package:unibook/widgets/ddmit_logo.dart';
import 'package:unibook/widgets/department_card.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final Set<String> _favorites = <String>{};

  List<DepartmentModel> _departments = const [];
  Map<String, DepartmentModel> _departmentById = const {};
  List<BookModel> _recentBooks = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame so that Provider.notifyListeners()
    // inside loadStats() does not fire during the widget build phase, which would
    // cause a "setState() called during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final service = context.read<FirestoreService>();
    final booksProvider = context.read<BooksProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      booksProvider.loadStats();
    });

    List<DepartmentModel> departments = const [];
    List<BookModel> books = const [];
    try {
      departments = await service.getDepartments();
      books = await service.streamRecentBooks(limit: 12).first;
    } catch (e) {
      debugPrint('HomeScreen load error: $e');
    }

    if (!mounted) return;

    setState(() {
      _departments = departments;
      _departmentById = {for (final d in departments) d.id: d};
      _recentBooks = books;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final booksProvider = context.watch<BooksProvider>();
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

    final q = _searchCtrl.text.toLowerCase().trim();
    final departments = _departments.where((d) {
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.facultyName.toLowerCase().contains(q) ||
          d.code.toLowerCase().contains(q);
    }).toList();

    final books = _recentBooks.where((b) {
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            DdmitLogo(
              size: 34,
              text: settings.languageCode == 'en' ? 'DDMIT' : 'ДДМИТ',
              textSize: settings.languageCode == 'en' ? 7.4 : 6.7,
            ),
            const SizedBox(width: 10),
            Text(
              settings.t('productName'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: settings.t('search'),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
            icon: const Icon(Icons.search_outlined),
          ),
          IconButton(
            tooltip: settings.t('settings'),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: settings.t('profile'),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      floatingActionButton: auth.isAdminOrTeacher
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
              icon: const Icon(Icons.add),
              label: Text(settings.t('uploadBook')),
            )
          : null,
      bottomNavigationBar: auth.isAuthenticated
          ? BottomAppBar(
              height: 52,
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: settings.t('home'),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                    icon: const Icon(Icons.home),
                  ),
                  IconButton(
                    tooltip: settings.t('search'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.search),
                    icon: const Icon(Icons.search_outlined),
                  ),
                  IconButton(
                    tooltip: settings.t('bookmarksAndNotes'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.bookmarksNotes),
                    icon: const Icon(Icons.bookmarks_outlined),
                  ),
                  IconButton(
                    tooltip: settings.t('profile'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
            )
          : null,
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
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        LoadingIndicator(message: settings.t('loading')),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      children: [
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${settings.t('welcome')}, ${auth.user?.name.trim().split(' ').first ?? settings.t('guest')}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                settings.t('openLibrary'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: settings.t('searchHint'),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchCtrl.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: booksProvider.statsLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _StatItem(
                                        label: settings.t('books'),
                                        value: booksProvider.booksCount,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatItem(
                                        label: settings.t('users'),
                                        value: booksProvider.usersCount,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatItem(
                                        label: settings.t('departments'),
                                        value: booksProvider.departmentsCount,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          settings.t('departments'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        if (departments.isEmpty)
                          _EmptyGlass(text: settings.t('emptyDepartments'))
                        else
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: departments.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.05,
                            ),
                            itemBuilder: (_, index) {
                              final dept = departments[index];
                              return DepartmentCard(
                                department: dept,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.bookList,
                                  arguments: dept,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 18),
                        Text(
                          settings.t('newArrivals'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (books.isEmpty)
                          _EmptyGlass(text: settings.t('emptyBooks'))
                        else
                          Column(
                            children: books
                                .map(
                                  (book) => BookCard(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    book: book,
                                    department: _departmentById[book.departmentId],
                                    isFavorite: _favorites.contains(book.id),
                                    onFavoriteTap: () {
                                      setState(() {
                                        if (!_favorites.add(book.id)) {
                                          _favorites.remove(book.id);
                                        }
                                      });
                                    },
                                    onTap: () => Navigator.of(context).pushNamed(
                                      AppRoutes.reader,
                                      arguments: book,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGlass extends StatelessWidget {
  const _EmptyGlass({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
