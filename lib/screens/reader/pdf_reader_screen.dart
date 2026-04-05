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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filePath == null && _cancelToken == null) {
      final book = ModalRoute.of(context)!.settings.arguments as BookModel;
      _download(book);
    }
  }

  Future<void> _download(BookModel book) async {
    _cancelToken = CancelToken();
    final path = '${Directory.systemTemp.path}/unibook_${book.id}.pdf';
    try {
      await _dio.download(
        book.fileUrl,
        path,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() => _downloadProgress = received / total);
        },
      );
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('last_page_${book.id}') ?? 1;
      await context.read<FirestoreService>().incrementDownloadCount(book.id);
      if (!mounted) return;
      setState(() {
        _filePath = path;
        _page = savedPage;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pdfController.jumpToPage(savedPage);
        _resetHideTimer();
        if (savedPage > 1 && !_hasShownResume) {
          _hasShownResume = true;
          showSuccess(context, 'Продолжаем с страницы $savedPage');
        }
      });
    } catch (_) {
      if (!mounted) return;
      showError(context, 'Не удалось загрузить PDF файл');
      Navigator.of(context).maybePop();
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
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;
    if (_filePath == null) {
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
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14),
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

    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Positioned.fill(
              child: SfPdfViewer.file(
                File(_filePath!),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(
                            '$_page/$_totalPages',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
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
}
