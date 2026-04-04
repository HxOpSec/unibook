import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/services/firestore_service.dart';

enum BookSort { byDate, byTitle }

class BooksProvider extends ChangeNotifier {
  BooksProvider(this._firestoreService);

  final FirestoreService _firestoreService;

  StreamSubscription<List<BookModel>>? _sub;
  List<BookModel> _books = [];
  String _query = '';
  String? _subjectFilter;
  BookSort _sort = BookSort.byDate;
  bool _loading = false;

  List<BookModel> get books {
    var filtered = _books.where((book) {
      final q = _query.toLowerCase();
      final queryMatches = q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q);
      final subjectMatches = _subjectFilter == null || book.subject == _subjectFilter;
      return queryMatches && subjectMatches;
    }).toList();

    if (_sort == BookSort.byTitle) {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return filtered;
  }

  bool get loading => _loading;
  String get query => _query;
  String? get subjectFilter => _subjectFilter;
  BookSort get sort => _sort;

  List<String> get subjects =>
      _books.map((e) => e.subject).where((s) => s.trim().isNotEmpty).toSet().toList()
        ..sort();

  void subscribeDepartment(String departmentId) {
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _firestoreService.streamBooksByDepartment(departmentId).listen((items) {
      _books = items;
      _loading = false;
      notifyListeners();
    });
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void setSubject(String? value) {
    _subjectFilter = value;
    notifyListeners();
  }

  void setSort(BookSort value) {
    _sort = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
