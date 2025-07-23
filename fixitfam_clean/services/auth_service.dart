import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'preferences_service.dart';

class AuthService {
  // Demo credentials for hackathon
  static const String demoEmail = 'demo@fixitfam.com';
  static const String demoPassword = 'demo123';
  
  // Simulate auth state changes
  Stream<UserModel?> get authStateChanges async* {
    // Check if user is logged in
    final user = await getCurrentUser();
    yield user;
  }

  // Get current user from local storage
  Future<UserModel?> getCurrentUser() async {
    try {
      final isLoggedIn = await PreferencesService.getBoolSafely('is_logged_in');
      
      if (!isLoggedIn) return null;
      
      final userDataString = await PreferencesService.getStringSafely('user_data');
      if (userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        // Ensure userData is a Map<String, dynamic>
        if (userData is Map<String, dynamic>) {
          return UserModel.fromMap(userData);
        }
      }
    } catch (e) {
      print('Error getting current user: $e');
      // Clear corrupted data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');
        await prefs.remove('is_logged_in');
      } catch (_) {}
    }
    return null;
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail(
    String email, 
    String password, 
    String displayName, 
    {String? familyName}
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // For demo purposes, accept any email/password with minimum requirements
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }
      
      if (displayName.trim().isEmpty) {
        throw Exception('Please enter your full name');
      }
      
      // Create user model
      final user = UserModel(
        uid: _generateUserId(),
        email: email.toLowerCase().trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        isPremium: false,
        subscriptionType: 'free',
        familyName: familyName?.trim(),
      );
      
      // Save user data
      await _saveUserLocally(user);
      
      return user;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      email = email.toLowerCase().trim();
      
      // Demo account
      if (email == demoEmail && password == demoPassword) {
        final user = UserModel(
          uid: 'demo_user_123',
          email: demoEmail,
          displayName: 'Demo Family',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          isPremium: true, // Give demo user premium access
          subscriptionType: 'premium_yearly',
          familyName: 'Demo Family',
        );
        
        await _saveUserLocally(user);
        return user;
      }
      
      // Check if user exists in local storage (for previously signed up users)
      final prefs = await SharedPreferences.getInstance();
      final registeredUsersString = prefs.getString('registered_users') ?? '[]';
      final registeredUsers = List<Map<String, dynamic>>.from(
        jsonDecode(registeredUsersString)
      );
      
      // Find user by email
      final userData = registeredUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => <String, dynamic>{},
      );
      
      if (userData.isEmpty) {
        throw Exception('No account found with this email. Please sign up first.');
      }
      
      // In a real app, you'd verify the password hash
      // For demo, we'll just check if it's not empty
      if (password.isEmpty) {
        throw Exception('Please enter your password');
      }
      
      // Ensure userData is properly formatted before creating UserModel
      if (userData is Map<String, dynamic>) {
        final user = UserModel.fromMap(userData);
        await _saveUserLocally(user);
        return user;
      } else {
        throw Exception('Invalid user data format');
      }
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign in with Google (demo version)
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Simulate Google sign in delay
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Create a demo Google user
      final user = UserModel(
        uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'googleuser@gmail.com',
        displayName: 'Google User',
        photoURL: 'https://via.placeholder.com/150',
        createdAt: DateTime.now(),
        isPremium: false,
        subscriptionType: 'free',
      );
      
      await _saveUserLocally(user);
      return user;
    } catch (e) {
      print('Google sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await PreferencesService.setBoolSafely('is_logged_in', false);
      await PreferencesService.removeSafely('user_data');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password (demo version)
  Future<void> resetPassword(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }
      
      // In a real app, this would send an actual email
      // For demo, we just simulate success
      print('Password reset email sent to: $email');
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // Update user premium status
  Future<void> updatePremiumStatus(bool isPremium, String subscriptionType) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          isPremium: isPremium,
          subscriptionType: subscriptionType,
        );
        await _saveUserLocally(updatedUser);
      }
    } catch (e) {
      print('Error updating premium status: $e');
      rethrow;
    }
  }

  // Clear all auth data (useful for debugging)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('is_logged_in');
      await prefs.remove('registered_users');
      await prefs.remove('hasSignedUp');
      await prefs.remove('hasAddedMembers');
      await prefs.remove('family_survey_completed');
      await prefs.remove('hasSelectedPlan');
      print('Auth data cleared successfully');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  // Private helper methods
  Future<void> _saveUserLocally(UserModel user) async {
    try {
      // Save current user
      await PreferencesService.setStringSafely('user_data', jsonEncode(user.toMap()));
      await PreferencesService.setBoolSafely('is_logged_in', true);
      
      // Save to registered users list (for future sign ins)
      final prefs = await SharedPreferences.getInstance();
      final registeredUsersString = prefs.getString('registered_users') ?? '[]';
      final registeredUsers = List<Map<String, dynamic>>.from(
        jsonDecode(registeredUsersString)
      );
      
      // Remove existing user with same email and add updated one
      registeredUsers.removeWhere((u) => u['email'] == user.email);
      registeredUsers.add(user.toMap());
      
      await prefs.setString('registered_users', jsonEncode(registeredUsers));
    } catch (e) {
      print('Error saving user locally: $e');
      rethrow;
    }
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9000 * (DateTime.now().millisecond / 1000))).round()}';
  }

  // Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final registeredUsersString = prefs.getString('registered_users') ?? '[]';
      final registeredUsers = List<Map<String, dynamic>>.from(
        jsonDecode(registeredUsersString)
      );
      
      return registeredUsers.any((user) => user['email'] == email.toLowerCase().trim());
    } catch (e) {
      return false;
    }
  }
}