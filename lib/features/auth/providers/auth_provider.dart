import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  AuthStatus _status = AuthStatus.Uninitialized;
  String? _error;
  UserModel? _currentUser;

  AuthProvider(this._firebaseService) {
    _status = AuthStatus.Uninitialized;
    _firebaseService.user.listen(_onAuthStateChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    // Give the stream a moment to emit
    await Future.delayed(const Duration(seconds: 1));

    // If still uninitialized (e.g. Mock Mode or silent stream),
    // transition to Unauthenticated so the user can login
    if (_status == AuthStatus.Uninitialized) {
      // Check if we are in mock mode or just timed out
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
    }
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _currentUser;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.Authenticating;

  // Sign In
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.Authenticating;
      _error = null;
      notifyListeners();

      final user = await _firebaseService.signInWithEmail(email, password);
      _currentUser = user;
      _status = AuthStatus.Authenticated;
      notifyListeners();
      return true;
    } on auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseAuthError(e.code);
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "An unexpected error occurred.";
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Sign Up
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.Authenticating;
      _error = null;
      notifyListeners();

      final user = await _firebaseService.signUpWithEmail(email, password);
      _currentUser = user;
      _status = AuthStatus.Authenticated;
      notifyListeners();
      return true;
    } on auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseAuthError(e.code);
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "An unexpected error occurred.";
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseService.signOut();
    _status = AuthStatus.Unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.resetPassword(email);
    } on auth.FirebaseAuthException catch (e) {
      _error = _mapFirebaseAuthError(e.code);
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(Object? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.Unauthenticated;
    } else {
      _currentUser = await _firebaseService.getCurrentUser();
      _status = AuthStatus.Authenticated;
    }
    notifyListeners();
  }

  // Helper method to map Firebase errors to user-friendly messages
  String _mapFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "An account already exists with this email.";
      case 'weak-password':
        return "Password should be at least 8 characters.";
      case 'invalid-email':
        return "Please enter a valid email address.";
      case 'network-request-failed':
        return "Network error. Please check your connection.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}
