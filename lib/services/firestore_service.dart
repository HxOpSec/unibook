import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = (Firebase.apps.isNotEmpty)
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  final FirebaseFirestore? _firestore;

  bool get isAvailable => _firestore != null;

  CollectionReference<Map<String, dynamic>>? get _users =>
      _firestore?.collection('users');
  CollectionReference<Map<String, dynamic>>? get _books =>
      _firestore?.collection('books');
  CollectionReference<Map<String, dynamic>>? get _departments =>
      _firestore?.collection('departments');

  static const List<DepartmentModel> _fallbackDepartments = [
    DepartmentModel(
      id: 'dept_fin_economics',
      name: 'Кафедра финансовой экономики',
      code: 'FE',
      facultyId: 'faculty_finance',
      facultyName: 'Факультет финансов',
      building: 'Корпус 1',
      room: '310',
      icon: 'trending_up',
      color: '#00695C',
      bookCount: 2,
      createdAt: DateTime(2024, 1, 1),
    ),
    DepartmentModel(
      id: 'dept_econ_theory',
      name: 'Кафедра экономической теории',
      code: 'ET',
      facultyId: 'faculty_economics',
      facultyName: 'Факультет экономики',
      building: 'Корпус 2',
      room: '405',
      icon: 'school',
      color: '#558B2F',
      bookCount: 2,
      createdAt: DateTime(2024, 1, 1),
    ),
    DepartmentModel(
      id: 'dept_digital',
      name: 'Кафедра цифровой экономики и логистики',
      code: 'DEL',
      facultyId: 'faculty_digital',
      facultyName: 'Факультет цифровой экономики',
      building: 'Корпус 3',
      room: '205',
      icon: 'devices',
      color: '#006064',
      bookCount: 2,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  static final List<BookModel> _fallbackBooks = [
    BookModel(
      id: 'demo_book_fin_analysis',
      title: 'Финансовый анализ предприятия',
      author: 'А. В. Грачёв',
      year: 2021,
      subject: 'Финансовый анализ',
      departmentId: 'dept_fin_economics',
      uploadedBy: 'demo_user',
      uploaderName: 'Demo User',
      fileUrl: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      publicId: 'unibook/books/demo_book_fin_analysis',
      coverUrl: null,
      downloadCount: 0,
      createdAt: DateTime(2025, 1, 14),
    ),
    BookModel(
      id: 'demo_book_econ_theory',
      title: 'Основы экономической теории',
      author: 'П. А. Самуэльсон',
      year: 2019,
      subject: 'Экономическая теория',
      departmentId: 'dept_econ_theory',
      uploadedBy: 'demo_user',
      uploaderName: 'Demo User',
      fileUrl: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      publicId: 'unibook/books/demo_book_econ_theory',
      coverUrl: null,
      downloadCount: 0,
      createdAt: DateTime(2025, 2, 2),
    ),
    BookModel(
      id: 'demo_book_digital_econ',
      title: 'Цифровая экономика и информационные технологии',
      author: 'В. Б. Кузнецов',
      year: 2022,
      subject: 'Цифровая экономика',
      departmentId: 'dept_digital',
      uploadedBy: 'demo_user',
      uploaderName: 'Demo User',
      fileUrl: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
      publicId: 'unibook/books/demo_book_digital_econ',
      coverUrl: null,
      downloadCount: 0,
      createdAt: DateTime(2025, 3, 10),
    ),
  ];

  Future<void> createUserProfile(UserModel user) async {
    final users = _users;
    if (users == null) return;
    await users.doc(user.uid).set(user.toMap());
  }

  Stream<UserModel?> streamUser(String uid) {
    final users = _users;
    if (users == null) return const Stream<UserModel?>.empty();
    return users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    }).handleError((Object e, StackTrace st) {
      debugPrint('streamUser error: $e');
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final users = _users;
    if (users == null) return null;
    try {
      final doc = await users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('getUser error: $e');
      return null;
    }
  }

  Future<void> updateUserName(String uid, String name) async {
    final users = _users;
    if (users == null) return;
    await users.doc(uid).update({'name': name.trim()});
  }

  Future<void> updateUserRole(String uid, String role) async {
    final users = _users;
    if (users == null) return;
    await users.doc(uid).update({'role': role});
  }

  Stream<List<UserModel>> streamUsers() {
    final users = _users;
    if (users == null) return Stream.value(const <UserModel>[]);
    return users.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        ).handleError((Object e, StackTrace st) {
          debugPrint('streamUsers error: $e');
        });
  }

  Stream<List<DepartmentModel>> streamDepartments() {
    final departments = _departments;
    if (departments == null) {
      return Stream.value(_fallbackDepartments);
    }
    return departments.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
              .toList(),
        ).handleError((Object e, StackTrace st) {
          debugPrint('streamDepartments error: $e');
        });
  }

  Future<List<DepartmentModel>> getDepartments() async {
    final departments = _departments;
    if (departments == null) return _fallbackDepartments;
    try {
      final snapshot = await departments.orderBy('name').get();
      final items = snapshot.docs
          .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
          .toList();
      return items.isEmpty ? _fallbackDepartments : items;
    } catch (e) {
      debugPrint('getDepartments error: $e');
      return _fallbackDepartments;
    }
  }

  Future<Map<String, DepartmentModel>> getDepartmentsMap() async {
    final deps = await getDepartments();
    return {for (final d in deps) d.id: d};
  }

  Future<void> addDepartment(String name, String code) async {
    final departments = _departments;
    if (departments == null) return;
    await departments.add({
      'name': name.trim(),
      'code': code.trim(),
      'facultyId': 'faculty_economics',
      'facultyName': 'Факультет экономики и государственного управления',
      'building': '',
      'room': '',
      'icon': 'school',
      'color': '#1565C0',
      'head': '',
      'bookCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDepartment({
    required String id,
    required String name,
    required String code,
  }) async {
    final departments = _departments;
    if (departments == null) return;
    await departments.doc(id).update({
      'name': name.trim(),
      'code': code.trim(),
    });
  }

  Future<void> deleteDepartment(String id) async {
    final departments = _departments;
    if (departments == null) return;
    await departments.doc(id).delete();
  }

  Stream<List<BookModel>> streamBooksByDepartment(String departmentId) {
    final books = _books;
    if (books == null) {
      return Stream.value(
        _fallbackBooks.where((e) => e.departmentId == departmentId).toList(),
      );
    }
    return books
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        ).handleError((Object e, StackTrace st) {
      debugPrint('streamBooksByDepartment error: $e');
    });
  }

  Stream<List<BookModel>> streamRecentBooks({int limit = 12}) {
    final books = _books;
    if (books == null) {
      final items = List<BookModel>.from(_fallbackBooks)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Stream.value(items.take(limit).toList());
    }
    return books
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        ).handleError((Object e, StackTrace st) {
      debugPrint('streamRecentBooks error: $e');
    });
  }

  Stream<List<BookModel>> streamBooksByUploader(String uid) {
    final books = _books;
    if (books == null) return Stream.value(const <BookModel>[]);
    return books
        .where('uploadedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        ).handleError((Object e, StackTrace st) {
      debugPrint('streamBooksByUploader error: $e');
    });
  }

  Future<void> addBook(BookModel book) async {
    final books = _books;
    final departments = _departments;
    if (books == null || departments == null) {
      throw Exception('Firebase Firestore не настроен');
    }

    final docRef = book.id.isNotEmpty ? books.doc(book.id) : books.doc();
    final bookId = docRef.id;

    await docRef.set({
      ...book.toMap(),
      'id': bookId,
    });

    await departments.doc(book.departmentId).update({
      'bookCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteBook(BookModel book) async {
    final books = _books;
    final departments = _departments;
    if (books == null || departments == null) return;

    if (book.id.isNotEmpty) {
      await books.doc(book.id).delete();
    }

    await departments.doc(book.departmentId).update({
      'bookCount': FieldValue.increment(-1),
    });
  }

  Future<void> incrementDownloadCount(String bookId) async {
    final books = _books;
    if (books == null) return;
    await books.doc(bookId).update({'downloadCount': FieldValue.increment(1)});
  }

  Future<String> getTeacherCode() async {
    if (_firestore == null) return '';
    try {
      final doc = await _firestore.collection('settings').doc('app_settings').get();
      final data = doc.data();
      if (data == null) return '';
      return (data['teacherCode'] as String?) ?? '';
    } catch (e) {
      debugPrint('getTeacherCode error: $e');
      return '';
    }
  }

  Future<void> setTeacherCode(String code) async {
    if (_firestore == null) return;
    await _firestore.collection('settings').doc('app_settings').set(
      {'teacherCode': code.trim(), 'appVersion': '1.0.0'},
      SetOptions(merge: true),
    );
  }

  Future<int> getBooksCount() async {
    final books = _books;
    if (books == null) return _fallbackBooks.length;
    try {
      final snap = await books.count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('getBooksCount error: $e');
      return _fallbackBooks.length;
    }
  }

  Future<int> getUsersCount() async {
    final users = _users;
    if (users == null) return 0;
    try {
      final snap = await users.count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('getUsersCount error: $e');
      return 0;
    }
  }

  Future<int> getDepartmentsCount() async {
    final departments = _departments;
    if (departments == null) return _fallbackDepartments.length;
    try {
      final snap = await departments.count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('getDepartmentsCount error: $e');
      return _fallbackDepartments.length;
    }
  }

  Future<Map<String, int>> getStats() async {
    final booksCount = await getBooksCount();
    final usersCount = await getUsersCount();
    final departmentsCount = await getDepartmentsCount();

    return {
      'books': booksCount,
      'users': usersCount,
      'departments': departmentsCount,
    };
  }
}
