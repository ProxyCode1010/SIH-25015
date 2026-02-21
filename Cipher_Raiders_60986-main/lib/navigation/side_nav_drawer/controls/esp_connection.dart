import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

/// ESP32 के WebSocket कनेक्शन को मैनेज करने के लिए Singleton Class.
class EspConnection {
  // --- CONNECTION SETTINGS ---
  // यह IP एड्रेस आपके ESP32 का होना चाहिए
  final String _espIpAddress = "10.41.165.22";
  // ESP32 कोड में 24 पोर्ट पर WebSocket चल रहा है (Updated)
  final int _espPort = 81;

  // WebSocket URL फॉर्मेट: ws://<IP>:<PORT>
  late final String _wsUrl;

  // --- PRIVATE PROPERTIES ---
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // कनेक्शन स्टेटस को स्ट्रीम करने के लिए (Observer Pattern)
  final StreamController<bool> _connectionStatusController = StreamController.broadcast();

  // Singleton Pattern: सुनिश्चित करता है कि केवल एक ही उदाहरण (instance) हो
  static final EspConnection _instance = EspConnection._internal();

  factory EspConnection() {
    return _instance;
  }

  // Private Constructor
  EspConnection._internal() {
    // WebSocket URL को initialize करें
    _wsUrl = 'ws://$_espIpAddress:$_espPort';
  }

  // --- PUBLIC GETTERS ---
  bool get isConnected => _isConnected;

  // UI को कनेक्शन स्टेटस सुनने के लिए Stream
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  // --- CONNECTION MANAGEMENT ---

  /// ESP32 से WebSocket कनेक्शन स्थापित करता है
  void connect() {
    if (_isConnected) {
      print("WebSocket already connected.");
      return;
    }

    try {
      print("Attempting to connect to $_wsUrl...");

      // WebSocketChannel को URL के साथ कनेक्ट करें
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Connection Status सुनें
      _channel!.stream.listen(
            (data) {
          // डेटा प्राप्त होने पर
          print("WS Received: $data");

          // यदि यह पहली बार कनेक्शन सफल होता है, तो स्टेटस अपडेट करें
          if (!_isConnected) {
            _isConnected = true;
            _connectionStatusController.add(true);
            print("WebSocket Connected Successfully.");
          }
        },
        onError: (error) {
          // Error होने पर
          print("WS Error: $error");
          _handleDisconnection();
        },
        onDone: () {
          // कनेक्शन बंद होने पर
          print("WS Disconnected.");
          _handleDisconnection();
        },
        cancelOnError: true,
      );

    } catch (e) {
      print("Could not connect to WebSocket: $e");
      _handleDisconnection();
    }
  }

  /// कनेक्शन बंद करता है
  void disconnect() {
    if (_isConnected) {
      _channel?.sink.close();
      _handleDisconnection();
    }
  }

  /// Disconnection को इंटरनली हैंडल करता है
  void _handleDisconnection() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStatusController.add(false);
    }
    _channel = null;
  }

  // --- COMMAND SENDING (Rover Control के लिए) ---

  /// ESP32 को टेक्स्ट कमांड भेजता है
  void sendCommand(String command) {
    if (_isConnected && _channel != null) {
      print("WS Sending Command: $command");
      _channel!.sink.add(command);
    } else {
      print("Cannot send command: WebSocket is not connected.");
    }
  }

  // --- CLEANUP ---
  void dispose() {
    _connectionStatusController.close();
    disconnect();
  }
}