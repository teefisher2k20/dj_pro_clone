import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
// For debug print if needed

class FirebaseService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isMockMode = false;

  // Mock Stream
  final StreamController<Object?> _mockUserStream =
      StreamController<Object?>.broadcast();

  FirebaseService() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
      } else {
        _isMockMode = true;
        print("[FirebaseService] Warning: No Firebase App. Mock Mode Enabled.");
      }
    } catch (e) {
      _isMockMode = true;
      print("[FirebaseService] Error initializing: $e. Mock Mode Enabled.");
    }
  }

  bool get isMockMode => _isMockMode;

  // Sign Up
  Future<UserModel> signUpWithEmail(String email, String password) async {
    if (_isMockMode) {
      // Mock Data
      await Future.delayed(const Duration(milliseconds: 500));
      final user = UserModel(
        id: 'mock_user_id',
        email: email,
        createdAt: DateTime.now(),
      );
      _mockUserStream.add("MOCK_SESSION");
      return user;
    }

    try {
      UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: result.user!.uid,
        email: email,
        createdAt: DateTime.now(),
      );

      // Create user document in Firestore on signup
      await _firestore!.collection('users').doc(user.id).set(user.toJson());

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign In
  Future<UserModel> signInWithEmail(String email, String password) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final user = UserModel(
        id: 'mock_user_id',
        email: email,
        createdAt: DateTime.now(),
      );
      _mockUserStream.add("MOCK_SESSION");
      return user;
    }

    try {
      UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final snapshot = await _firestore!
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data()!);
      } else {
        // Create user doc if for some reason it doesn't exist (e.g., imported users)
        final user = UserModel(
          id: result.user!.uid,
          email: email,
          createdAt: DateTime.now(),
        );
        await _firestore!.collection('users').doc(user.id).set(user.toJson());
        return user;
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    if (_isMockMode) {
      _mockUserStream.add(null);
      return;
    }
    await _auth!.signOut();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    if (_isMockMode) return;
    await _auth!.sendPasswordResetEmail(email: email);
  }

  // Get current user stream
  // Returns Object? to decouple from firebase_auth.User
  Stream<Object?> get user {
    if (_isMockMode) return _mockUserStream.stream;
    return _auth!.authStateChanges();
  }

  // Get current user model
  Future<UserModel?> getCurrentUser() async {
    if (_isMockMode) {
      return UserModel(
        id: 'mock_user_id',
        email: 'guest@example.com',
        createdAt: DateTime.now(),
      );
    }

    if (_auth == null || _auth!.currentUser == null) return null;

    final user = _auth!.currentUser!;
    // Check if _firestore is available?
    if (_firestore == null) return null;

    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data()!);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }
}
