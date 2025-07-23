import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'sound_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  final Color color;
  final String category;
  final String tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.color,
    required this.category,
    required this.tier,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      points: points,
      color: color,
      category: category,
      tier: tier,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();
  static AchievementService get instance => _instance;

  static const String _achievementsKey = 'user_achievements';
  static const String _pointsKey = 'user_points';
  static const String _streakKey = 'user_streak';

  // Streams
  final StreamController<List<Achievement>> _achievementsController = 
      StreamController<List<Achievement>>.broadcast();
  final StreamController<int> _pointsController = 
      StreamController<int>.broadcast();
  
  Stream<List<Achievement>> get achievementsStream => _achievementsController.stream;
  Stream<int> get pointsStream => _pointsController.stream;
  
  int _totalPoints = 0;
  int get totalPoints => _totalPoints;

  // Achievement definitions
  final List<Map<String, dynamic>> _achievementDefinitions = [
    {
      'id': 'first_login',
      'title': 'Welcome to FixitFam!',
      'description': 'Complete your first login',
      'icon': Icons.login,
      'points': 100,
      'color': const Color(0xFF2196F3),
      'category': 'getting_started',
      'tier': 'bronze',
    },
    {
      'id': 'expense_tracker',
      'title': 'Expense Tracker',
      'description': 'Add your first expense',
      'icon': Icons.attach_money,
      'points': 50,
      'color': const Color(0xFF4CAF50),
      'category': 'finance',
      'tier': 'bronze',
    },
    {
      'id': 'task_master',
      'title': 'Task Master',
      'description': 'Complete 5 tasks',
      'icon': Icons.task_alt,
      'points': 200,
      'color': const Color(0xFFFF9800),
      'category': 'productivity',
      'tier': 'silver',
    },
    {
      'id': 'family_organizer',
      'title': 'Family Organizer',
      'description': 'Use all 5 main features',
      'icon': Icons.family_restroom,
      'points': 500,
      'color': const Color(0xFF9C27B0),
      'category': 'exploration',
      'tier': 'gold',
    },
    {
      'id': 'week_warrior',
      'title': 'Week Warrior',
      'description': 'Login for 7 consecutive days',
      'icon': Icons.calendar_today,
      'points': 300,
      'color': const Color(0xFFE91E63),
      'category': 'consistency',
      'tier': 'silver',
    },
    {
      'id': 'ai_enthusiast',
      'title': 'AI Enthusiast',
      'description': 'Chat with FamBot 10 times',
      'icon': Icons.smart_toy,
      'points': 150,
      'color': const Color(0xFF00BCD4),
      'category': 'ai',
      'tier': 'bronze',
    },
    {
      'id': 'budget_master',
      'title': 'Budget Master',
      'description': 'Stay under budget for a month',
      'icon': Icons.savings,
      'points': 1000,
      'color': const Color(0xFFFF5722),
      'category': 'finance',
      'tier': 'platinum',
    },
  ];

  // Get user points
  Future<int> getUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  // Add points
  Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentPoints = await getUserPoints();
    await prefs.setInt(_pointsKey, currentPoints + points);
    
    // Update streams
    await _updatePointsStream();
  }

  // Get user level based on points
  Future<Map<String, dynamic>> getUserLevel() async {
    final points = await getUserPoints();
    
    if (points >= 5000) {
      return {'level': 10, 'title': 'Family Legend', 'color': const Color(0xFFFFD700)};
    } else if (points >= 3000) {
      return {'level': 9, 'title': 'Master Organizer', 'color': const Color(0xFF9C27B0)};
    } else if (points >= 2000) {
      return {'level': 8, 'title': 'Expert Manager', 'color': const Color(0xFFE91E63)};
    } else if (points >= 1500) {
      return {'level': 7, 'title': 'Advanced User', 'color': const Color(0xFFFF5722)};
    } else if (points >= 1000) {
      return {'level': 6, 'title': 'Skilled Parent', 'color': const Color(0xFF795548)};
    } else if (points >= 700) {
      return {'level': 5, 'title': 'Organized Family', 'color': const Color(0xFF607D8B)};
    } else if (points >= 500) {
      return {'level': 4, 'title': 'Family Helper', 'color': const Color(0xFF00BCD4)};
    } else if (points >= 300) {
      return {'level': 3, 'title': 'Task Tackler', 'color': const Color(0xFF4CAF50)};
    } else if (points >= 150) {
      return {'level': 2, 'title': 'Getting Started', 'color': const Color(0xFF2196F3)};
    } else {
      return {'level': 1, 'title': 'New Member', 'color': const Color(0xFF9E9E9E)};
    }
  }

  // Get earned achievements
  Future<List<String>> getEarnedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    if (achievementsJson != null) {
      final List<dynamic> achievementsList = jsonDecode(achievementsJson);
      return achievementsList.cast<String>();
    }
    return [];
  }

  // Unlock achievement
  Future<bool> unlockAchievement(String achievementId) async {
    final earned = await getEarnedAchievements();
    if (earned.contains(achievementId)) {
      return false; // Already earned
    }

    final achievement = _achievementDefinitions.firstWhere(
      (a) => a['id'] == achievementId,
      orElse: () => {},
    );

    if (achievement.isNotEmpty) {
      earned.add(achievementId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_achievementsKey, jsonEncode(earned));
      await addPoints(achievement['points'] as int);
      
      // Play achievement sound/haptic
      SoundService.instance.playAchievement();
      
      return true; // Newly earned
    }
    return false;
  }

  // Get achievement definition by ID
  Map<String, dynamic>? getAchievementDefinition(String id) {
    try {
      return _achievementDefinitions.firstWhere((a) => a['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get all achievement definitions
  List<Map<String, dynamic>> getAllAchievements() {
    return _achievementDefinitions;
  }

  // Get achievements by category
  List<Map<String, dynamic>> getAchievementsByCategory(String category) {
    return _achievementDefinitions.where((a) => a['category'] == category).toList();
  }

  // Get completion percentage
  Future<double> getCompletionPercentage() async {
    final earned = await getEarnedAchievements();
    return earned.length / _achievementDefinitions.length;
  }

  // Update streak
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString('last_login_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastLogin == null) {
      await prefs.setString('last_login_date', today);
      await prefs.setInt(_streakKey, 1);
      return;
    }

    final lastLoginDate = DateTime.parse('${lastLogin}T00:00:00');
    final todayDate = DateTime.parse('${today}T00:00:00');
    final difference = todayDate.difference(lastLoginDate).inDays;

    if (difference == 1) {
      // Consecutive day
      final currentStreak = prefs.getInt(_streakKey) ?? 0;
      await prefs.setInt(_streakKey, currentStreak + 1);
      await prefs.setString('last_login_date', today);
      
      // Check for streak achievements
      final streak = currentStreak + 1;
      if (streak == 7) {
        await unlockAchievement('week_warrior');
      }
    } else if (difference > 1) {
      // Streak broken
      await prefs.setInt(_streakKey, 1);
      await prefs.setString('last_login_date', today);
    }
    // If difference == 0, same day, do nothing
  }

  // Get current streak
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // Initialize user achievements (call on first app launch)
  Future<void> initializeAchievements() async {
    await unlockAchievement('first_login');
    await updateStreak();
    await _loadData();
  }

  // Load initial data and update streams
  Future<void> _loadData() async {
    _totalPoints = await getUserPoints();
    _pointsController.add(_totalPoints);
    
    final achievements = await getAllAchievementsWithStatus();
    _achievementsController.add(achievements);
  }

  // Get all achievements with unlock status
  Future<List<Achievement>> getAllAchievementsWithStatus() async {
    final earnedIds = await getEarnedAchievements();
    
    return _achievementDefinitions.map((def) {
      final isUnlocked = earnedIds.contains(def['id']);
      return Achievement(
        id: def['id'],
        title: def['title'],
        description: def['description'],
        icon: def['icon'],
        points: def['points'],
        color: def['color'],
        category: def['category'],
        tier: def['tier'],
        isUnlocked: isUnlocked,
        unlockedAt: isUnlocked ? DateTime.now() : null, // Simplified for now
      );
    }).toList();
  }

  // Trigger achievement by ID
  Future<void> triggerAchievement(String achievementId) async {
    final wasUnlocked = await unlockAchievement(achievementId);
    if (wasUnlocked) {
      // Refresh streams
      await _loadData();
    }
  }

  // Update points stream
  Future<void> _updatePointsStream() async {
    _totalPoints = await getUserPoints();
    _pointsController.add(_totalPoints);
  }

  // Dispose streams
  void dispose() {
    _achievementsController.close();
    _pointsController.close();
  }
}

// Achievement popup widget
class AchievementPopup extends StatefulWidget {
  final String achievementId;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    super.key,
    required this.achievementId,
    this.onDismiss,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = AchievementService.instance.getAchievementDefinition(widget.achievementId);
    if (achievement == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    achievement['color'],
                    (achievement['color'] as Color).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: achievement['color'].withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 ACHIEVEMENT UNLOCKED! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      achievement['icon'],
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    achievement['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['description'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${achievement['points']} Points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
