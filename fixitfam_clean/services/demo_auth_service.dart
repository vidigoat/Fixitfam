import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class DemoAuthService {
  static const String _userKey = 'demo_user';
  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;
  
  // Auth state changes stream
  Stream<UserModel?> get authStateChanges async* {
    await _loadCurrentUser();
    yield _currentUser;
  }

  // Load current user from storage
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = UserModel.fromMap(userData);
      }
    } catch (e) {
      print('Error loading user: $e');
      _currentUser = null;
    }
  }

  // Save current user to storage
  Future<void> _saveCurrentUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
      _currentUser = user;
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // Sign up with email and password
  Future<UserModel?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final user = UserModel(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        createdAt: DateTime.now(),
        isPremium: false,
        subscriptionType: 'free',
      );
      
      await _saveCurrentUser(user);
      return user;
    } catch (e) {
      print('Demo sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = UserModel(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        createdAt: DateTime.now(),
        isPremium: true, // Demo user gets premium access
        subscriptionType: 'premium_annual',
      );
      
      await _saveCurrentUser(user);
      return user;
    } catch (e) {
      print('Demo sign in error: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final user = UserModel(
        uid: 'demo_google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'demo@gmail.com',
        displayName: 'Demo User',
        photoURL: 'https://via.placeholder.com/150',
        createdAt: DateTime.now(),
        isPremium: true, // Demo Google user gets premium
        subscriptionType: 'premium_annual',
      );
      
      await _saveCurrentUser(user);
      return user;
    } catch (e) {
      print('Demo Google sign in error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      _currentUser = null;
    } catch (e) {
      print('Demo sign out error: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    // Demo - just return success
    print('Demo password reset email sent to: $email');
    await Future.delayed(const Duration(seconds: 1));
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_currentUser != null) {
      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        createdAt: _currentUser!.createdAt,
        isPremium: _currentUser!.isPremium,
        subscriptionType: _currentUser!.subscriptionType,
        familyName: _currentUser!.familyName,
      );
      
      await _saveCurrentUser(updatedUser);
    }
  }
}
