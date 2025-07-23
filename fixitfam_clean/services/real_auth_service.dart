import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealAuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _sessionKey = 'user_session';

  // Singleton pattern
  static final RealAuthService _instance = RealAuthService._internal();
  factory RealAuthService() => _instance;
  RealAuthService._internal();
  static RealAuthService get instance => _instance;

  // Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Check if user already exists
      if (await _userExists(email)) {
        return {
          'success': false,
          'message': 'User with this email already exists'
        };
      }

      // Validate input
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address'
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters'
        };
      }

      // Create user data
      final userId = _generateUserId();
      final hashedPassword = _hashPassword(password);
      
      final userData = {
        'id': userId,
        'email': email.toLowerCase().trim(),
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'hashedPassword': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'profilePicture': null,
        'subscription': 'free',
        'surveyCompleted': false,
      };

      // Save user to storage
      await _saveUserData(userData);
      
      print('✅ User registered successfully: $email');
      
      return {
        'success': true,
        'message': 'Account created successfully!',
        'userId': userId,
        'userData': userData
      };
      
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed. Please try again.'
      };
    }
  }

  // Sign in user
  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data
      final userData = await _getUserData(email.toLowerCase().trim());
      
      if (userData == null) {
        return {
          'success': false,
          'message': 'No account found with this email'
        };
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (userData['hashedPassword'] != hashedPassword) {
        return {
          'success': false,
          'message': 'Incorrect password'
        };
      }

      // Check if account is active
      if (userData['isActive'] != true) {
        return {
          'success': false,
          'message': 'Account is deactivated'
        };
      }

      // Create session
      final sessionData = {
        'userId': userData['id'],
        'email': userData['email'],
        'loginTime': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      await prefs.setString(_currentUserKey, jsonEncode(userData));
      await prefs.setString(_sessionKey, jsonEncode(sessionData));
      
      print('✅ User signed in successfully: $email');
      
      return {
        'success': true,
        'message': 'Welcome back!',
        'userData': userData
      };
      
    } catch (e) {
      print('❌ Sign in error: $e');
      return {
        'success': false,
        'message': 'Sign in failed. Please try again.'
      };
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_sessionKey);
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_currentUserKey);
      
      if (userDataString == null) return null;
      
      return jsonDecode(userDataString);
    } catch (e) {
      print('❌ Get current user error: $e');
      return null;
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionString = prefs.getString(_sessionKey);
      
      if (sessionString == null) return false;
      
      final sessionData = jsonDecode(sessionString);
      return sessionData['isActive'] == true;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not signed in'
        };
      }

      // Update user data
      final updatedUser = Map<String, dynamic>.from(currentUser);
      updates.forEach((key, value) {
        if (key != 'id' && key != 'hashedPassword') {
          updatedUser[key] = value;
        }
      });
      
      updatedUser['updatedAt'] = DateTime.now().toIso8601String();

      // Save updated data
      await _updateUserInStorage(updatedUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser));
      
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'userData': updatedUser
      };
      
    } catch (e) {
      print('❌ Update profile error: $e');
      return {
        'success': false,
        'message': 'Failed to update profile'
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'User not signed in'
        };
      }

      // Verify current password
      final currentHashedPassword = _hashPassword(currentPassword);
      if (currentUser['hashedPassword'] != currentHashedPassword) {
        return {
          'success': false,
          'message': 'Current password is incorrect'
        };
      }

      // Validate new password
      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters'
        };
      }

      // Update password
      final newHashedPassword = _hashPassword(newPassword);
      await updateUserProfile(updates: {
        'hashedPassword': newHashedPassword,
        'passwordChangedAt': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Password changed successfully'
      };
      
    } catch (e) {
      print('❌ Change password error: $e');
      return {
        'success': false,
        'message': 'Failed to change password'
      };
    }
  }

  // Helper methods
  static Future<bool> _userExists(String email) async {
    final userData = await _getUserData(email.toLowerCase().trim());
    return userData != null;
  }

  static Future<Map<String, dynamic>?> _getUserData(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString(_usersKey);
      
      if (usersString == null) return null;
      
      final users = jsonDecode(usersString) as List;
      
      for (var user in users) {
        if (user['email'] == email) {
          return Map<String, dynamic>.from(user);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Get user data error: $e');
      return null;
    }
  }

  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString(_usersKey);
      
      List users = [];
      if (usersString != null) {
        users = jsonDecode(usersString);
      }
      
      users.add(userData);
      await prefs.setString(_usersKey, jsonEncode(users));
    } catch (e) {
      print('❌ Save user data error: $e');
    }
  }

  static Future<void> _updateUserInStorage(Map<String, dynamic> updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString(_usersKey);
      
      if (usersString == null) return;
      
      List users = jsonDecode(usersString);
      
      for (int i = 0; i < users.length; i++) {
        if (users[i]['id'] == updatedUser['id']) {
          users[i] = updatedUser;
          break;
        }
      }
      
      await prefs.setString(_usersKey, jsonEncode(users));
    } catch (e) {
      print('❌ Update user in storage error: $e');
    }
  }

  static String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 - 1000) * (DateTime.now().microsecond / 1000000)).round()}';
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'fixitfam_salt_2025');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Development/testing methods
  static Future<void> clearAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_currentUserKey);
      await prefs.remove(_sessionKey);
      print('🧹 All user data cleared');
    } catch (e) {
      print('❌ Clear users error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersString = prefs.getString(_usersKey);
      
      if (usersString == null) return [];
      
      final users = jsonDecode(usersString) as List;
      return users.map((user) => Map<String, dynamic>.from(user)).toList();
    } catch (e) {
      print('❌ Get all users error: $e');
      return [];
    }
  }
}
