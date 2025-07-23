import 'package:flutter/material.dart';
import '../services/real_auth_service.dart';
import 'real_signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await RealAuthService.instance.getCurrentUser();
      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await RealAuthService.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RealSignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
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
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
            : _currentUser == null
                ? const Center(
                    child: Text(
                      'No user data found',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE91E63),
                          child: Text(
                            _currentUser!['fullName']?[0]?.toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person, color: Colors.white),
                                  title: const Text('Full Name', style: TextStyle(color: Colors.white70)),
                                  subtitle: Text(
                                    _currentUser!['fullName'] ?? 'N/A',
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.email, color: Colors.white),
                                  title: const Text('Email', style: TextStyle(color: Colors.white70)),
                                  subtitle: Text(
                                    _currentUser!['email'] ?? 'N/A',
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                if (_currentUser!['phoneNumber'] != null)
                                  ListTile(
                                    leading: const Icon(Icons.phone, color: Colors.white),
                                    title: const Text('Phone', style: TextStyle(color: Colors.white70)),
                                    subtitle: Text(
                                      _currentUser!['phoneNumber'] ?? 'N/A',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _signOut,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF44336),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
