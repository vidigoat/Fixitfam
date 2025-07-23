import 'package:shared_preferences/shared_preferences.dart';

class AIPersonalizationService {
  Map<String, dynamic> _familyData = {};
  
  Future<void> loadFamilyProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load survey data
    _familyData = {
      'family_size': prefs.getInt('family_size') ?? 4,
      'primary_challenges': prefs.getStringList('primary_challenges') ?? [],
      'parenting_style': prefs.getString('parenting_style') ?? 'balanced',
      'activity_level': prefs.getString('activity_level') ?? 'moderate',
      'tech_comfort': prefs.getString('tech_comfort') ?? 'comfortable',
      'budget_focus': prefs.getString('budget_focus') ?? 'balanced',
      'communication_style': prefs.getString('communication_style') ?? 'open',
      'family_goals': prefs.getStringList('family_goals') ?? [],
      'special_needs': prefs.getStringList('special_needs') ?? [],
      'work_schedule': prefs.getString('work_schedule') ?? 'traditional',
    };
  }
  
  Future<String> getAdaptiveSystemPrompt() async {
    String basePrompt = 'You are FamBot, a helpful AI assistant for family management. ';
    
    // Personalize based on family data
    if (_familyData['family_size'] != null) {
      int size = _familyData['family_size'];
      basePrompt += 'You are helping a family of $size members. ';
    }
    
    if (_familyData['parenting_style'] != null) {
      String style = _familyData['parenting_style'];
      if (style == 'strict') {
        basePrompt += 'Provide structured, rule-based advice that emphasizes discipline and clear boundaries. ';
      } else if (style == 'relaxed') {
        basePrompt += 'Offer flexible, gentle guidance that promotes creativity and independence. ';
      } else {
        basePrompt += 'Give balanced advice that combines structure with flexibility. ';
      }
    }
    
    if (_familyData['primary_challenges'] != null && _familyData['primary_challenges'].isNotEmpty) {
      List<String> challenges = List<String>.from(_familyData['primary_challenges']);
      basePrompt += 'Pay special attention to helping with: ${challenges.join(", ")}. ';
    }
    
    if (_familyData['tech_comfort'] != null) {
      String comfort = _familyData['tech_comfort'];
      if (comfort == 'not_comfortable') {
        basePrompt += 'Explain technical solutions in simple, non-technical terms. ';
      } else if (comfort == 'very_comfortable') {
        basePrompt += 'Feel free to suggest advanced technical solutions and digital tools. ';
      }
    }
    
    basePrompt += 'Be friendly, concise, and practical. Use emojis appropriately. Focus on actionable advice.';
    
    return basePrompt;
  }
  
  Future<String> getContextualResponse(String userMessage) async {
    // This method can be expanded to provide context-aware responses
    // based on the user's message and family profile
    return userMessage;
  }
}
