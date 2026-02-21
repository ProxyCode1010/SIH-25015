import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vrikshanova/authentication/login_screen.dart';
import 'package:vrikshanova/authentication/otpscreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  bool hasMinLength = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    setState(() {
      final password = passwordController.text;
      hasMinLength = password.length >= 8;
      hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      hasLowerCase = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'नाम दर्ज करना आवश्यक है';
    }
    if (value.length < 2) {
      return 'नाम कम से कम 2 अक्षरों का होना चाहिए';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email दर्ज करना आवश्यक है';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'कृपया सही email दर्ज करें';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'फोन नंबर दर्ज करना आवश्यक है';
    }
    if (value.length != 10) {
      return 'फोन नंबर 10 अंकों का होना चाहिए';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'केवल नंबर दर्ज करें';
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
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'कम से कम एक बड़ा अक्षर (A-Z) होना चाहिए';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'कम से कम एक छोटा अक्षर (a-z) होना चाहिए';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'कम से कम एक अंक (0-9) होना चाहिए';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'कम से कम एक विशेष चिन्ह (!@# etc.) होना चाहिए';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password फिर से दर्ज करें';
    }
    if (value != passwordController.text) {
      return 'Password match नहीं हो रहा';
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

  Future<void> handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Step 1: Supabase में नया account बनाओ
        final authResponse = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (authResponse.user != null) {
          final userId = authResponse.user!.id;
          print('✅ User created with ID: $userId');
          print('✅ Email: ${authResponse.user!.email}');

          if (mounted) {
            setState(() => _isLoading = false);

            showSuccess('Account बनाया गया! OTP भेजा जा रहा है...');

            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              // ✅ EMAIL PASS KAR RAHE HAIN OTP SCREEN KO
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return OtpScreen(
                      email: emailController.text.trim(),
                      userId: userId,
                      fullName: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
          }
        }
      } on AuthException catch (error) {
        setState(() => _isLoading = false);
        print('❌ Auth Error: ${error.message}');

        if (error.message.contains('already exists')) {
          showError('यह email पहले से registered है');
        } else if (error.message.contains('weak password')) {
          showError('Password काफी strong नहीं है');
        } else {
          showError('Error: ${error.message}');
        }
      } catch (error) {
        setState(() => _isLoading = false);
        print('❌ Error: $error');
        showError('कुछ गलती हुई: $error');
      }
    }
  }

  Widget _buildPasswordStrengthIndicator(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      const Text(
                        '🌿',
                        style: TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        'वृक्षनोवा',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e5128),
                        ),
                      ),

                      const Text(
                        'नया खाता बनाएं',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF558b5f),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Name TextField
                      TextFormField(
                        controller: nameController,
                        validator: validateName,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Full Name',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF2d6a4f)),
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

                      // Email TextField
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

                      // Phone TextField
                      TextFormField(
                        controller: phoneController,
                        validator: validatePhone,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Mobile No.',
                          hintText: '98XXXXXXXX',
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF2d6a4f)),
                          counterText: '',
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

                      // Password TextField
                      TextFormField(
                        controller: passwordController,
                        validator: validatePassword,
                        enabled: !_isLoading,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Strong password बनाएं',
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

                      const SizedBox(height: 12),

                      // Password strength indicators
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFa8d5ba)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password में होना चाहिए:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2d6a4f),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPasswordStrengthIndicator(
                                'कम से कम 8 अक्षर', hasMinLength),
                            _buildPasswordStrengthIndicator(
                                'एक बड़ा अक्षर (A-Z)', hasUpperCase),
                            _buildPasswordStrengthIndicator(
                                'एक छोटा अक्षर (a-z)', hasLowerCase),
                            _buildPasswordStrengthIndicator(
                                'एक अंक (0-9)', hasDigit),
                            _buildPasswordStrengthIndicator(
                                'एक विशेष चिन्ह (!@#)', hasSpecialChar),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password TextField
                      TextFormField(
                        controller: confirmPasswordController,
                        validator: validateConfirmPassword,
                        enabled: !_isLoading,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'फिर से दर्ज करें',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2d6a4f)),
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
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF2d6a4f),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Register Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : handleRegister,
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
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Account बनाएं',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'पहले से खाता है?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF558b5f),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login करें',
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
        ),
      ),
    );
  }
}