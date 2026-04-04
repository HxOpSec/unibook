import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/department_card.dart';
import 'package:unibook/widgets/university_emblem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchTerm = '';
  List<DepartmentModel> _departments = [];
  List<BookModel> _recentBooks = [];
  bool _offline = false;
  bool _fabExtended = true;
  Map<String, int> _stats = const {'books': 0, 'users': 0, 'departments': 0};
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadStatsAndBooks();
    _scrollController = ScrollController()
      ..addListener(() {
        final shouldExtend = _scrollController.position.pixels < 30;
        if (_fabExtended != shouldExtend && mounted) {
          setState(() => _fabExtended = shouldExtend);
        }
      });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() => _offline = offline);
      }
    });
  }

  Future<void> _loadDepartments() async {
    final items = await context.read<FirestoreService>().getDepartments();
    if (!mounted) return;
    setState(() => _departments = items);
  }

  Future<void> _loadStatsAndBooks() async {
    final firestore = context.read<FirestoreService>();
    final stats = await firestore.getStats();
    final books = await firestore.streamRecentBooks().first;
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _recentBooks = books;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySub.cancel();
    super.dispose();
  }

  String _getGreetingMessage(String name) {
    final hour = DateTime.now().toLocal().hour;
    if (hour >= 6 && hour < 12) return 'Доброе утро, $name! ☀️';
    if (hour >= 12 && hour < 18) return 'Добрый день, $name! 👋';
    if (hour >= 18 && hour < 22) return 'Добрый вечер, $name! 🌙';
    return 'Доброй ночи, $name! 🌟';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final query = _searchTerm.toLowerCase();
    final departments = _departments
        .where((d) => d.name.toLowerCase().contains(query))
        .toList();
    final filteredRecentBooks = _recentBooks.where((book) {
      if (_searchTerm.trim().isEmpty) return true;
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.subject.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniBook — ТГФЭУ'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
            ),
          ),
        ),
        leadingWidth: 56,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Center(child: UniversityEmblem(size: 36, textSize: 9)),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            icon: CircleAvatar(
              radius: 14,
              child: Text(
                (user?.name.trim().isNotEmpty ?? false)
                    ? user!.name.trim().substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (user?.isTeacher ?? false) || (user?.isAdmin ?? false)
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _fabExtended
                  ? FloatingActionButton.extended(
                      key: const ValueKey('fab-extended'),
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить книгу'),
                    )
                  : FloatingActionButton(
                      key: const ValueKey('fab-icon'),
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.uploadBook),
                      child: const Icon(Icons.add),
                    ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDepartments();
          await _loadStatsAndBooks();
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            if (auth.isDeveloperMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF59D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'РЕЖИМ РАЗРАБОТЧИКА',
                  style: TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_offline)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                child: const Text(
                  'Офлайн режим',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) => Opacity(opacity: value, child: child),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFBBDEFB),
                      const Color(0xFF90CAF9).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreetingMessage(user?.name.isNotEmpty == true ? user!.name : 'друг'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('Что будем читать сегодня?'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              decoration: InputDecoration(
                hintText: 'Поиск книг, авторов, предметов...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => _searchTerm = ''),
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if ((user?.isTeacher ?? false) || (user?.isAdmin ?? false)) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(title: 'Всего книг', value: _stats['books'] ?? 0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatCard(
                      title: 'Пользователей',
                      value: _stats['users'] ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatCard(
                      title: 'Кафедр',
                      value: _stats['departments'] ?? 0,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Кафедры университета',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            departments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 34),
                    child: Center(child: Text('Кафедры не найдены')),
                  )
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: departments.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.06,
                    ),
                    itemBuilder: (context, index) {
                      final department = departments[index];
                      return DepartmentCard(
                        department: department,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.bookList,
                            arguments: department,
                          );
                        },
                      );
                    },
                  ),
            const SizedBox(height: 16),
            const Text(
              'Новые поступления',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: filteredRecentBooks.isEmpty
                  ? const Center(child: Text('Пока нет новых поступлений'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredRecentBooks.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final book = filteredRecentBooks[index];
                        return SizedBox(
                          width: 160,
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
                                          color: Colors.blue.shade50,
                                        ),
                                        child: const Icon(Icons.menu_book, size: 38),
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
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.title, required this.value});

  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 700),
              builder: (context, animValue, _) {
                return Text(
                  animValue.round().toString(),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
