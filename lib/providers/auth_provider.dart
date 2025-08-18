import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  auth.User? get currentUser => _firebaseAuth.currentUser;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signIn(email, password);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.register(email, password, name);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Registration failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication failed.';
    }
  }
}
