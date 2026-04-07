import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unibook/models/bookmark_model.dart';
import 'package:unibook/models/note_model.dart';
import 'package:unibook/services/firestore_service.dart';

class BookmarksNotesProvider extends ChangeNotifier {
  BookmarksNotesProvider([FirestoreService? firestoreService])
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  StreamSubscription<List<BookmarkModel>>? _bookmarksSub;
  StreamSubscription<List<NoteModel>>? _notesSub;

  List<BookmarkModel> _bookmarks = [];
  List<NoteModel> _notes = [];
  bool _loading = false;
  String? _error;

  List<BookmarkModel> get bookmarks => _bookmarks;
  List<NoteModel> get notes => _notes;
  bool get loading => _loading;
  String? get error => _error;

  List<BookmarkModel> bookmarksForBook(String bookId) =>
      _bookmarks.where((b) => b.bookId == bookId).toList();

  List<NoteModel> notesForBook(String bookId) =>
      _notes.where((n) => n.bookId == bookId).toList();

  bool isPageBookmarked(String bookId, int page) =>
      _bookmarks.any((b) => b.bookId == bookId && b.page == page);

  BookmarkModel? bookmarkForPage(String bookId, int page) =>
      _bookmarks.where((b) => b.bookId == bookId && b.page == page).firstOrNull;

  void subscribe(String userId) {
    _loading = true;
    _error = null;
    notifyListeners();

    _bookmarksSub?.cancel();
    _notesSub?.cancel();

    _bookmarksSub = _firestoreService.streamBookmarks(userId).listen(
      (items) {
        _bookmarks = items;
        _loading = false;
        notifyListeners();
      },
      onError: (e, st) {
        debugPrint('BookmarksNotesProvider bookmarks error: $e');
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );

    _notesSub = _firestoreService.streamNotes(userId).listen(
      (items) {
        _notes = items;
        notifyListeners();
      },
      onError: (e, st) {
        debugPrint('BookmarksNotesProvider notes error: $e');
      },
    );
  }

  void clear() {
    _bookmarksSub?.cancel();
    _notesSub?.cancel();
    _bookmarks = [];
    _notes = [];
    notifyListeners();
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _firestoreService.addBookmark(bookmark);
    } catch (e) {
      debugPrint('addBookmark error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _firestoreService.deleteBookmark(bookmarkId);
    } catch (e) {
      debugPrint('deleteBookmark error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addNote(NoteModel note) async {
    try {
      await _firestoreService.addNote(note);
    } catch (e) {
      debugPrint('addNote error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(String noteId, String text) async {
    try {
      await _firestoreService.updateNote(noteId, text);
    } catch (e) {
      debugPrint('updateNote error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _firestoreService.deleteNote(noteId);
    } catch (e) {
      debugPrint('deleteNote error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bookmarksSub?.cancel();
    _notesSub?.cancel();
    super.dispose();
  }
}
