import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibook/models/book_model.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection('books');
  CollectionReference<Map<String, dynamic>> get _departments =>
      _firestore.collection('departments');

  Future<void> createUserProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Stream<UserModel?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUserName(String uid, String name) async {
    await _users.doc(uid).update({'name': name.trim()});
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _users.doc(uid).update({'role': role});
  }

  Stream<List<UserModel>> streamUsers() {
    return _users.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<DepartmentModel>> streamDepartments() {
    return _departments.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<DepartmentModel>> getDepartments() async {
    final snapshot = await _departments.orderBy('name').get();
    return snapshot.docs
        .map((doc) => DepartmentModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addDepartment(String name, String code) async {
    await _departments.add({
      'name': name.trim(),
      'code': code.trim(),
      'bookCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDepartment({
    required String id,
    required String name,
    required String code,
  }) async {
    await _departments.doc(id).update({'name': name.trim(), 'code': code.trim()});
  }

  Future<void> deleteDepartment(String id) async {
    await _departments.doc(id).delete();
  }

  Stream<List<BookModel>> streamBooksByDepartment(String departmentId) {
    return _books
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<BookModel>> streamRecentBooks() {
    return _books
        .orderBy('createdAt', descending: true)
        .limit(12)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<BookModel>> streamBooksByUploader(String uid) {
    return _books
        .where('uploadedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addBook(BookModel book) async {
    await _books.add(book.toMap());
    await _departments.doc(book.departmentId).update({
      'bookCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteBook(BookModel book) async {
    await _books.doc(book.id).delete();
    await _departments.doc(book.departmentId).update({
      'bookCount': FieldValue.increment(-1),
    });
  }

  Future<void> incrementDownloadCount(String bookId) async {
    await _books.doc(bookId).update({'downloadCount': FieldValue.increment(1)});
  }

  Future<String> getTeacherCode() async {
    final doc = await _firestore.collection('settings').doc('app_settings').get();
    return (doc.data()?['teacherCode'] ?? '') as String;
  }

  Future<void> setTeacherCode(String code) async {
    await _firestore.collection('settings').doc('app_settings').set(
      {'teacherCode': code.trim(), 'appVersion': '1.0.0'},
      SetOptions(merge: true),
    );
  }

  Future<Map<String, int>> getStats() async {
    final books = await _books.count().get();
    final users = await _users.count().get();
    final departments = await _departments.count().get();
    return {
      'books': books.count ?? 0,
      'users': users.count ?? 0,
      'departments': departments.count ?? 0,
    };
  }
}
