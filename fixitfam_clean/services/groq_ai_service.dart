import 'dart:convert';
import 'package:http/http.dart' as http;
import 'adaptive_ai_service.dart';

class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _apiKey = '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';
  
  // Family-specific AI personality and safety
  static const String _systemPrompt = '''
You are FamBot, a helpful and intelligent family assistant AI. You help families with:

🏠 Family Management:
- Scheduling and calendar organization
- Task planning and reminders
- Household management tips

💰 Financial Planning:
- Budget tracking and savings advice
- Expense management
- Family financial planning

👨‍👩‍👧‍👦 Parenting & Family Life:
- Parenting tips and advice
- Child development guidance
- Family activity suggestions
- Educational support

🍽️ Daily Life:
- Meal planning and recipes
- Shopping lists and organization
- Health and wellness tips

✈️ Travel & Entertainment:
- Trip planning assistance
- Family-friendly activity recommendations
- Vacation budgeting

SAFETY GUIDELINES:
- Always prioritize family safety and well-being
- Provide age-appropriate advice
- Never ask for or store personal financial information
- Encourage family communication and bonding
- Be helpful, friendly, and supportive

Keep responses concise, practical, and family-focused. Use emojis appropriately to make conversations engaging.
''';

  Future<String> sendMessage(String userMessage, {
    List<Map<String, String>>? conversationHistory,
    String? familyContext,
  }) async {
    try {
      // Build conversation history
      List<Map<String, dynamic>> messages = [
        {'role': 'system', 'content': _systemPrompt}
      ];
      
      // Add family context if available
      if (familyContext != null && familyContext.isNotEmpty) {
        messages.add({
          'role': 'system', 
          'content': 'Family Context: $familyContext'
        });
      }
      
      // Add conversation history
      if (conversationHistory != null) {
        for (var msg in conversationHistory) {
          messages.add({
            'role': msg['role']!,
            'content': msg['content']!,
          });
        }
      }
      
      // Add current user message
      messages.add({'role': 'user', 'content': userMessage});
      
      print('🔗 Making request to Groq API...');
      print('📝 Message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        },
        body: json.encode({
          'model': 'llama3-8b-8192', // Fast Groq model
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
          'top_p': 1,
          'stream': false,
        }),
      );
      
      print('📡 Groq API Response Status: ${response.statusCode}');
      print('📊 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📄 Full Response: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'];
          
          print('✅ Groq AI Success: ${aiResponse.length} characters');
          print('🤖 AI Response Preview: ${aiResponse.substring(0, aiResponse.length > 100 ? 100 : aiResponse.length)}...');
          
          // Basic content filtering for family safety
          if (_containsInappropriateContent(aiResponse)) {
            return '🛡️ I\'m designed to keep our family conversations safe and positive. Let me help you with something else!';
          }
          
          return aiResponse;
        } else {
          print('⚠️ No choices in response');
          return _getFallbackResponse(userMessage);
        }
      } else {
        print('❌ Groq API Error: ${response.statusCode}');
        print('📄 Error Body: ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('❌ Network/Parse Error: $e');
      print('🔧 Falling back to local response');
      return _getFallbackResponse(userMessage);
    }
  }
  
  bool _containsInappropriateContent(String text) {
    final inappropriateWords = [
      'password', 'ssn', 'social security', 'credit card', 'bank account',
      'unsafe', 'harmful', 'illegal'
    ];
    
    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }
  
  String _getFallbackResponse(String userMessage) {
    // Smart fallback responses based on message content
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('budget') || lowerMessage.contains('money')) {
      return '💰 For budgeting help, I recommend:\n\n• Track your family expenses weekly\n• Set clear savings goals\n• Use the 50/30/20 rule (needs/wants/savings)\n• Involve the whole family in financial planning\n\nWould you like specific budgeting tips for families?';
    }
    
    if (lowerMessage.contains('meal') || lowerMessage.contains('food') || lowerMessage.contains('cook')) {
      return '🍽️ Here are some family meal planning tips:\n\n• Plan weekly menus together\n• Prep ingredients on weekends\n• Involve kids in age-appropriate cooking\n• Try new recipes monthly\n• Keep healthy snacks available\n\nWould you like family-friendly recipe suggestions?';
    }
    
    if (lowerMessage.contains('kid') || lowerMessage.contains('child') || lowerMessage.contains('parent')) {
      return '👨‍👩‍👧‍👦 Parenting is a wonderful journey! Here are some tips:\n\n• Maintain consistent routines\n• Encourage open communication\n• Celebrate small achievements\n• Balance structure with flexibility\n• Make time for family bonding\n\nWhat specific parenting challenge can I help you with?';
    }
    
    if (lowerMessage.contains('travel') || lowerMessage.contains('trip') || lowerMessage.contains('vacation')) {
      return '✈️ Family travel planning tips:\n\n• Create a travel budget early\n• Pack entertainment for kids\n• Research family-friendly destinations\n• Book accommodations in advance\n• Plan for flexibility in your itinerary\n\nWhere are you thinking of traveling with your family?';
    }
    
    return '🤖 I\'m here to help your family with organization, budgeting, parenting, meal planning, and more!\n\nSome things I can assist with:\n• Family schedules and tasks\n• Budget planning and saving tips\n• Parenting advice and activities\n• Meal planning and recipes\n• Travel and vacation planning\n\nWhat would you like help with today?';
  }
  
  // Enhanced adaptive messaging using survey data
  Future<String> sendAdaptiveMessage(String userMessage, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // Get personalized family context from survey data
      final familyContext = await AdaptiveAIService.getCachedFamilyContext();
      
      print('🧠 Using adaptive AI context for personalized response');
      
      return await sendMessage(
        userMessage, 
        conversationHistory: conversationHistory,
        familyContext: familyContext,
      );
    } catch (e) {
      print('❌ Error in adaptive messaging, falling back to standard: $e');
      // Fallback to standard messaging if adaptive fails
      return await sendMessage(userMessage, conversationHistory: conversationHistory);
    }
  }

  // Get personalized greeting based on family context
  Future<String> getPersonalizedGreeting() async {
    return await AdaptiveAIService.getPersonalizedGreeting();
  }

  // Quick family-specific suggestions
  Future<String> getQuickSuggestions() async {
    try {
      final familyContext = await AdaptiveAIService.getCachedFamilyContext();
      
      String prompt = '''
Based on my family profile, give me 3 quick, actionable suggestions for today. 
Keep them practical and relevant to my family's needs. 
Format as a simple list with emojis.
''';
      
      return await sendMessage(prompt, familyContext: familyContext);
    } catch (e) {
      return '''
Here are some general family suggestions for today:
📅 Review your family calendar for upcoming events
💡 Plan tomorrow's meals based on your preferences  
🏃‍♀️ Schedule some family activity time
''';
    }
  }

  // Get personalized family tips based on family profile
  Future<String> getFamilyTips(Map<String, dynamic> familyProfile) async {
    final familySize = familyProfile['memberCount'] ?? 2;
    final hasKids = familyProfile['members']?.any((member) => 
      member['age'] != null && int.tryParse(member['age'].toString()) != null && 
      int.parse(member['age'].toString()) < 18
    ) ?? false;
    
    String prompt = '''
Based on this family profile, provide 3 personalized tips:
- Family size: $familySize members
- Has children: $hasKids
- Preferences: ${familyProfile['dietaryPreferences'] ?? 'Not specified'}

Give practical, actionable tips for this family.
''';
    
    return await sendMessage(prompt, familyContext: json.encode(familyProfile));
  }
}
