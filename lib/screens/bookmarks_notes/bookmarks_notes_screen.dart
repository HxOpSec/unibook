import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/models/bookmark_model.dart';
import 'package:unibook/models/note_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/bookmarks_notes_provider.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/empty_state.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/loading_indicator.dart';

class BookmarksNotesScreen extends StatefulWidget {
  const BookmarksNotesScreen({super.key});

  @override
  State<BookmarksNotesScreen> createState() => _BookmarksNotesScreenState();
}

class _BookmarksNotesScreenState extends State<BookmarksNotesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid = auth.firebaseUser?.uid;
      if (uid != null) {
        context.read<BookmarksNotesProvider>().subscribe(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final provider = context.watch<BookmarksNotesProvider>();
    final auth = context.watch<AuthProvider>();
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

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(settings.t('bookmarksAndNotes'))),
        body: EmptyState(
          icon: Icons.bookmark_border,
          title: settings.t('notAuthorized'),
          subtitle: settings.t('signInToAdmin'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(settings.t('bookmarksAndNotes')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.bookmark_outlined), text: settings.t('bookmarks')),
            Tab(icon: const Icon(Icons.note_outlined), text: settings.t('notes')),
          ],
        ),
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
            child: provider.loading
                ? LoadingIndicator(message: settings.t('loading'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _BookmarksList(
                        bookmarks: provider.bookmarks,
                        onDelete: (id) =>
                            context.read<BookmarksNotesProvider>().deleteBookmark(id),
                        onTap: _openBook,
                      ),
                      _NotesList(
                        notes: provider.notes,
                        onDelete: (id) =>
                            context.read<BookmarksNotesProvider>().deleteNote(id),
                        onEdit: (note) => _editNote(context, note),
                        onTap: _openBook,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBook(String bookId, int page) async {
    // Navigate to reader cannot be done without the BookModel, so we show a
    // helpful message to the user to open the book from the library instead.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Откройте книгу из раздела «Кафедры» или «Новые поступления»'),
        action: SnackBarAction(
          label: 'ОК',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _editNote(BuildContext context, NoteModel note) async {
    final controller = TextEditingController(text: note.text);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать заметку'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Текст заметки...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      await context.read<BookmarksNotesProvider>().updateNote(note.id, result);
    }
    controller.dispose();
  }
}

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({
    required this.bookmarks,
    required this.onDelete,
    required this.onTap,
  });

  final List<BookmarkModel> bookmarks;
  final void Function(String id) onDelete;
  final void Function(String bookId, int page) onTap;

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const EmptyState(
        icon: Icons.bookmark_border,
        title: 'Нет закладок',
        subtitle: 'Добавляйте закладки во время чтения',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        return GlassCard(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.bookmark, color: Colors.white, size: 20),
            ),
            title: Text(
              bm.bookTitle.isNotEmpty ? bm.bookTitle : 'Книга',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${bm.label.isNotEmpty ? "${bm.label} · " : ""}Страница ${bm.page}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => onDelete(bm.id),
            ),
            onTap: () => onTap(bm.bookId, bm.page),
          ),
        );
      },
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  final List<NoteModel> notes;
  final void Function(String id) onDelete;
  final void Function(NoteModel note) onEdit;
  final void Function(String bookId, int page) onTap;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.note_outlined,
        title: 'Нет заметок',
        subtitle: 'Добавляйте заметки во время чтения',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GlassCard(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.note, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.bookTitle.isNotEmpty ? note.bookTitle : 'Книга',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'Стр. ${note.page}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.primary,
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    onPressed: () => onEdit(note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                    onPressed: () => onDelete(note.id),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(note.text, style: const TextStyle(fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}
