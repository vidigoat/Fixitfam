import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedTheme = 'default';
  String _selectedAccentColor = 'blue';
  bool _isDarkMode = true;
  bool _enableAnimations = true;
  bool _enableSoundEffects = false;

  final Map<String, List<Color>> _themes = {
    'default': [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
    'ocean': [const Color(0xFF2E3192), const Color(0xFF1BFFFF), const Color(0xFF2E86AB)],
    'sunset': [const Color(0xFFFF6B6B), const Color(0xFFFFE66D), const Color(0xFF4ECDC4)],
    'forest': [const Color(0xFF2D5016), const Color(0xFF3A5F0B), const Color(0xFF86A3B8)],
    'royal': [const Color(0xFF4A148C), const Color(0xFF7B1FA2), const Color(0xFF9C27B0)],
    'cyberpunk': [const Color(0xFF0F0F23), const Color(0xFF7209B7), const Color(0xFF560BAD)],
  };

  final Map<String, Color> _accentColors = {
    'blue': const Color(0xFF2196F3),
    'green': const Color(0xFF4CAF50),
    'orange': const Color(0xFFFF9800),
    'purple': const Color(0xFF9C27B0),
    'red': const Color(0xFFF44336),
    'teal': const Color(0xFF009688),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadPreferences();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'default';
      _selectedAccentColor = prefs.getString('accent_color') ?? 'blue';
      _isDarkMode = prefs.getBool('dark_mode') ?? true;
      _enableAnimations = prefs.getBool('enable_animations') ?? true;
      _enableSoundEffects = prefs.getBool('enable_sound_effects') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _selectedTheme);
    await prefs.setString('accent_color', _selectedAccentColor);
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('enable_animations', _enableAnimations);
    await prefs.setBool('enable_sound_effects', _enableSoundEffects);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themes[_selectedTheme]!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: currentTheme,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Theme Settings 🎨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Settings content
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Theme selection
                          _buildSection(
                            'Color Themes',
                            Icons.palette,
                            _buildThemeGrid(),
                          ),
                          const SizedBox(height: 24),
                          // Accent color selection
                          _buildSection(
                            'Accent Colors',
                            Icons.color_lens,
                            _buildAccentColorGrid(),
                          ),
                          const SizedBox(height: 24),
                          // Settings toggles
                          _buildSection(
                            'Display Settings',
                            Icons.settings_display,
                            Column(
                              children: [
                                _buildToggleTile(
                                  'Dark Mode',
                                  'Use dark theme throughout the app',
                                  Icons.dark_mode,
                                  _isDarkMode,
                                  (value) {
                                    setState(() => _isDarkMode = value);
                                    _savePreferences();
                                  },
                                ),
                                _buildToggleTile(
                                  'Animations',
                                  'Enable smooth animations and transitions',
                                  Icons.animation,
                                  _enableAnimations,
                                  (value) {
                                    setState(() => _enableAnimations = value);
                                    _savePreferences();
                                  },
                                ),
                                _buildToggleTile(
                                  'Sound Effects',
                                  'Play sounds for interactions and achievements',
                                  Icons.volume_up,
                                  _enableSoundEffects,
                                  (value) {
                                    setState(() => _enableSoundEffects = value);
                                    _savePreferences();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Preview section
                          _buildSection(
                            'Preview',
                            Icons.preview,
                            _buildPreviewCard(),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildThemeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final themeEntry = _themes.entries.toList()[index];
        final themeName = themeEntry.key;
        final themeColors = themeEntry.value;
        final isSelected = _selectedTheme == themeName;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedTheme = themeName);
            _savePreferences();
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeColors,
              ),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: _accentColors[_selectedAccentColor]!, width: 3)
                  : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: _accentColors[_selectedAccentColor],
                    size: 20,
                  ),
                const SizedBox(height: 4),
                Text(
                  themeName.substring(0, 1).toUpperCase() + themeName.substring(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccentColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _accentColors.length,
      itemBuilder: (context, index) {
        final colorEntry = _accentColors.entries.toList()[index];
        final colorName = colorEntry.key;
        final color = colorEntry.value;
        final isSelected = _selectedAccentColor == colorName;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedAccentColor = colorName);
            _savePreferences();
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColors[_selectedAccentColor]!.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _accentColors[_selectedAccentColor],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _accentColors[_selectedAccentColor],
            activeTrackColor: _accentColors[_selectedAccentColor]!.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _themes[_selectedTheme]!,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColors[_selectedAccentColor]!.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accentColors[_selectedAccentColor],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Card Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'This is how your theme will look',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.favorite,
                color: _accentColors[_selectedAccentColor],
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: _accentColors[_selectedAccentColor],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
