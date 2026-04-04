import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/services/firestore_service.dart';

class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({super.key});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _controller = PdfViewerController();
  String? _filePath;
  double _progress = 0;
  int _page = 1;
  int _totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;
    if (_filePath == null) {
      _download(book);
    }
  }

  Future<void> _download(BookModel book) async {
    final path = '${Directory.systemTemp.path}/unibook_${book.id}.pdf';
    await Dio().download(
      book.fileUrl,
      path,
      onReceiveProgress: (received, total) {
        if (!mounted || total <= 0) return;
        setState(() => _progress = received / total);
      },
    );
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('last_page_${book.id}') ?? 1;
    await FirestoreService().incrementDownloadCount(book.id);
    if (!mounted) return;
    setState(() {
      _filePath = path;
      _page = savedPage;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.jumpToPage(savedPage);
    });
  }

  Future<void> _savePage(BookModel book) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${book.id}', _page);
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('$_page/$_totalPages'),
            ),
          ),
        ],
      ),
      body: _filePath == null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _progress == 0 ? null : _progress),
                  const SizedBox(height: 10),
                  Text('Загрузка PDF: ${(_progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'book-cover-${book.id}',
                    child: SfPdfViewer.file(
                      File(_filePath!),
                      controller: _controller,
                      onDocumentLoaded: (details) {
                        setState(() => _totalPages = details.document.pages.count);
                      },
                      onPageChanged: (details) {
                        setState(() => _page = details.newPageNumber);
                        _savePage(book);
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _controller.previousPage(),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: () => _controller.nextPage(),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
