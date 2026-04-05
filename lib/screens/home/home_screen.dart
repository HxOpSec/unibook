import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/tgfeu_data.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_list_item.dart';
import 'package:unibook/widgets/about_dialog_content.dart';
import 'package:unibook/widgets/department_card.dart';
import 'package:unibook/widgets/empty_state.dart';
import 'package:unibook/widgets/university_emblem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  int _tabIndex = 0;
  bool _fabExtended = true;
  bool _offline = false;

  List<DepartmentModel> _departments = [];
  List<BookModel> _recentBooks = [];
  Map<String, int> _stats = const {'books': 0, 'users': 0, 'departments': 0};
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) setState(() => _offline = results.contains(ConnectivityResult.none));
    });
    _scrollController.addListener(() {
      final shouldExpand = _scrollController.position.pixels < 20;
      if (_fabExtended != shouldExpand && mounted) {
        setState(() => _fabExtended = shouldExpand);
      }
    });
  }

  Future<void> _loadAll() async {
    final firestore = context.read<FirestoreService>();
    final departments = await firestore.getDepartments();
    final recentBooks = await firestore.streamRecentBooks().first;
    final stats = await firestore.getStats();
    if (!mounted) return;
    setState(() {
      _departments = departments;
      _recentBooks = recentBooks;
      _stats = stats;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    _connectivitySub.cancel();
    super.dispose();
  }

  String _greeting(String fullName) {
    final firstName = fullName.trim().split(' ').first;
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return '☀️ Доброе утро, $firstName!';
    if (hour >= 12 && hour < 17) return '👋 Добрый день, $firstName!';
    if (hour >= 17 && hour < 22) return '🌙 Добрый вечер, $firstName!';
    return '🌟 Доброй ночи, $firstName!';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isTeacherOrAdmin = (user?.isTeacher ?? false) || (user?.isAdmin ?? false);
    final query = _searchCtrl.text.toLowerCase();
    final filteredBooks = _recentBooks.where((book) {
      if (query.isEmpty) return true;
      return book.title.toLowerCase().contains(query) || book.author.toLowerCase().contains(query);
    }).toList();
    final filteredDepartments = _departments.where((d) {
      if (query.isEmpty) return true;
      return d.name.toLowerCase().contains(query) || d.code.toLowerCase().contains(query);
    }).toList();

    return DefaultTabController(
      length: faculties.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          titleSpacing: 8,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => _showTgfeuAboutDialog(context),
              child: const Center(child: TgfeuLogo(size: 36, textSize: 9, showStar: false)),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('UniBook', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('ТГФЭУ', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _showNotificationsInfo(context),
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (user?.name.trim().isNotEmpty ?? false)
                      ? user!.name.trim().substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54),
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(Icons.search, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Поиск книг и авторов...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: isTeacherOrAdmin
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _fabExtended
                    ? FloatingActionButton.extended(
                        key: const ValueKey('fabExt'),
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить книгу'),
                      )
                    : FloatingActionButton(
                        key: const ValueKey('fab'),
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
                        child: const Icon(Icons.add),
                      ),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: _loadAll,
          child: IndexedStack(
            index: _tabIndex,
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  if (auth.isDeveloperMode)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      color: const Color(0xFFFFF9C4),
                      child: const Text(
                        '⚠ РЕЖИМ РАЗРАБОТЧИКА — не для продакшена',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (_offline)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: EmptyState(
                        icon: Icons.wifi_off,
                        title: 'Нет интернета',
                        subtitle: 'Показаны сохранённые данные',
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(user?.name ?? 'друг'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Что будем читать сегодня?',
                          style: TextStyle(fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  if (isTeacherOrAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.menu_book_rounded,
                              color: AppColors.primary,
                              label: 'Книг',
                              value: _stats['books'] ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.people_alt_outlined,
                              color: AppColors.success,
                              label: 'Студентов',
                              value: _stats['users'] ?? 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.school_outlined,
                              color: Colors.purple,
                              label: 'Кафедр',
                              value: _stats['departments'] ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Факультеты и кафедры',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => _searchCtrl.clear()),
                          child: const Text('Все →'),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: faculties.map((f) => Tab(text: f.shortName)).toList(),
                  ),
                  SizedBox(
                    height: 360,
                    child: TabBarView(
                      children: faculties.map((faculty) {
                        final deps = filteredDepartments
                            .where((d) => d.facultyId == faculty.id)
                            .toList();
                        if (deps.isEmpty) {
                          return const EmptyState(
                            icon: Icons.search_off,
                            title: 'Ничего не найдено',
                            subtitle: 'Попробуйте другой запрос',
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.18,
                          ),
                          itemCount: deps.length,
                          itemBuilder: (context, index) {
                            final dept = deps[index];
                            return AnimatedListItem(
                              index: index,
                              child: DepartmentCard(
                                department: dept,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.bookList,
                                  arguments: dept,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Новые поступления',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filteredBooks.isEmpty)
                    const SizedBox(
                      height: 140,
                      child: EmptyState(
                        icon: Icons.menu_book,
                        title: 'Пока нет книг в библиотеке',
                        subtitle: 'Будьте первым кто добавит книгу',
                      ),
                    )
                  else
                    SizedBox(
                      height: 208,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredBooks.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return AnimatedListItem(
                            index: index,
                            child: Container(
                              width: 168,
                              margin: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.reader,
                                  arguments: book,
                                ),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primary.withOpacity(0.2),
                                                  AppColors.primaryLight.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.menu_book, size: 42),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          book.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.author,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const EmptyState(
                icon: Icons.library_books_outlined,
                title: 'Каталог',
                subtitle: 'Каталог доступен с главной страницы',
              ),
              const EmptyState(
                icon: Icons.bookmark_border,
                title: 'Нет избранных',
                subtitle: 'Добавляйте книги в избранное',
              ),
              if (isTeacherOrAdmin)
                const EmptyState(
                  icon: Icons.upload_outlined,
                  title: 'Мои книги',
                  subtitle: 'Откройте раздел профиля или кнопку загрузки',
                ),
              const EmptyState(
                icon: Icons.person_outline,
                title: 'Профиль',
                subtitle: 'Откройте профиль через аватар вверху',
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (v) => setState(() => _tabIndex = v),
          selectedItemColor: AppColors.primary,
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          items: isTeacherOrAdmin
              ? const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Главная'),
                  BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Каталог'),
                  BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Избранное'),
                  BottomNavigationBarItem(icon: Icon(Icons.upload_outlined), label: 'Мои книги'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
                ]
              : const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Главная'),
                  BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Каталог'),
                  BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Избранное'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
                ],
        ),
      ),
    );
  }

  void _showTgfeuAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(content: AboutDialogContent()),
    );
  }

  void _showNotificationsInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Уведомления появятся в следующем обновлении')),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => Text(
              v.round().toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
