import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapRegisterError(e.code));
    } catch (_) {
      throw Exception('Не удалось зарегистрироваться. Попробуйте позже.');
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
      throw Exception('Не удалось выполнить вход. Попробуйте позже.');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapCommonError(e.code));
    } catch (_) {
      throw Exception('Не удалось выйти из аккаунта. Попробуйте позже.');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapResetPasswordError(e.code));
    } catch (_) {
      throw Exception(
        'Не удалось отправить письмо для сброса пароля. Попробуйте позже.',
      );
    }
  }

  String _mapRegisterError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует.';
      case 'invalid-email':
        return 'Некорректный формат email.';
      case 'weak-password':
        return 'Слишком простой пароль. Используйте более сложный пароль.';
      case 'operation-not-allowed':
        return 'Регистрация временно недоступна.';
      case 'network-request-failed':
        return 'Нет подключения к интернету. Проверьте сеть.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже.';
      default:
        return 'Ошибка регистрации. Попробуйте позже.';
    }
  }

  String _mapLoginError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некорректный формат email.';
      case 'user-disabled':
        return 'Этот аккаунт отключён.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль.';
      case 'network-request-failed':
        return 'Нет подключения к интернету. Проверьте сеть.';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Попробуйте позже.';
      default:
        return 'Ошибка входа. Попробуйте позже.';
    }
  }

  String _mapResetPasswordError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некорректный формат email.';
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'network-request-failed':
        return 'Нет подключения к интернету. Проверьте сеть.';
      case 'too-many-requests':
        return 'Слишком много запросов. Попробуйте позже.';
      default:
        return 'Ошибка отправки письма для сброса пароля.';
    }
  }

  String _mapCommonError(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Нет подключения к интернету. Проверьте сеть.';
      case 'too-many-requests':
        return 'Слишком много запросов. Попробуйте позже.';
      default:
        return 'Произошла ошибка. Попробуйте позже.';
    }
  }
}
