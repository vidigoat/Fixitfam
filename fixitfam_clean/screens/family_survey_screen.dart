import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'plan_selection_screen.dart';

class FamilySurveyScreen extends StatefulWidget {
  const FamilySurveyScreen({super.key});

  @override
  _FamilySurveyScreenState createState() => _FamilySurveyScreenState();
}

class _FamilySurveyScreenState extends State<FamilySurveyScreen> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Survey Data
  Map<String, dynamic> surveyData = {
    'familyName': '',
    'memberCount': 1,
    'members': [],
    'dietaryType': '',
    'preferredCuisines': [],
    'favoriteDishes': '',
    'gpsTracking': '',
    'locationSharing': '',
    'kidsGrade': '',
    'quizTopics': [],
    'budgetingStyle': '',
    'expenseTracking': '',
    'hasAllergies': '',
    'medicineReminders': '',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSurvey();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('surveyData', json.encode(surveyData));
    await prefs.setBool('hasCompletedSurvey', true);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PlanSelectionScreen()),
    );
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
              Color(0xFF16213E),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildFamilyBasicsPage(),
                      _buildFoodPreferencesPage(),
                      _buildLocationPage(),
                      _buildKidsLearningPage(),
                      _buildBudgetingPage(),
                      _buildHealthPage(),
                    ],
                  ),
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
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Icon(
            Icons.family_restroom,
            size: 48,
            color: Color(0xFF6C63FF),
          ),
          SizedBox(height: 12),
          Text(
            'Family Setup Survey',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tell us about your family to personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${((_currentPage + 1) / _totalPages * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyBasicsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('👨‍👩‍👧‍👦 Tell us about your family'),
          const SizedBox(height: 24),
          _buildInputField(
            'Family Name',
            'Enter your family name',
            onChanged: (value) => surveyData['familyName'] = value,
          ),
          const SizedBox(height: 20),
          _buildMemberCountSelector(),
          const SizedBox(height: 20),
          _buildMembersList(),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🍽️ Food & Dietary Preferences'),
          const SizedBox(height: 24),
          _buildDietaryTypeSelector(),
          const SizedBox(height: 20),
          _buildCuisineSelector(),
          const SizedBox(height: 20),
          _buildInputField(
            'Favorite Dishes',
            'List your family\'s favorite dishes',
            maxLines: 3,
            onChanged: (value) => surveyData['favoriteDishes'] = value,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📍 Location & GPS Settings'),
          const SizedBox(height: 24),
          _buildToggleOption(
            'Enable GPS Tracking',
            'Track family member locations for safety',
            surveyData['gpsTracking'] == 'enabled',
            (value) => setState(() {
              surveyData['gpsTracking'] = value ? 'enabled' : 'disabled';
            }),
          ),
          const SizedBox(height: 20),
          _buildToggleOption(
            'Location Sharing',
            'Share locations with family members',
            surveyData['locationSharing'] == 'enabled',
            (value) => setState(() {
              surveyData['locationSharing'] = value ? 'enabled' : 'disabled';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKidsLearningPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🎓 Kids Learning & Education'),
          const SizedBox(height: 24),
          _buildGradeSelector(),
          const SizedBox(height: 20),
          _buildQuizTopicsSelector(),
        ],
      ),
    );
  }

  Widget _buildBudgetingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('💰 Budgeting & Expenses'),
          const SizedBox(height: 24),
          _buildBudgetingStyleSelector(),
          const SizedBox(height: 20),
          _buildToggleOption(
            'Track Expenses',
            'Monitor family spending and budgets',
            surveyData['expenseTracking'] == 'enabled',
            (value) => setState(() {
              surveyData['expenseTracking'] = value ? 'enabled' : 'disabled';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🏥 Health & Wellness'),
          const SizedBox(height: 24),
          _buildToggleOption(
            'Family has Allergies',
            'Track allergies and dietary restrictions',
            surveyData['hasAllergies'] == 'yes',
            (value) => setState(() {
              surveyData['hasAllergies'] = value ? 'yes' : 'no';
            }),
          ),
          const SizedBox(height: 20),
          _buildToggleOption(
            'Medicine Reminders',
            'Set up medication reminders',
            surveyData['medicineReminders'] == 'enabled',
            (value) => setState(() {
              surveyData['medicineReminders'] = value ? 'enabled' : 'disabled';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFF6C63FF) : Colors.white24,
          width: 2,
        ),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of family members',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [1, 2, 3, 4, 5, 6].map((count) {
            bool isSelected = surveyData['memberCount'] == count;
            return GestureDetector(
              onTap: () {
                setState(() {
                  surveyData['memberCount'] = count;
                  // Adjust members list
                  List<String> members = List<String>.filled(count, '');
                  surveyData['members'] = members;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    int memberCount = surveyData['memberCount'] ?? 1;
    List<String> members = List<String>.from(surveyData['members'] ?? []);
    
    if (members.length != memberCount) {
      members = List<String>.filled(memberCount, '');
      surveyData['members'] = members;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family member names',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(memberCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: members[index],
              onChanged: (value) {
                members[index] = value;
                surveyData['members'] = members;
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Member ${index + 1} name',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDietaryTypeSelector() {
    List<String> dietTypes = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Mixed'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Preference',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: dietTypes.map((type) {
            bool isSelected = surveyData['dietaryType'] == type;
            return GestureDetector(
              onTap: () => setState(() => surveyData['dietaryType'] = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCuisineSelector() {
    List<String> cuisines = ['Indian', 'Chinese', 'Italian', 'Mexican', 'Thai', 'Continental'];
    List<String> selectedCuisines = List<String>.from(surveyData['preferredCuisines'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Cuisines (Select multiple)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cuisines.map((cuisine) {
            bool isSelected = selectedCuisines.contains(cuisine);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCuisines.remove(cuisine);
                  } else {
                    selectedCuisines.add(cuisine);
                  }
                  surveyData['preferredCuisines'] = selectedCuisines;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  cuisine,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGradeSelector() {
    List<String> grades = ['Pre-K', 'K-2', '3-5', '6-8', '9-12', 'College', 'Adult'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kids Grade Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: grades.map((grade) {
            bool isSelected = surveyData['kidsGrade'] == grade;
            return GestureDetector(
              onTap: () => setState(() => surveyData['kidsGrade'] = grade),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuizTopicsSelector() {
    List<String> topics = ['Math', 'Science', 'History', 'Geography', 'Literature', 'General Knowledge'];
    List<String> selectedTopics = List<String>.from(surveyData['quizTopics'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Topics of Interest',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: topics.map((topic) {
            bool isSelected = selectedTopics.contains(topic);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTopics.remove(topic);
                  } else {
                    selectedTopics.add(topic);
                  }
                  surveyData['quizTopics'] = selectedTopics;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetingStyleSelector() {
    List<String> styles = ['Simple Tracking', 'Category-based', 'Envelope Method', 'Zero-based'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budgeting Style',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: styles.map((style) {
            bool isSelected = surveyData['budgetingStyle'] == style;
            return GestureDetector(
              onTap: () => setState(() => surveyData['budgetingStyle'] = style),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  style,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _totalPages - 1 ? 'Complete Survey' : 'Next',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
