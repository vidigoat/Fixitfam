import 'package:flutter/material.dart';
import '../services/real_auth_service.dart';
import '../services/notification_service.dart';
import '../services/achievement_service.dart';
import '../services/avatar_service.dart';
import '../services/sound_service.dart';
import '../modes/adaptive_fambot_page.dart';
import '../modes/famfinance_manager.dart';
import '../modes/family_care_manager.dart';
import '../modes/smart_vault_manager.dart';
import '../modes/task_board_manager.dart';
import '../modes/trip_mode_manager.dart';
import 'real_signin_screen.dart';
import 'achievements_screen.dart';
import 'theme_customization_screen.dart';
import 'profile_screen.dart';

class RealHomeScreen extends StatefulWidget {
  const RealHomeScreen({super.key});

  @override
  State<RealHomeScreen> createState() => _RealHomeScreenState();
}

class _RealHomeScreenState extends State<RealHomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'FamVoice',
      'subtitle': 'Your Family Voice Assistant',
      'icon': Icons.smart_toy,
      'color': const Color(0xFF2196F3),
      'page': () => const AdaptiveFamBotPage(),
      'description': 'Voice-powered AI assistant for family tasks and planning',
      'isNew': true,
    },
    {
      'title': 'FamFinance',
      'subtitle': 'Budget Management',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF4CAF50),
      'page': () => const FamFinanceManager(),
      'description': 'Track expenses, manage budgets, and achieve financial goals',
      'isHot': true,
    },
    {
      'title': 'Family Care',
      'subtitle': 'Health & Wellness',
      'icon': Icons.favorite,
      'color': const Color(0xFFE91E63),
      'description': 'Health records, appointments, medication reminders',
      'page': () => const FamilyCareManager(),
    },
    {
      'title': 'Smart Vault',
      'subtitle': 'Document Manager',
      'icon': Icons.security,
      'color': const Color(0xFF607D8B),
      'description': 'Secure storage for important documents and files',
      'page': () => const SmartVaultManager(),
    },
    {
      'title': 'Task Board',
      'subtitle': 'Family Organizer',
      'icon': Icons.task_alt,
      'color': const Color(0xFF795548),
      'description': 'Assign chores, track habits, and manage daily activities',
      'page': () => const TaskBoardManager(),
    },
    {
      'title': 'Trip Mode',
      'subtitle': 'Travel Planner',
      'icon': Icons.flight,
      'color': const Color(0xFF9C27B0),
      'description': 'Plan trips, manage itineraries, and track travel expenses',
      'page': () => const TripModeManager(),
    },
    {
      'title': 'Achievements',
      'subtitle': 'Rewards & Progress',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD700),
      'page': () => const AchievementsScreen(),
      'description': 'Track your progress and unlock exciting rewards',
      'isNew': true,
    },
    {
      'title': 'Themes',
      'subtitle': 'Customize Appearance',
      'icon': Icons.palette,
      'color': const Color(0xFFFF5722),
      'page': () => const ThemeCustomizationScreen(),
      'description': 'Personalize your app with custom themes and colors',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
    _initializeNotifications();
    _initializeServices();
  }

  void _initializeServices() async {
    await AvatarService.instance.initialize();
    await SoundService.instance.initialize();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeNotifications() {
    // Welcome notification
    NotificationService.instance.showSuccess(
      'Your smart family management journey starts now!',
      title: 'Welcome to FixitFam! 🎉',
    );
    
    // Daily tips
    NotificationService.instance.showInfo(
      'Use FamBot AI to get personalized suggestions for your family!',
      title: 'Daily Tip 💡',
    );

    // Trigger welcome achievement
    AchievementService.instance.triggerAchievement('first_login');
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await RealAuthService.instance.getCurrentUser();
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1419),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
                Color(0xFF533A71),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar with animations
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2196F3).withValues(alpha: 0.8),
                          const Color(0xFF9C27B0).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  title: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFE1F5FE)],
                          ).createShader(bounds),
                          child: const Text(
                            'FixitFam',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  // Avatar button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AvatarService.instance.buildAvatar(
                      size: 35,
                      onTap: () {
                        SoundService.instance.playClick();
                        showDialog(
                          context: context,
                          builder: (context) => const AvatarSelectionDialog(),
                        );
                      },
                    ),
                  ),
                  // Enhanced notification button with badge
                  StreamBuilder<List<AppNotification>>(
                    stream: NotificationService.instance.notificationStream,
                    builder: (context, snapshot) {
                      final notifications = snapshot.data ?? [];
                      final unreadCount = notifications.length;
                      
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {
                              SoundService.instance.playClick();
                              _showNotificationsPanel(context);
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE91E63),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'logout') {
                        _signOut();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Enhanced Quick Stats with animations
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.dashboard, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'Quick Overview',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickStat('Tasks', '3', Icons.task_alt),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                Expanded(
                                  child: _buildQuickStat('Expenses', '₹3,750', Icons.currency_rupee),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                Expanded(
                                  child: _buildQuickStat('Documents', '12', Icons.folder),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Enhanced Feature Grid with staggered animations
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final animationValue = Curves.easeOutBack.transform(
                            (((_fadeAnimation.value - delay).clamp(0.0, 1.0)) / (1.0 - delay)).clamp(0.0, 1.0),
                          );
                          
                          return Transform.translate(
                            offset: Offset(0, 100 * (1 - animationValue)),
                            child: Opacity(
                              opacity: animationValue,
                              child: _buildEnhancedFeatureCard(_features[index], index),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _features.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Enhanced floating action button
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Quick add functionality
                _showQuickAddMenu(context);
              },
              backgroundColor: const Color(0xFF2196F3),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Quick Add',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              elevation: 8,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeatureCard(Map<String, dynamic> feature, int index) {
    return GestureDetector(
      onTap: () => _navigateToFeature(feature),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (feature['color'] as Color).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (feature['color'] as Color).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: feature['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feature['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    feature['description'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Badges for new/hot features
            if (feature['isNew'] == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            if (feature['isHot'] == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToFeature(Map<String, dynamic> feature) {
    // Play click sound
    SoundService.instance.playClick();
    
    // Trigger feature usage achievements
    AchievementService.instance.triggerAchievement('feature_explorer');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => feature['page'](),
      ),
    );
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await RealAuthService.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RealSignInScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          NotificationService.instance.clearAll();
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Color(0xFF2196F3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(child: NotificationPanel()),
          ],
        ),
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickAddItem('Expense', Icons.attach_money, const Color(0xFF4CAF50)),
                _buildQuickAddItem('Task', Icons.task, const Color(0xFF2196F3)),
                _buildQuickAddItem('Note', Icons.note, const Color(0xFFFF9800)),
                _buildQuickAddItem('Health', Icons.health_and_safety, const Color(0xFFE91E63)),
                _buildQuickAddItem('Trip', Icons.flight, const Color(0xFF9C27B0)),
                _buildQuickAddItem('Document', Icons.folder, const Color(0xFF607D8B)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddItem(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Handle quick add action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick add $label coming soon!'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
