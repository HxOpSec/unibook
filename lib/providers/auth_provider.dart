import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/models/user_model.dart';
import 'package:unibook/services/auth_service.dart';
import 'package:unibook/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider([AuthService? authService, FirestoreService? firestoreService])
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    initialize();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserModel?>? _profileSub;

  bool _isLoading = false;
  String? _error;
  User? _firebaseUser;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isAuthenticated => _firebaseUser != null;

  bool get isAdminOrTeacher => _user?.isAdmin == true || _user?.isTeacher == true;

  void initialize() {
    _authSub?.cancel();
    _authSub = _authService.authStateChanges().listen((firebaseUser) {
      _firebaseUser = firebaseUser;
      _profileSub?.cancel();
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
        return;
      }
      _profileSub = _firestoreService.streamUser(firebaseUser.uid).listen((profile) {
        _user = profile;
        notifyListeners();
      });
    });
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.login(email, password);
      final signedUser = _authService.currentUser;
      if (signedUser == null) {
        throw Exception(AppStrings.translate('errorGeneric'));
      }

      final profile = await _firestoreService.getUser(signedUser.uid);
      if (profile == null || !(profile.isAdmin || profile.isTeacher)) {
        await _authService.logout();
        throw Exception(AppStrings.translate('adminAccessDenied'));
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String departmentId,
    String? teacherCode,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      if (role == 'teacher' || role == 'admin') {
        final requiredCode = await _firestoreService.getTeacherCode();
        if (requiredCode.isNotEmpty && requiredCode != (teacherCode ?? '').trim()) {
          throw Exception('Неверный код учителя');
        }
      }

      final credential = await _authService.register(email, password);
      final uid = credential.user!.uid;

      await _firestoreService.createUserProfile(
        UserModel(
          uid: uid,
          name: name.trim(),
          email: email.trim(),
          role: role,
          departmentId: departmentId,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.logout();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
