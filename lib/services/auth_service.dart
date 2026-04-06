import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = (Firebase.apps.isNotEmpty)
            ? (firebaseAuth ?? FirebaseAuth.instance)
            : null;

  final FirebaseAuth? _firebaseAuth;

  bool get isAvailable => _firebaseAuth != null;

  Stream<User?> authStateChanges() {
    final auth = _firebaseAuth;
    if (auth == null) return const Stream<User?>.empty();
    return auth.authStateChanges();
  }

  User? get currentUser => _firebaseAuth?.currentUser;

  Future<UserCredential> register(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase Auth не настроен');
    }
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapRegisterError(e.code));
    } catch (_) {
      throw Exception('Ошибка регистрации. Попробуйте позже');
    }
  }

  Future<UserCredential> login(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase Auth не настроен');
    }
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapLoginError(e.code));
    } catch (_) {
      throw Exception('Ошибка входа. Попробуйте позже');
    }
  }

  Future<void> logout() async {
    final auth = _firebaseAuth;
    if (auth == null) return;
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase Auth не настроен');
    }
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw Exception('Нет подключения к интернету');
      }
      throw Exception('Не удалось отправить письмо для сброса');
    }
  }

  String _mapRegisterError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'weak-password':
        return 'Пароль должен содержать минимум 6 символов';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      default:
        return 'Ошибка регистрации. Попробуйте позже';
    }
  }

  String _mapLoginError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Неверный email или пароль';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      default:
        return 'Ошибка входа. Попробуйте позже';
    }
  }
}
