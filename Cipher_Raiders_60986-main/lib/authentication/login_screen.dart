import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrikshanova/authentication/registration_screen.dart';
import 'package:vrikshanova/navigation/bottom_nav/Home/homescreen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email दर्ज करना आवश्यक है';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'कृपया सही email दर्ज करें';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password दर्ज करना आवश्यक है';
    }
    if (value.length < 8) {
      return 'Password कम से कम 8 अक्षरों का होना चाहिए';
    }
    return null;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHomeWithAnimation() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const HomeScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _saveLoginData(String userId, String email, String? fullName, String? phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userId);
      await prefs.setString('userEmail', email);
      if (fullName != null) await prefs.setString('userFullName', fullName);
      if (phone != null) await prefs.setString('userPhone', phone);

      print('✅ Login data saved to SharedPreferences');
    } catch (error) {
      print('❌ Error saving login data: $error');
    }
  }

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('🔐 Logging in with email: ${emailController.text.trim()}');

        final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (mounted) {
          if (response.user != null) {
            final userId = response.user!.id;
            final userEmail = response.user!.email;

            print('✅ Login successful - User ID: $userId');
            print('✅ Email: $userEmail');

            String? fullName;
            String? phone;

            try {
              final farmerData = await supabase
                  .from('farmers')
                  .select()
                  .eq('user_id', userId)
                  .maybeSingle();

              if (farmerData != null) {
                fullName = farmerData['full_name'];
                phone = farmerData['phone'];
                print('✅ Farmer data found:');
                print('   - Name: $fullName');
                print('   - Email: ${farmerData['email']}');
                print('   - Phone: $phone');
              } else {
                print('⚠️ Warning: Farmer data not found for user $userId');
              }
            } catch (dbError) {
              print('⚠️ Error fetching farmer data: $dbError');
            }

            // ✅ SharedPreferences mein login data save karo
            await _saveLoginData(userId, userEmail ?? '', fullName, phone);

            setState(() => _isLoading = false);
            showSuccess('Login सफल! 🎉');

            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              _navigateToHomeWithAnimation();
            }
          }
        }
      } on AuthException catch (error) {
        setState(() => _isLoading = false);
        print('❌ Auth Error: ${error.message}');

        if (error.message.contains('Invalid login credentials')) {
          showError('Email या Password गलत है');
        } else if (error.message.contains('User not found')) {
          showError('यह email registered नहीं है');
        } else if (error.message.contains('Email not confirmed')) {
          showError('कृपया अपने email को verify करें');
        } else if (error.message.contains('disabled')) {
          showError('यह account disable है');
        } else {
          showError('Login Error: ${error.message}');
        }
      } catch (error) {
        setState(() => _isLoading = false);
        print('❌ Error: $error');
        showError('कुछ गलती हुई: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F9F0),
                Color(0xFFE8F5E9),
              ],
            ),
          ),
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  const Text(
                    '🌿',
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'वृक्षनोवा',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e5128),
                    ),
                  ),

                  const Text(
                    'आपके खेत, आपकी सफलता',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF558b5f),
                    ),
                  ),

                  const SizedBox(height: 50),

                  TextFormField(
                    controller: emailController,
                    validator: validateEmail,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'farmer@example.com',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF2d6a4f)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFa8d5ba),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1e5128),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        color: Color(0xFF2d6a4f),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    validator: validatePassword,
                    enabled: !_isLoading,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF2d6a4f)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFa8d5ba),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1e5128),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        color: Color(0xFF2d6a4f),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF2d6a4f),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        showError('Forgot Password feature coming soon!');
                      },
                      child: const Text(
                        'Password भूल गए?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1e5128),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1e5128),
                      disabledBackgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'लॉगिन हो रहा है...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : const Text(
                      'लॉगिन करें',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'खाता नहीं है?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF558b5f),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up करें',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1e5128),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}