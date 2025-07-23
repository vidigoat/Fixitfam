import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/plan_selection_screen.dart';
import 'services/preferences_service.dart';
import 'services/adaptive_ai_service.dart';
import 'services/real_auth_service.dart';

class FamilySurveyScreen extends StatefulWidget {
  const FamilySurveyScreen({super.key});

  @override
  _FamilySurveyScreenState createState() => _FamilySurveyScreenState();
}

class _FamilySurveyScreenState extends State<FamilySurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6; // Back to original for now
  
  // Enhanced Survey Data with your questions
  Map<String, dynamic> surveyData = {
    // Basic Information
    'familyName': '',
    'memberCount': 1,
    'members': [],
    
    // Food & Dietary
    'dietaryType': '', // vegetarian, non-vegetarian, etc.
    'dietaryRestrictions': '',
    'preferredCuisines': [],
    'favoriteDishes': '',
    
    // GPS & Location
    'gpsTracking': '',
    'locationSharing': '',
    'homeAddress': '',
    
    // Learning & KidZone
    'kidsGrade': '',
    'quizTopics': [],
    'quizDifficulty': '',
    'kidRewards': [],
    
    // Budgeting
    'expenseTracking': '',
    'budgetingStyle': '',
    'budgetView': '',
    'upiUsage': '',
    
    // Health & Wellness
    'hasAllergies': '',
    'allergiesList': '',
    'medicineReminders': '',
    'wellnessTracking': [],
    
    // Document Storage
    'documentsToStore': [],
    'vaultAccess': '',
    
    // Daily Tasks
    'taskAssignment': '',
    'taskTypes': [],
    
    // Customization
    'appTheme': 'dark',
    'dailyTips': '',
    'featureRequests': '',
    
    // Final
    'contactForTesting': '',
    'contactInfo': '',
    
    // Additional Smart Questions
    'workSchedule': '',
    'familyGoals': [],
    'communicationStyle': '',
    'techComfort': '',
    'emergencyContacts': [],
    'specialOccasions': [],
    'languagePreference': 'English',
  };

  // Controllers for all text inputs
  final Map<String, TextEditingController> _controllers = {
    'familyName': TextEditingController(),
    'dietaryRestrictions': TextEditingController(),
    'favoriteDishes': TextEditingController(),
    'homeAddress': TextEditingController(),
    'kidsGrade': TextEditingController(),
    'allergiesList': TextEditingController(),
    'featureRequests': TextEditingController(),
    'contactInfo': TextEditingController(),
  };

  List<Map<String, dynamic>> familyMembers = [];

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildFamilyInfoPage(),
                    _buildPreferencesPage(),
                    _buildKidsPage(),
                    _buildHealthWellnessPage(),
                    _buildCustomizationPage(),
                    _buildFinalPage(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Family Preferences Survey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us personalize FixitFam for your family',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalPages, (index) {
              return Container(
                width: (MediaQuery.of(context).size.width - 48 - (_totalPages - 1) * 8) / _totalPages,
                height: 4,
                decoration: BoxDecoration(
                  color: index <= _currentPage ? const Color(0xFF0EA5E9) : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentPage + 1} of $_totalPages',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('👨‍👩‍👧 Family Information'),
          const SizedBox(height: 24),
          
          _buildInputField(
            'Family Name',
            _controllers['familyName']!,
            'Enter your family name',
            onChanged: (value) => surveyData['familyName'] = value,
          ),
          
          const SizedBox(height: 20),
          
          _buildSliderField(
            'Number of Family Members',
            surveyData['memberCount']?.toDouble() ?? 1.0,
            1.0,
            10.0,
            (value) {
              setState(() {
                surveyData['memberCount'] = value.round();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Dietary Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Vegan']
                .map((diet) => _buildChip(
                      diet,
                      surveyData['dietaryPreferences']?.contains(diet) ?? false,
                      () => _toggleListItem('dietaryPreferences', diet),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🍽️ Food & Location Preferences'),
          const SizedBox(height: 24),
          
          const Text(
            'Favorite Cuisines',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Indian', 'Italian', 'Chinese', 'Mexican', 'Japanese', 'American', 'Thai', 'South Indian']
                .map((cuisine) => _buildChip(
                      cuisine,
                      surveyData['cuisines']?.contains(cuisine) ?? false,
                      () => _toggleListItem('cuisines', cuisine),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 24),
          
          _buildSwitchTile(
            '🗺️ Enable GPS Family Tracking',
            'For safety and location sharing',
            (surveyData['gpsTracking'] is bool) ? surveyData['gpsTracking'] : false,
            (value) => setState(() => surveyData['gpsTracking'] = value),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🧠 Kids Learning & Fun'),
          const SizedBox(height: 24),
          
          _buildInputField(
            'Kids Grade/Class',
            _controllers['kidsGrade']!,
            'e.g., Grade 5, 10th Standard',
            onChanged: (value) => surveyData['kidsGrade'] = value,
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Favorite Quiz Topics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Math', 'Science', 'GK', 'English', 'Logic Puzzles', 'Coding Basics']
                .map((topic) => _buildChip(
                      topic,
                      surveyData['quizTopics']?.contains(topic) ?? false,
                      () => _toggleListItem('quizTopics', topic),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 24),
          
          _buildSwitchTile(
            '📝 Enable Task Assignment for Kids',
            'Study goals, chores, and fun challenges',
            (surveyData['taskAssignment'] is bool) ? surveyData['taskAssignment'] : false,
            (value) => setState(() => surveyData['taskAssignment'] = value),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthWellnessPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('❤️ Health & Wellness'),
          const SizedBox(height: 24),
          
          const Text(
            'Health Tracking Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Water Intake', 'Sleep', 'Fitness', 'Mood', 'Medicine Reminders']
                .map((health) => _buildChip(
                      health,
                      surveyData['healthTracking']?.contains(health) ?? false,
                      () => _toggleListItem('healthTracking', health),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Budgeting Style',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Weekly', 'Monthly', 'Yearly', 'Full Family View', 'Parents Only']
                .map((budget) => _buildChip(
                      budget,
                      surveyData['budgetingStyle'] == budget,
                      () => setState(() => surveyData['budgetingStyle'] = budget),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🎨 Customization'),
          const SizedBox(height: 24),
          
          const Text(
            'App Theme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Light', 'Dark', 'Auto']
                .map((theme) => _buildChip(
                      theme,
                      surveyData['theme'] == theme.toLowerCase(),
                      () => setState(() => surveyData['theme'] = theme.toLowerCase()),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF60A5FA), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'AI Personalization',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Based on your preferences, our AI will:\n• Suggest personalized meal plans\n• Recommend family activities\n• Customize learning content for kids\n• Optimize your family schedule',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('✅ Almost Done!'),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Survey Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your FixitFam experience will be personalized based on your responses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSwitchTile(
            '📧 Contact for Beta Testing',
            'Get early access to new features',
            (surveyData['contactForTesting'] is bool) ? surveyData['contactForTesting'] : false,
            (value) => setState(() => surveyData['contactForTesting'] = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white60),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${value.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0EA5E9),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF0EA5E9),
            overlayColor: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)])
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0EA5E9),
            activeTrackColor: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: Container(
              height: 48,
              margin: EdgeInsets.only(left: _currentPage > 0 ? 8 : 0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _currentPage == _totalPages - 1 ? _completeSurvey : () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? 'Complete Survey' : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleListItem(String key, String item) {
    setState(() {
      if (surveyData[key] == null) {
        surveyData[key] = [];
      }
      List<String> list = List<String>.from(surveyData[key]);
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
      surveyData[key] = list;
    });
  }

  Future<void> _completeSurvey() async {
    // Save survey data to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('family_survey_data', jsonEncode(surveyData));
    await PreferencesService.setBoolSafely('family_survey_completed', true);
    
    // Save survey data for AI personalization
    await AdaptiveAIService.saveSurveyData(surveyData);
    print('✅ Survey data saved for AI personalization');
    
    // Mark the survey step as completed in user profile
    try {
      await RealAuthService.instance.updateUserProfile(
        updates: {'familySurveyCompleted': true}
      );
    } catch (e) {
      print('Error updating user profile with survey completion: $e');
    }
    
    // Navigate to plan selection screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PlanSelectionScreen()),
    );
  }
}
