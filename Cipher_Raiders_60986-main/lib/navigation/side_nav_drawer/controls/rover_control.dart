import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/controls/esp_connection.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/controls/ControlSettings.dart';

// THEME COLORS
const Color darkGreen = Color(0xFF1e5128);
const Color cardColor = Color(0xFF2E5339);
const Color veryDarkGreen = Color(0xFF0d3b1f);
const Color mediumGreen = Color(0xFF2d6a4f);
const Color lightGreenAccent = Color(0xFFa8d5aa);

class RoverControl extends StatefulWidget {
  final String cameraIp;
  const RoverControl({super.key, required this.cameraIp});

  @override
  State<RoverControl> createState() => _RoverControlState();
}

class _RoverControlState extends State<RoverControl> with SingleTickerProviderStateMixin {
  final EspConnection espConnection = EspConnection();

  String? _pressedButton;
  double _currentSpeed = 1.0;
  bool _isConnected = false;

  // NEW: For Interactive Text Feedback
  String _feedbackText = 'Ready to Move';
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackAnimation;

  late WebViewController _webViewController;
  late String _controlBaseUrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final Uri uri = Uri.parse(widget.cameraIp);
    _controlBaseUrl = '${uri.scheme}://${uri.host}:${uri.port}';

    espConnection.connect();

    espConnection.connectionStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isConnected = status;
        });
      }
    });

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.cameraIp));

    // Initialize feedback animation
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    espConnection.disconnect();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Update feedback text with animation
  void _updateFeedback(String text) {
    setState(() {
      _feedbackText = text;
    });
    _feedbackAnimationController.forward(from: 0.0);
  }

  void _sendCommand(String direction) {
    if (!_isConnected) {
      print('Cannot send command: WebSocket is disconnected.');
      return;
    }

    if (direction != 'stop') {
      int mappedSpeed = (_currentSpeed * 200).toInt().clamp(100, 255);
      espConnection.sendCommand('speed:$mappedSpeed');
    }

    espConnection.sendCommand(direction);
    print('WS Sent Command: $direction (Speed: ${_currentSpeed.toStringAsFixed(1)}x)');
  }

  void _onButtonPressed(String button) {
    setState(() {
      _pressedButton = button;
    });

    // ➡️ COMMAND LOGIC REVERSED (as requested):
    switch(button) {
      case 'forward':
      // UI बटन 'FORWARD' दबाया गया है।
      // COMMAND: 'backward' भेजी गई।
        _sendCommand('backward');
        // FEEDBACK: UI के अनुसार 'Moving Forward' दिखाया गया।
        _updateFeedback('⬆️ Moving Forward');
        break;
      case 'backward':
      // UI बटन 'BACKWARD' दबाया गया है।
      // COMMAND: 'forward' भेजी गई।
        _sendCommand('forward');
        // FEEDBACK: UI के अनुसार 'Moving Backward' दिखाया गया।
        _updateFeedback('⬇️ Moving Backward');
        break;
      case 'left':
        _sendCommand('left');
        _updateFeedback('⬅️ Turning Left');
        break;
      case 'right':
        _sendCommand('right');
        _updateFeedback('➡️ Turning Right');
        break;
    }
    // ⬅️ COMMAND LOGIC REVERSED ENDS HERE
  }

  void _onButtonReleased() {
    setState(() {
      _pressedButton = null;
    });
    _sendCommand('stop');
    _updateFeedback('🛑 Stopped');
    print('Button Released: STOP');
  }

  void _onStopInteraction() {
    setState(() {
      _pressedButton = null;
    });
    _sendCommand('stop');
    _updateFeedback('🚨 EMERGENCY STOP!');
    print('EMERGENCY STOP initiated.');
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final String connectionStatusText = _isConnected ? 'WS Connected' : 'Disconnected';
    final Color connectionColor = _isConnected ? lightGreenAccent : Colors.redAccent;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: connectionColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: connectionColor.withOpacity(0.8),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          connectionStatusText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Speed: ${_currentSpeed.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // NEW: Interactive Feedback Display Widget
  Widget _buildFeedbackDisplay() {
    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              darkGreen.withOpacity(0.9),
              mediumGreen.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: lightGreenAccent.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Text(
          _feedbackText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return _buildLandscapeView();
            } else {
              return _buildPortraitView();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeView() {
    return Stack(
      children: [
        // 1. Live Video Feed
        Positioned.fill(
          child: WebViewWidget(controller: _webViewController),
        ),

        // 2. Top Bar
        Material(
          elevation: 8.0,
          color: cardColor,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTopBarButton(
                  icon: Icons.arrow_back,
                  label: 'Back',
                  onTap: () => Navigator.pop(context),
                ),
                _buildStatusIndicator(),
                _buildTopBarButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildSettingsDialog(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 3. NEW: Interactive Feedback Display (Center Top)
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: _buildFeedbackDisplay(),
          ),
        ),

        // 4. Control Layout
        Padding(
          padding: const EdgeInsets.only(
            top: 60.0,
            bottom: 70.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _buildSteeringControls(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildThrottleControls(),
              ),
            ],
          ),
        ),

        // 5. STOP Button
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: Center(
            child: _buildStopButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: _onStopInteraction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade700,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_circle_outlined, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'STOP ROVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteeringControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildControlButton(
          'left',
          '←',
          'LEFT',
          _onButtonPressed,
          _onButtonReleased,
          size: 60.0,
          fontSize: 32.0,
        ),
        const SizedBox(width: 80),
        _buildControlButton(
          'right',
          '→',
          'RIGHT',
          _onButtonPressed,
          _onButtonReleased,
          size: 60.0,
          fontSize: 32.0,
        ),
      ],
    );
  }

  Widget _buildThrottleControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // UI अभी भी FORWARD बटन दिखाता है।
        _buildControlButton(
          'forward',
          '↑',
          'FORWARD',
          _onButtonPressed,
          _onButtonReleased,
          size: 60.0,
          fontSize: 32.0,
        ),
        // UI अभी भी BACKWARD बटन दिखाता है।
        _buildControlButton(
          'backward',
          '↓',
          'BACKWARD',
          _onButtonPressed,
          _onButtonReleased,
          size: 60.0,
          fontSize: 32.0,
        ),
      ],
    );
  }

  Widget _buildPortraitView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1F8F6),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_locked, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please rotate to landscape',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'to use Rover Controls',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
      String id,
      String icon,
      String label,
      Function(String) onPressed,
      Function() onReleased, {
        double size = 60.0,
        double fontSize = 32.0,
      }) {
    bool isPressed = _pressedButton == id;

    return GestureDetector(
      onTapDown: (_) => onPressed(id),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isPressed ? mediumGreen : darkGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Center(
        child: Text(
          'General Rover Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Speed Control (Affects Rover Command)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _currentSpeed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 3,
                        activeColor: darkGreen,
                        inactiveColor: const Color(0xFFE8F5E9),
                        onChanged: (value) {
                          setState(() {
                            _currentSpeed = value;
                          });
                          this.setState(() {
                            _currentSpeed = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentSpeed.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Camera Feed On/Off',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                    value: true,
                    activeColor: darkGreen,
                    onChanged: (value) {
                      // Logic to hide/show WebView
                    }
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          icon: const Icon(Icons.tune, color: Colors.blueGrey),
          label: const Text(
            'Control Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ControlSettings()),
            );
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}