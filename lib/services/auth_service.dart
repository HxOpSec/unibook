import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
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
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
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
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
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
