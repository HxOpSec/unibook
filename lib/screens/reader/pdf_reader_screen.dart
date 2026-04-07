import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/bookmark_model.dart';
import 'package:unibook/models/note_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/bookmarks_notes_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/university_emblem.dart';

class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({super.key});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _pdfController = PdfViewerController();
  final _dio = Dio();
  CancelToken? _cancelToken;
  Timer? _hideTimer;

  String? _filePath;
  double _downloadProgress = 0;
  int _page = 1;
  int _totalPages = 1;
  bool _showControls = true;
  bool _hasShownResume = false;
  BookModel? _book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_book == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is BookModel) _book = args;
    }
    if (_book != null && _filePath == null && _cancelToken == null) {
      _download(_book!);
    }
    // Subscribe to bookmarks/notes for the current user
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      context.read<BookmarksNotesProvider>().subscribe(uid);
    }
  }

  Future<void> _download(BookModel book) async {
    _cancelToken = CancelToken();
    final path = '${Directory.systemTemp.path}/unibook_${book.id}.pdf';
    try {
      final fileUrl = book.fileUrl.trim();
      if (fileUrl.isEmpty) {
        throw Exception('URL файла отсутствует');
      }
      final uri = Uri.tryParse(fileUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        throw Exception('Некорректная ссылка на файл');
      }

      await _dio.download(
        fileUrl,
        path,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() => _downloadProgress = received / total);
        },
      );
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('last_page_${book.id}') ?? 1;
      if (!mounted) return;
      await context.read<FirestoreService>().incrementDownloadCount(book.id);
      if (!mounted) return;
      setState(() {
        _filePath = path;
        _page = savedPage < 1 ? 1 : savedPage;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pdfController.jumpToPage(_page);
        _resetHideTimer();
        if (_page > 1 && !_hasShownResume) {
          _hasShownResume = true;
          showSuccess(context, 'Продолжаем с страницы $_page');
        }
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('PDF download error: $e');
      showError(context, 'Не удалось загрузить PDF файл');
      setState(() {
        _filePath = '';
      });
    }
  }

  Future<void> _savePage(BookModel book) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${book.id}', _page);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;
    if (book == null) {
      return const Scaffold(
        body: Center(child: Text('Книга не выбрана')),
      );
    }

    final filePath = _filePath;
    if (filePath == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TgfeuLogo(size: 60, textSize: 14),
                    const SizedBox(height: 24),
                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _downloadProgress == 0 ? null : _downloadProgress,
                        minHeight: 6,
                        backgroundColor: Colors.white30,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Загрузка... ${(_downloadProgress * 100).round()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _cancelToken?.cancel();
                        Navigator.of(context).maybePop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (filePath.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Не удалось открыть книгу',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Проверьте подключение к интернету или попробуйте позже.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _filePath = null;
                      _downloadProgress = 0;
                    });
                    _download(book);
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Positioned.fill(
              child: SfPdfViewer.file(
                File(filePath),
                controller: _pdfController,
                onDocumentLoaded: (details) {
                  setState(() => _totalPages = details.document.pages.count);
                },
                onPageChanged: (details) {
                  setState(() => _page = details.newPageNumber);
                  _savePage(book);
                  _resetHideTimer();
                },
              ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          '$_page/$_totalPages',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        _BookmarkButton(book: book, page: _page),
                        IconButton(
                          onPressed: () => _showAddNoteDialog(context, book),
                          tooltip: 'Добавить заметку',
                          icon: const Icon(Icons.note_add_outlined, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 6,
                      bottom: MediaQuery.of(context).padding.bottom + 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _pdfController.previousPage(),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: _totalPages.toDouble(),
                            value: _page.clamp(1, _totalPages).toDouble(),
                            onChanged: (v) {
                              final target = v.round();
                              _pdfController.jumpToPage(target);
                              setState(() => _page = target);
                              _resetHideTimer();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () => _pdfController.nextPage(),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddNoteDialog(BuildContext context, BookModel book) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Заметка — стр. $_page'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Введите заметку...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty || !mounted) return;

    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid == null) return;

    final note = NoteModel(
      id: '',
      userId: uid,
      bookId: book.id,
      bookTitle: book.title,
      page: _page,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    await context.read<BookmarksNotesProvider>().addNote(note);
    if (!mounted) return;
    showSuccess(context, 'Заметка добавлена');
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.book, required this.page});

  final BookModel book;
  final int page;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksNotesProvider>();
    final isBookmarked = provider.isPageBookmarked(book.id, page);
    final auth = context.read<AuthProvider>();

    return IconButton(
      tooltip: isBookmarked ? 'Убрать закладку' : 'Добавить закладку',
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: Colors.white,
      ),
      onPressed: () async {
        final uid = auth.firebaseUser?.uid;
        if (uid == null) return;

        if (isBookmarked) {
          final bm = provider.bookmarkForPage(book.id, page);
          if (bm != null) {
            await provider.deleteBookmark(bm.id);
            if (context.mounted) showSuccess(context, 'Закладка удалена');
          }
        } else {
          final bookmark = BookmarkModel(
            id: '',
            userId: uid,
            bookId: book.id,
            bookTitle: book.title,
            page: page,
            createdAt: DateTime.now(),
          );
          await provider.addBookmark(bookmark);
          if (context.mounted) showSuccess(context, 'Закладка добавлена');
        }
      },
    );
  }
}
