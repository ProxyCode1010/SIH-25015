import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Note: आपको यह सुनिश्चित करना होगा कि VideoPreview.dart file में
// VideoPreview class में 'required String cameraIp' constructor parameter हो।
import 'package:vrikshanova/navigation/side_nav_drawer/controls/video_preview.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  // Controller for the IP text input.
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController();

    // Lock the screen to landscape orientation.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _ipController.dispose();

    // Reset orientation to portrait when exiting the screen.
    // NOTE: यह सुनिश्चित करेगा कि जब आप इस screen से बाहर निकलें तो orientation portrait हो जाए।
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // --- LOGIC ADDITION: IP Validation and Navigation ---
  void _handleButtonTap() {
    final String rawIp = _ipController.text.trim();

    if (rawIp.isEmpty) {
      _showSnackBar('कृपया IP पता या URL दर्ज करें।');
      return;
    }

    // Basic IP/URL cleaning and formatting
    String fullUrl = rawIp;

    // 1. यदि IP/URL में 'http://' या 'https://' नहीं है, तो 'http://' जोड़ें
    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      // NOTE: Rover/ESP32 streams अक्सर HTTP पर चलते हैं।
      fullUrl = 'http://$fullUrl';
    }

    // 2. IP/URL validation (A simple check that it can be parsed as a valid Uri)
    // Flutter में complex regex validation से बेहतर है कि हम Uri.tryParse का उपयोग करें
    final uri = Uri.tryParse(fullUrl);

    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      _showSnackBar('अवैध फॉर्मेट। कृपया सही IP:Port या URL दर्ज करें।');
      return;
    }

    // Navigation to VideoPreview, passing the validated URL
    Navigator.push(
      context,
      MaterialPageRoute(
        // IMPORTANT: यहाँ VideoPreview को 'cameraIp' parameter पास किया गया है।
        // VideoPreview class को अब इस parameter को accept करना होगा।
        builder: (context) => VideoPreview(cameraIp: fullUrl),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFD32F2F), // Red color for error/warning
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return _buildConnectionPanel();
  }

  Widget _buildConnectionPanel() {
    return Scaffold(
      backgroundColor: const Color(0xFF0a2e1a),
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  // Pops the screen if it was pushed onto the Navigator stack.
                  if (Navigator.canPop(context)) {
                    // Orientation को reset करना आवश्यक नहीं है क्योंकि वह dispose() में होता है,
                    // लेकिन यह सुनिश्चित करता है कि जब हम बाहर निकलें तो device portrait में जाए।
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Connection Panel
            Center(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a5c2f),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4CAF50),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'रोवर से कनेक्ट करें',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'कैमरा IP पता या स्ट्रीम URL दर्ज करें', // Updated text
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFa8d5ba),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // IP Address Input Field
                    TextField(
                      controller: _ipController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.url, // Hint for URL input
                      decoration: InputDecoration(
                        hintText: '192.168.1.100:8080 or http://server/stream',
                        hintStyle: const TextStyle(color: Color(0xFF689F38)),
                        filled: true,
                        fillColor: const Color(0xFF0a2e1a),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Connect Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Logic is now correctly handled here
                        onPressed: _handleButtonTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: const Color(0xFF4CAF50),
                          elevation: 8,
                        ),
                        child: const Text(
                          'कनेक्ट करें',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}