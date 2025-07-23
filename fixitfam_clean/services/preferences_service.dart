import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static Future<bool> getBoolSafely(String key, {bool defaultValue = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.get(key);
      
      // Handle different types that might be stored
      if (value is bool) {
        return value;
      } else if (value is String) {
        return value.toLowerCase() == 'true';
      } else if (value is int) {
        return value != 0;
      }
      
      return defaultValue;
    } catch (e) {
      print('Error getting bool for key $key: $e');
      return defaultValue;
    }
  }

  static Future<void> setBoolSafely(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('Error setting bool for key $key: $e');
    }
  }

  static Future<String> getStringSafely(String key, {String defaultValue = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key) ?? defaultValue;
    } catch (e) {
      print('Error getting string for key $key: $e');
      return defaultValue;
    }
  }

  static Future<void> setStringSafely(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      print('Error setting string for key $key: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All preferences cleared');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }

  static Future<void> removeSafely(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Error removing key $key: $e');
    }
  }

  // Survey Data Storage for Adaptive AI
  static Future<void> storeSurveyData(Map<String, dynamic> surveyData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store family basic info
      await prefs.setString('family_name', surveyData['familyName'] ?? '');
      await prefs.setString('family_city', surveyData['familyCity'] ?? '');
      await prefs.setInt('family_size', surveyData['familySize'] ?? 2);
      await prefs.setString('primary_language', surveyData['primaryLanguage'] ?? 'English');
      
      // Store dietary preferences
      await prefs.setStringList('dietary_preferences', 
          (surveyData['dietaryPreferences'] as List<String>?) ?? []);
      await prefs.setStringList('allergies', 
          (surveyData['allergies'] as List<String>?) ?? []);
      
      // Store family goals and priorities
      await prefs.setStringList('family_goals', 
          (surveyData['familyGoals'] as List<String>?) ?? []);
      await prefs.setStringList('priority_areas', 
          (surveyData['priorityAreas'] as List<String>?) ?? []);
      
      // Store lifestyle preferences
      await prefs.setString('budget_range', surveyData['budgetRange'] ?? 'moderate');
      await prefs.setString('activity_level', surveyData['activityLevel'] ?? 'moderate');
      await prefs.setString('communication_style', surveyData['communicationStyle'] ?? 'balanced');
      
      print('Survey data stored successfully for adaptive AI');
    } catch (e) {
      print('Error storing survey data: $e');
    }
  }

  static Future<Map<String, dynamic>> getSurveyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'familyName': prefs.getString('family_name') ?? '',
        'familyCity': prefs.getString('family_city') ?? '',
        'familySize': prefs.getInt('family_size') ?? 2,
        'primaryLanguage': prefs.getString('primary_language') ?? 'English',
        'dietaryPreferences': prefs.getStringList('dietary_preferences') ?? [],
        'allergies': prefs.getStringList('allergies') ?? [],
        'familyGoals': prefs.getStringList('family_goals') ?? [],
        'priorityAreas': prefs.getStringList('priority_areas') ?? [],
        'budgetRange': prefs.getString('budget_range') ?? 'moderate',
        'activityLevel': prefs.getString('activity_level') ?? 'moderate',
        'communicationStyle': prefs.getString('communication_style') ?? 'balanced',
      };
    } catch (e) {
      print('Error retrieving survey data: $e');
      return {};
    }
  }
}
