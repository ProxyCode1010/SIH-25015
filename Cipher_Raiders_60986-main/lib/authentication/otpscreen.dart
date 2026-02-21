import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vrikshanova/authentication/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String userId;
  final String fullName;
  final String phone;

  const OtpScreen({
    super.key,
    required this.email,
    required this.userId,
    required this.fullName,
    required this.phone,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  bool _isLoading = false;
  final supabase = Supabase.instance.client;

  // ✅ TIMER - 3 MINUTES (180 seconds)
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes = 180 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 180; // Reset to 3 minutes

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  String get _timerText {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

  void navigateToLoginScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          final scaleTween = Tween<double>(begin: 0.9, end: 1.0).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );

          return ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  // ✅ OTP VERIFY + DATABASE INSERT (IMPROVED)
  Future<void> handleVerifyOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      showError('कृपया सभी 6 अंक दर्ज करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔐 Verifying OTP: $otp');
      print('📧 Email: ${widget.email}');

      // ✅ STEP 1: OTP VERIFY
      final response = await supabase.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.signup,
      );

      if (response.user != null) {
        print('✅ OTP Verified Successfully!');
        print('✅ User ID: ${response.user!.id}');
        print('✅ Email confirmed: ${response.user!.emailConfirmedAt}');

        // ✅ STEP 2: CHECK IF USER ALREADY EXISTS IN FARMERS TABLE
        try {
          final existingFarmer = await supabase
              .from('farmers')
              .select()
              .eq('email', widget.email)
              .maybeSingle();

          if (existingFarmer != null) {
            print('⚠️ Farmer already exists in database');
            setState(() => _isLoading = false);
            showSuccess('Email verify हो गया! अब login करें 🎉');
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              navigateToLoginScreen();
            }
            return;
          }

          // ✅ STEP 3: INSERT NEW FARMER DATA
          print('📝 Inserting farmer data...');

          final insertData = {
            'user_id': response.user!.id,  // ✅ USER_ID ADD KIYA
            'full_name': widget.fullName,
            'email': widget.email,
            'phone': widget.phone,
          };

          print('Data to insert: $insertData');

          await supabase.from('farmers').insert(insertData);

          print('✅ Farmer data saved successfully!');

          setState(() => _isLoading = false);
          showSuccess('Email verify हो गया! अब login करें 🎉');

          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            navigateToLoginScreen();
          }
        } catch (dbError) {
          print('❌ Database Error: $dbError');
          setState(() => _isLoading = false);

          // Check specific error types
          if (dbError.toString().contains('duplicate key')) {
            showSuccess('Email verify हो गया! अब login करें 🎉');
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              navigateToLoginScreen();
            }
          } else if (dbError.toString().contains('violates foreign key constraint')) {
            showError('User data save में problem है। Support से संपर्क करें।');
          } else {
            showError('Data save नहीं हुआ: ${dbError.toString()}');
          }
        }
      } else {
        setState(() => _isLoading = false);
        showError('OTP verification failed');
      }
    } on AuthException catch (error) {
      setState(() => _isLoading = false);
      print('❌ Auth Error: ${error.message}');

      if (error.message.contains('Token has expired') ||
          error.message.contains('expired')) {
        showError('OTP expire हो गया है। नया OTP भेजें।');
      } else if (error.message.contains('Invalid token') ||
          error.message.contains('invalid')) {
        showError('OTP गलत है। सही OTP दर्ज करें।');
      } else if (error.message.contains('Email not confirmed')) {
        showError('Email verify नहीं हुआ। OTP फिर से भेजें।');
      } else {
        showError('Error: ${error.message}');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      print('❌ Unexpected Error: $error');
      showError('कुछ गलत हुआ। दोबारा try करें।');
    }
  }

  // ✅ RESEND OTP (IMPROVED)
  Future<void> handleResendOtp() async {
    if (!_canResend) {
      showError('कृपया $_timerText के बाद try करें');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📤 Resending OTP to: ${widget.email}');

      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      // Clear all OTP boxes
      for (var controller in otpControllers) {
        controller.clear();
      }

      // Focus on first box
      FocusScope.of(context).requestFocus(focusNodes[0]);

      setState(() => _isLoading = false);
      showSuccess('नया OTP भेजा गया! Email check करें 📧');

      // Restart timer
      _startTimer();
    } on AuthException catch (error) {
      setState(() => _isLoading = false);
      print('❌ Resend Error: ${error.message}');

      if (error.message.contains('rate limit')) {
        showError('बहुत जल्दी-जल्दी request भेज रहे हो। थोड़ा wait करो।');
      } else {
        showError('OTP नहीं भेजा जा सका: ${error.message}');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      print('❌ Error: $error');
      showError('कुछ गलत हुआ: $error');
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
          constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                const Text(
                  '✉️',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 20),

                const Text(
                  'वृक्षनोवा OTP',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e5128),
                  ),
                ),

                const Text(
                  'अपना ईमेल सत्यापित करें',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF558b5f),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'OTP भेजा गया: ${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF558b5f),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ TIMER DISPLAY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _remainingSeconds < 60
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _remainingSeconds < 60
                          ? Colors.red.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _remainingSeconds < 60
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'समय बाकी: $_timerText',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds < 60
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                        (index) => SizedBox(
                      width: 48,
                      height: 60,
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (RawKeyEvent event) {
                          if (event is RawKeyDownEvent &&
                              event.logicalKey ==
                                  LogicalKeyboardKey.backspace) {
                            if (otpControllers[index].text.isEmpty &&
                                index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(focusNodes[index - 1]);
                              otpControllers[index - 1].clear();
                            }
                          }
                        },
                        child: TextField(
                          controller: otpControllers[index],
                          focusNode: focusNodes[index],
                          enabled: !_isLoading,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 5) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[index + 1]);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            }
                          },
                          onTap: () {
                            otpControllers[index].selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                      offset: otpControllers[index].text.length),
                                );
                          },
                          decoration: InputDecoration(
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
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1e5128),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Verify Button
                ElevatedButton(
                  onPressed: _isLoading ? null : handleVerifyOtp,
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
                    'Verify करें',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Resend OTP Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'OTP नहीं मिला?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF558b5f),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading || !_canResend ? null : handleResendOtp,
                      child: Text(
                        _canResend ? 'दोबारा भेजें' : '($_timerText)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _canResend
                              ? const Color(0xFF1e5128)
                              : Colors.grey,
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
    );
  }
}