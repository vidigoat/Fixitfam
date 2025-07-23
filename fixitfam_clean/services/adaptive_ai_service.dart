import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdaptiveAIService {
  static const String _familyContextKey = 'family_context';
  static const String _surveyDataKey = 'survey_data';

  // Generate personalized AI context based on survey responses
  static Future<String> generateFamilyContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surveyData = prefs.getString(_surveyDataKey);
      
      if (surveyData == null) {
        return _getDefaultContext();
      }

      final Map<String, dynamic> data = jsonDecode(surveyData);
      return _buildPersonalizedContext(data);
    } catch (e) {
      print('Error generating family context: $e');
      return _getDefaultContext();
    }
  }

  // Save survey responses for AI personalization
  static Future<void> saveSurveyData(Map<String, dynamic> surveyResponses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_surveyDataKey, jsonEncode(surveyResponses));
      
      // Generate and cache the family context
      final context = _buildPersonalizedContext(surveyResponses);
      await prefs.setString(_familyContextKey, context);
      
      print('Survey data saved and family context generated');
    } catch (e) {
      print('Error saving survey data: $e');
    }
  }

  // Get cached family context
  static Future<String> getCachedFamilyContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_familyContextKey) ?? _getDefaultContext();
    } catch (e) {
      return _getDefaultContext();
    }
  }

  // Build personalized context from survey data
  static String _buildPersonalizedContext(Map<String, dynamic> data) {
    final StringBuffer context = StringBuffer();
    
    context.writeln('FAMILY PROFILE & PREFERENCES:');
    
    // Basic family info
    if (data['familySize'] != null) {
      context.writeln('👨‍👩‍👧‍👦 Family Size: ${data['familySize']} members');
    }
    
    if (data['hasChildren'] == true) {
      context.writeln('👶 Has children in the household');
      if (data['childrenAges'] != null) {
        context.writeln('📅 Children ages: ${data['childrenAges']}');
      }
    }

    // Dietary preferences
    if (data['dietaryRestrictions'] != null && data['dietaryRestrictions'].isNotEmpty) {
      context.writeln('🍽️ Dietary considerations: ${(data['dietaryRestrictions'] as List).join(', ')}');
    }

    // Lifestyle preferences
    if (data['lifestyle'] != null) {
      context.writeln('🏃‍♀️ Lifestyle: ${data['lifestyle']}');
    }

    // Budget consciousness
    if (data['budgetPriority'] != null) {
      context.writeln('💰 Budget priority: ${data['budgetPriority']}');
    }

    // Health & wellness focus
    if (data['healthFocus'] == true) {
      context.writeln('🏥 Health & wellness is a priority');
    }

    // Technology comfort
    if (data['techComfort'] != null) {
      context.writeln('📱 Technology comfort level: ${data['techComfort']}');
    }

    // Interests and hobbies
    if (data['interests'] != null && data['interests'].isNotEmpty) {
      context.writeln('🎯 Family interests: ${(data['interests'] as List).join(', ')}');
    }

    // Location/timezone (if provided)
    if (data['location'] != null) {
      context.writeln('📍 Location: ${data['location']}');
    }

    context.writeln('\nAI BEHAVIOR GUIDELINES:');
    context.writeln('- Tailor all responses to this family\'s specific needs and preferences');
    context.writeln('- Consider dietary restrictions when suggesting meals or recipes');
    context.writeln('- Adjust complexity based on technology comfort level');
    context.writeln('- Factor in budget consciousness for financial advice');
    context.writeln('- Consider children\'s ages for activity and safety recommendations');
    context.writeln('- Be mindful of lifestyle preferences in suggestions');
    
    return context.toString();
  }

  // Default context when no survey data available
  static String _getDefaultContext() {
    return '''
FAMILY PROFILE & PREFERENCES:
👨‍👩‍👧‍👦 General family household
🍽️ No specific dietary restrictions known
💰 Budget-conscious approach
📱 Moderate technology comfort level

AI BEHAVIOR GUIDELINES:
- Provide general family-friendly advice
- Keep suggestions budget-friendly
- Use clear, simple language
- Focus on practical solutions
- Always prioritize safety and well-being
''';
  }

  // Get personalized greeting based on time and family context
  static Future<String> getPersonalizedGreeting() async {
    final context = await getCachedFamilyContext();
    final hour = DateTime.now().hour;
    
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    // Check if we have family data for personalization
    if (context.contains('Family Size:')) {
      return '$timeGreeting! Ready to help your family today? 👨‍👩‍👧‍👦';
    } else {
      return '$timeGreeting! I\'m FamBot, your family assistant. How can I help? 😊';
    }
  }

  // Clear all stored data (for testing/reset)
  static Future<void> clearFamilyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_familyContextKey);
      await prefs.remove(_surveyDataKey);
      print('Family data cleared');
    } catch (e) {
      print('Error clearing family data: $e');
    }
  }
}
