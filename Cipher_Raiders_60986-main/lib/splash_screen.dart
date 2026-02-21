import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrikshanova/authentication/login_screen.dart';
import 'package:vrikshanova/navigation/bottom_nav/Home/homescreen.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.repeat(reverse: true);
    _progressController.forward();

    _handleNavigation();
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      try {
        final session = supabase.auth.currentSession;
        final user = supabase.auth.currentUser;

        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        print('🔍 Checking login status...');
        print('Session: $session');
        print('User: $user');
        print('IsLoggedIn in Prefs: $isLoggedIn');

        if (session != null && user != null && isLoggedIn) {
          print('✅ User already logged in: ${user.email}');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          print('❌ No user logged in, going to login screen');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        }
      } catch (error) {
        print('⚠️ Error checking session: $error');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _progressController.dispose();
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
              Color(0xFF0d3b1f),
              Color(0xFF1e5128),
              Color(0xFF2d6a4f),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Text(
                  "🌿",
                  style: TextStyle(fontSize: 100),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "वृक्षनोवा",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Text(
                "आपके खेत, आपकी सफलता",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),

              Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            value: _progressController.value,
                            minHeight: 6,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      int percentage =
                      (_progressController.value * 100).toInt();
                      return Text(
                        "$percentage%",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}