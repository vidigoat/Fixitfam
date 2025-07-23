import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();
  
  static SoundService get instance => _instance;
  
  bool _soundEnabled = false;
  bool get soundEnabled => _soundEnabled;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('enable_sound_effects') ?? false;
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_sound_effects', enabled);
  }
  
  void playSuccess() {
    if (!_soundEnabled) return;
    
    // Play haptic feedback as sound substitute
    HapticFeedback.lightImpact();
    
    // Show visual feedback
    Fluttertoast.showToast(
      msg: "🎉 Success!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  void playError() {
    if (!_soundEnabled) return;
    
    // Play haptic feedback
    HapticFeedback.heavyImpact();
    
    // Show visual feedback
    Fluttertoast.showToast(
      msg: "❌ Error!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFFF44336),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  void playClick() {
    if (!_soundEnabled) return;
    
    // Light haptic feedback for clicks
    HapticFeedback.selectionClick();
  }
  
  void playAchievement() {
    if (!_soundEnabled) return;
    
    // Strong haptic feedback for achievements
    HapticFeedback.heavyImpact();
    
    // Show celebration toast
    Fluttertoast.showToast(
      msg: "🏆 Achievement Unlocked!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFFFFD700),
      textColor: Colors.black,
      fontSize: 18.0,
    );
  }
  
  void playNotification() {
    if (!_soundEnabled) return;
    
    // Medium haptic feedback
    HapticFeedback.mediumImpact();
    
    // Show notification toast
    Fluttertoast.showToast(
      msg: "🔔 New notification",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF2196F3),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  void playLevelUp() {
    if (!_soundEnabled) return;
    
    // Sequence of haptic feedback
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
    
    // Show level up celebration
    Fluttertoast.showToast(
      msg: "⭐ Level Up! ⭐",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color(0xFF9C27B0),
      textColor: Colors.white,
      fontSize: 20.0,
    );
  }
}
