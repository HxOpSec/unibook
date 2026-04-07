import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/book_card.dart';
import 'package:unibook/widgets/department_card.dart';
import 'package:unibook/widgets/empty_state.dart';
import 'package:unibook/widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _historyKey = 'search_history';
  static const _maxHistory = 10;

  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  List<String> _history = [];
  List<BookModel> _bookResults = [];
  List<DepartmentModel> _deptResults = [];
  bool _searching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    if (mounted) setState(() => _history = history);
  }

  Future<void> _saveToHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [
      query,
      ..._history.where((h) => h != query),
    ].take(_maxHistory).toList();
    await prefs.setStringList(_historyKey, updated);
    if (mounted) setState(() => _history = updated);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) setState(() => _history = []);
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _bookResults = [];
        _deptResults = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _searching = true);
    await _saveToHistory(q);

    try {
      final service = context.read<FirestoreService>();
      final lower = q.toLowerCase();

      final allBooks = await service.streamRecentBooks(limit: 100).first;
      final allDepts = await service.getDepartments();

      final books = allBooks.where((b) {
        return b.title.toLowerCase().contains(lower) ||
            b.author.toLowerCase().contains(lower) ||
            b.subject.toLowerCase().contains(lower);
      }).toList();

      final depts = allDepts.where((d) {
        return d.name.toLowerCase().contains(lower) ||
            d.code.toLowerCase().contains(lower) ||
            d.facultyName.toLowerCase().contains(lower);
      }).toList();

      if (!mounted) return;
      setState(() {
        _bookResults = books;
        _deptResults = depts;
        _searching = false;
        _hasSearched = true;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _searching = false);
    }
  }

  void _submitSearch() => _search(_searchCtrl.text);

  void _selectHistory(String query) {
    _searchCtrl.text = query;
    _search(query);
  }

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
      appBar: AppBar(
        titleSpacing: 0,
        title: Hero(
          tag: 'search_bar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focusNode,
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  setState(() {
                    _bookResults = [];
                    _deptResults = [];
                    _hasSearched = false;
                  });
                }
              },
              onSubmitted: (_) => _submitSearch(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: settings.t('searchHint'),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _bookResults = [];
                            _deptResults = [];
                            _hasSearched = false;
                          });
                        },
                      ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _submitSearch,
          ),
        ],
      ),
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
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? _buildResults(settings)
                    : _buildSuggestions(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(SettingsProvider settings) {
    if (_history.isEmpty) {
      return EmptyState(
        icon: Icons.search,
        title: settings.t('search'),
        subtitle: settings.t('searchSuggestion'),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                settings.t('recentSearches'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: _clearHistory,
              child: Text(settings.t('clearHistory')),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._history.map(
          (h) => GlassCard(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: Text(h),
              trailing: const Icon(Icons.north_west, size: 16),
              onTap: () => _selectHistory(h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(SettingsProvider settings) {
    if (_bookResults.isEmpty && _deptResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: settings.t('noResults'),
        subtitle: '"${_searchCtrl.text}"',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (_deptResults.isNotEmpty) ...[
          Text(
            settings.t('departments'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _deptResults.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (_, index) {
              final dept = _deptResults[index];
              return DepartmentCard(
                department: dept,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.bookList,
                  arguments: dept,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        if (_bookResults.isNotEmpty) ...[
          Text(
            settings.t('books'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ..._bookResults.map(
            (book) => BookCard(
              margin: const EdgeInsets.symmetric(vertical: 5),
              book: book,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.reader,
                arguments: book,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
