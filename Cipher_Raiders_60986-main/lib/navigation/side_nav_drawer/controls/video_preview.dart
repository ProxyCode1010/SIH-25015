import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart'; // REQUIRED PACKAGE
import 'package:vrikshanova/navigation/side_nav_drawer/controls/rover_control.dart';

// THEME COLOR
const Color darkGreen = Color(0xFF1e5128); // Using a theme color for the pause screen

// IMPORTANT: Constructor added to accept the camera IP/URL from the previous screen
class VideoPreview extends StatefulWidget {
  final String cameraIp;
  const VideoPreview({super.key, required this.cameraIp});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  // State to handle the toggle between Play and Pause icons.
  bool _isPlaying = true;

  // WebView Controller to manage the video stream
  late WebViewController _webViewController;

  // Define button size and padding constants for consistent design
  static const double _controlButtonSize = 56.0;
  static const double _edgePadding = 24.0;

  @override
  void initState() {
    super.initState();
    // 1. Enforce Landscape mode for this screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 2. Initialize and configure the WebView Controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
    // Load the stream URL received from the previous screen
      ..loadRequest(Uri.parse(widget.cameraIp));
  }

  @override
  void dispose() {
    // 3. Reset orientation to portrait when leaving the screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // --- LOGIC: Play/Pause Video Stream (Updated to only toggle state) ---
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video Stream Resumed.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video Stream Paused.')),
      );
    }
  }

  // --- LOGIC: Navigate to Rover Control ---
  void _handleStartTap() {
    // Navigate to RoverControl, passing the camera IP/URL
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoverControl(cameraIp: widget.cameraIp),
      ),
    );
  }

  void _handleCloseTap() {
    // Exit this screen and return to the IP entry screen.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // --- NEW: Static Pause Overlay Widget ---
  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8), // Dark transparent background
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle_outline, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text(
              'Stream Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Base layer for Live Video Feed (WebView)
          // Uses Positioned.fill and SizedBox.expand to ensure full screen coverage in landscape.
          Positioned.fill(
            child: _isPlaying
                ? SizedBox.expand( // NEW: Ensures the WebView container takes full space
              child: WebViewWidget(controller: _webViewController),
            )
                : Container(color: Colors.black), // Hide WebView when paused
          ),

          // 1B. Pause Overlay (Shown when _isPlaying is false)
          if (!_isPlaying)
            Positioned.fill(
              child: _buildPauseOverlay(),
            ),


          // --- Control Buttons Layer ---

          // 1. Close Button (Top Left)
          Positioned(
            top: _edgePadding,
            left: _edgePadding,
            child: _buildControlCircleButton(
              icon: Icons.close_rounded,
              color: const Color(0xFFFF6B6B), // Red for disconnect/close
              onTap: _handleCloseTap,
              tooltip: 'Close/Disconnect',
            ),
          ),

          // 2. Play/Pause Button (Top Right)
          Positioned(
            top: _edgePadding,
            right: _edgePadding,
            child: _buildControlCircleButton(
              icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF4CAF50), // Green for control
              onTap: _togglePlayPause,
              tooltip: _isPlaying ? 'Pause Video' : 'Play Video',
            ),
          ),

          // 3. Start Button (Bottom Right)
          Positioned(
            bottom: _edgePadding,
            right: _edgePadding,
            child: ElevatedButton.icon(
              onPressed: _handleStartTap, // Navigation logic here
              icon: const Icon(Icons.drive_eta, color: Colors.white, size: 28),
              label: const Text(
                'Start Control', // Updated label for clarity
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create the rounded, shadowed control buttons
  Widget _buildControlCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: _controlButtonSize,
          height: _controlButtonSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}