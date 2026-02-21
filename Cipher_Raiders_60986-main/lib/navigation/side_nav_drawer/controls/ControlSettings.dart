import 'package:flutter/material.dart';

class ControlSettings extends StatefulWidget {
  const ControlSettings({super.key});

  @override
  State<ControlSettings> createState() => _ControlSettingsState();
}

class _ControlSettingsState extends State<ControlSettings> {
  // 1. Connectivity State
  String _ipAddress = '192.168.1.100';
  String _port = '8080';

  // 2. Control Layout State
  bool _isSteeringLeft = true; // True: Steering (L/R) on Left side, False: Throttle (F/B) on Left side

  // 3. Visual/Theme State
  Color _buttonColor = const Color(0xFF4CAF50); // Default Green
  double _controlOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRITICAL FIX: Wrap the entire body in SafeArea to avoid overlap
      // with the status bar (notch, battery, etc.) in landscape mode.
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Settings screen is optimized for LANDSCAPE mode
            return _buildLandscapeSettings();
          },
        ),
      ),
    );
  }

  // --- LANDSCAPE VIEW (Settings Focused) ---
  Widget _buildLandscapeSettings() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1F8F6), // Very light green base
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar (Title)
          Container(
            color: const Color(0xFF4CAF50), // Theme Green
            // FIX: Ensure horizontal padding is equal on both sides (e.g., 24.0)
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Rover Control Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Settings Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // 1. Connectivity Settings (IP Address / Live Feed)
                _buildSettingsCard(
                  title: 'Connectivity & Live Feed',
                  icon: Icons.wifi,
                  children: [
                    _buildIPInput(),
                    _buildPortInput(),
                    const Divider(height: 20),
                    _buildSettingRow(
                      label: 'Enable Video Feed',
                      trailing: Switch(
                        value: true,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (val) {
                          // Toggle video feed state (will implement later)
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Control Layout Settings (Joystick Position)
                _buildSettingsCard(
                  title: 'Control Layout',
                  icon: Icons.gamepad,
                  children: [
                    _buildSettingRow(
                      label: 'Place Steering (L/R) on Left Side',
                      trailing: Switch(
                        value: _isSteeringLeft,
                        activeColor: const Color(0xFF4CAF50),
                        onChanged: (val) {
                          setState(() {
                            _isSteeringLeft = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isSteeringLeft
                          ? 'Current: Steering controls (← →) are on the left.'
                          : 'Current: Throttle controls (↑ ↓) are on the left.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Visual Settings (Theme & Colors)
                _buildSettingsCard(
                  title: 'Visual & Theme',
                  icon: Icons.color_lens,
                  children: [
                    _buildSettingRow(
                      label: 'Button Opacity (Transparency)',
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: _controlOpacity,
                          min: 0.3,
                          max: 1.0,
                          divisions: 7,
                          activeColor: const Color(0xFF4CAF50),
                          onChanged: (value) {
                            setState(() {
                              _controlOpacity = value;
                            });
                          },
                        ),
                      ),
                    ),
                    _buildSettingRow(
                      label: 'Control Color (Button Color)',
                      trailing: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: _buttonColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300)
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Placeholder for a future color picker
                    const Text(
                      'A color picker will be added here to change the button color.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Card Widget ---
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4CAF50), size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- Reusable Setting Row ---
  Widget _buildSettingRow({required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          trailing,
        ],
      ),
    );
  }

  // --- IP Address Input ---
  Widget _buildIPInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        initialValue: _ipAddress,
        decoration: InputDecoration(
          labelText: 'Rover IP Address (Video Feed Source)',
          labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
          prefixIcon: const Icon(Icons.network_check, color: Color(0xFF4CAF50)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
        keyboardType: TextInputType.url,
        onChanged: (value) {
          _ipAddress = value;
          // Logic: Test connectivity after changing IP address
        },
      ),
    );
  }

  // --- Port Input ---
  Widget _buildPortInput() {
    return TextFormField(
      initialValue: _port,
      decoration: InputDecoration(
        labelText: 'Port Number',
        labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
        prefixIcon: const Icon(Icons.settings_input_hdmi, color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _port = value;
        // Logic: Update port number
      },
    );
  }
}