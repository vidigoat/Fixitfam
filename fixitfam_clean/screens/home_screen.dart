import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/mode_icons.dart';
import '../widgets/safe_dialog.dart';
import '../modes/fambot_page.dart';
import '../modes/smartbudget_page.dart';
import '../modes/kidzone_page.dart';
import '../modes/tripmode_page.dart';
import '../modes/familycare_page.dart';
import '../modes/smartvault_page.dart';
import '../modes/taskboard_page.dart';
import '../modes/famchat_page.dart';
import '../family_survey_screen.dart';
import '../family_group_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isPremium;

  const HomeScreen({Key? key, this.isPremium = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _userName = 'Family';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
    _animationController.forward();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Family';
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              Color(0xFF16213E),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      _buildWelcomeSection(),
                      _buildQuickActions(),
                      _buildModesGrid(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.family_restroom, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'FixitFam',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (widget.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotifications(),
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showProfileMenu(),
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'F',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $_userName! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your family\'s smart assistant is ready to help',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Family Survey',
                    'Complete your profile',
                    Icons.assignment,
                    const Color(0xFF6C63FF),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FamilySurveyScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'Add Members',
                    'Invite family',
                    Icons.person_add,
                    const Color(0xFF03DAC6),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FamilyGroupSetupScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModesGrid() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Modes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildModeCard(
                  'FamBot',
                  'AI Family Assistant',
                  ModeIcons.famBot(size: 50),
                  false,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FamBotPage()),
                  ),
                ),
                _buildModeCard(
                  'SmartBudget',
                  'Family Finances',
                  ModeIcons.smartBudget(size: 50),
                  true,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SmartBudgetPage()),
                  ),
                ),
                _buildModeCard(
                  'KidZone',
                  'Child Safety',
                  ModeIcons.kidZone(size: 50),
                  true,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KidZonePage()),
                  ),
                ),
                _buildModeCard(
                  'TripMode',
                  'Travel Planning',
                  ModeIcons.tripMode(size: 50),
                  true,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripModePage()),
                  ),
                ),
                _buildModeCard(
                  'FamilyCare',
                  'Health & Wellness',
                  ModeIcons.familyCare(size: 50),
                  true,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FamilyCarePage()),
                  ),
                ),
                _buildModeCard(
                  'SmartVault',
                  'Document Storage',
                  ModeIcons.smartVault(size: 50),
                  true,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SmartVaultPage()),
                  ),
                ),
                _buildModeCard(
                  'TaskBoard',
                  'Family Tasks',
                  ModeIcons.taskBoard(size: 50),
                  false,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskBoardPage()),
                  ),
                ),
                _buildModeCard(
                  'FamChat',
                  'Family Messaging',
                  ModeIcons.famChat(size: 50),
                  false,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FamChatPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(String title, String subtitle, Widget icon, bool requiresPremium, VoidCallback onTap) {
    final bool canAccess = widget.isPremium || !requiresPremium;
    
    return GestureDetector(
      onTap: canAccess ? onTap : () => _showPremiumRequired(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: canAccess 
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF1A1A2E).withOpacity(0.5), const Color(0xFF16213E).withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canAccess ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Opacity(
                    opacity: canAccess ? 1.0 : 0.5,
                    child: icon,
                  ),
                  if (requiresPremium && !widget.isPremium)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: canAccess ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: canAccess ? Colors.white70 : Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    // TODO: Implement notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications coming soon!')),
    );
  }

  void _showProfileMenu() {
    // TODO: Implement profile menu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile menu coming soon!')),
    );
  }

  void _showPremiumRequired() {
    SafeDialog.showPremiumDialog(context: context);
  }
}
