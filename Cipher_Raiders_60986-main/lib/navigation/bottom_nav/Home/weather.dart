import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Vrikshanova App Color Palette
const Color kDarkGreen = Color(0xFF1E5128);
const Color kMediumGreen = Color(0xFF2D6A3F);
const Color kSoftGreen = Color(0xFFF0F9F0);
const Color kLightGreenAccent = Color(0xFFa8d5ea);

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {

  // API Key Variable
  final String apiKey = "e7f55c6095be515c7667d81763a808fc";

  // State Variables
  String _cityName = 'Enter Location Below...';
  String _temperature = '--';
  String _weatherDescription = 'Weather data will appear here.';
  String _humidity = '--%';
  String _windSpeed = '-- m/s';
  bool _isLoading = false;

  // Controllers for Text Input
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Location Variables
  String _currentQuery = '';
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Full Screen Refresh Function
  void _refreshScreen() {
    setState(() {
      _cityName = 'Enter Location Below...';
      _temperature = '--';
      _weatherDescription = 'Weather data will appear here.';
      _humidity = '--%';
      _windSpeed = '-- m/s';
      _isLoading = false;
      _currentQuery = '';
      _latitude = null;
      _longitude = null;
      _cityController.clear();
      _countryController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screen refreshed!'),
        duration: Duration(seconds: 1),
        backgroundColor: kMediumGreen,
      ),
    );
  }

  // Helper function to get temperature status
  String _getTemperatureStatus() {
    if (_temperature == '--') return 'default';
    final temp = double.tryParse(_temperature);
    if (temp == null) return 'default';

    if (temp >= 30) return 'hot';
    if (temp <= 15) return 'cold';
    return 'moderate';
  }

  // Helper function to get humidity status
  String _getHumidityStatus() {
    if (_humidity == '--%') return 'default';
    final humidity = int.tryParse(_humidity);
    if (humidity == null) return 'default';

    if (humidity >= 70) return 'high';
    if (humidity <= 30) return 'low';
    return 'moderate';
  }

  // Helper function to get wind speed status
  String _getWindSpeedStatus() {
    if (_windSpeed == '-- m/s') return 'default';
    final windSpeed = double.tryParse(_windSpeed);
    if (windSpeed == null) return 'default';

    if (windSpeed >= 10) return 'strong';
    if (windSpeed <= 3) return 'calm';
    return 'moderate';
  }

  // Function to process input and trigger API call
  void _checkWeatherByLocality() {
    final cityText = _cityController.text.trim();
    final countryText = _countryController.text.trim();

    if (cityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a City or Locality name.')),
      );
      return;
    }

    _currentQuery = cityText;
    if (countryText.isNotEmpty) {
      _currentQuery += ',$countryText';
    }

    setState(() {});
    _fetchWeather();
  }

  // OpenWeatherMap API Call function
  void _fetchWeather() async {
    if (apiKey.isEmpty || apiKey == "YOUR_OPENWEATHERMAP_API_KEY_HERE" || _currentQuery.isEmpty) {
      setState(() {
        _weatherDescription = 'Please set location and use a valid API Key.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _weatherDescription = 'Fetching weather for $_currentQuery...';
      _cityName = _currentQuery;
      _temperature = '--';
      _humidity = '--%';
      _windSpeed = '-- m/s';
    });

    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$_currentQuery&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _cityName = data['name'] ?? 'Unknown Location';
          _temperature = data['main']['temp'].toStringAsFixed(1);
          _weatherDescription = data['weather'][0]['description'] ?? 'No description';
          _humidity = data['main']['humidity']?.toString() ?? '--';
          _windSpeed = data['wind']['speed']?.toStringAsFixed(1) ?? '--';
          _latitude = data['coord']['lat'];
          _longitude = data['coord']['lon'];
          _isLoading = false;
        });

      } else {
        setState(() {
          _weatherDescription = 'Error: Location not found or API key issue (Code: ${response.statusCode})';
          _cityName = 'Error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weatherDescription = 'Network Error: $e';
        _cityName = 'Error';
        _isLoading = false;
      });
    }
  }

  // Custom AppBar Widget
  Widget _buildCustomAppBar(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.transparent,
      height: 80.0 + statusBarHeight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Card(
            elevation: 6,
            color: kDarkGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashColor: Colors.white24,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Field Weather Check',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh Screen',
                  onPressed: _isLoading ? null : _refreshScreen,
                  splashColor: Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftGreen,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: _buildCustomAppBar(context),
      ),

      // Body Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Location Display Card (WITHOUT Choose Location Button)
            _buildLocationDisplayCard(),

            const SizedBox(height: 20),

            // 2. Main Weather Display (Temperature and Description)
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: kMediumGreen))
                : _buildMainWeatherCard(),

            const SizedBox(height: 20),

            // 3. Humidity and Details Row
            _buildDetailsRow(),

            const SizedBox(height: 30),

            // 4. City Input
            _buildInputField('City / Locality', _cityController, TextInputType.text),
            const SizedBox(height: 10),

            // Country Code Input
            _buildInputField('Country Code (Optional, e.g., IN, US)', _countryController, TextInputType.text),
            const SizedBox(height: 15),

            // Check Weather Button
            ElevatedButton(
              onPressed: _isLoading ? null : _checkWeatherByLocality,
              style: ElevatedButton.styleFrom(
                backgroundColor: kMediumGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Check Weather',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Location Display Card (REMOVED Choose Location Button)
  Widget _buildLocationDisplayCard() {
    final locationText = (_latitude != null && _longitude != null)
        ? 'Lat: ${_latitude?.toStringAsFixed(2)}, Lon: ${_longitude?.toStringAsFixed(2)}'
        : _currentQuery.isNotEmpty ? 'Searching for: $_currentQuery' : 'Awaiting input...';

    return Card(
      color: kMediumGreen,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_pin, size: 30, color: Colors.white),
            const SizedBox(width: 15),

            // Location Text Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _cityName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    locationText,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main Temperature Card with Dynamic Colors
  Widget _buildMainWeatherCard() {
    final tempStatus = _getTemperatureStatus();
    Color iconColor;
    IconData weatherIcon;

    switch (tempStatus) {
      case 'hot':
        iconColor = Colors.orange.shade700;
        weatherIcon = Icons.wb_sunny;
        break;
      case 'cold':
        iconColor = Colors.blue.shade700;
        weatherIcon = Icons.ac_unit;
        break;
      default:
        iconColor = kDarkGreen;
        weatherIcon = Icons.wb_sunny_sharp;
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Icon(weatherIcon, size: 80, color: iconColor),
            const SizedBox(height: 15),
            Text(
              '$_temperature °C',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w800,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _weatherDescription,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Details Row (Humidity and Wind)
  Widget _buildDetailsRow() {
    return Row(
      children: [
        Expanded(child: _buildDetailCard('Humidity', '$_humidity%', Icons.water_drop, _getHumidityStatus())),
        const SizedBox(width: 15),
        Expanded(child: _buildDetailCard('Wind Speed', '$_windSpeed m/s', Icons.air, _getWindSpeedStatus())),
      ],
    );
  }

  // Helper Widget for Detail Cards with Dynamic Colors
  Widget _buildDetailCard(String title, String value, IconData icon, String status) {
    Color cardColor;
    Color iconColor;

    // For Humidity
    if (title == 'Humidity') {
      switch (status) {
        case 'high':
          cardColor = Colors.blue.shade100;
          iconColor = Colors.blue.shade700;
          break;
        case 'low':
          cardColor = Colors.orange.shade100;
          iconColor = Colors.orange.shade700;
          break;
        default:
          cardColor = kLightGreenAccent;
          iconColor = kDarkGreen;
      }
    }
    // For Wind Speed
    else {
      switch (status) {
        case 'strong':
          cardColor = Colors.purple.shade100;
          iconColor = Colors.purple.shade700;
          break;
        case 'calm':
          cardColor = Colors.green.shade100;
          iconColor = Colors.green.shade700;
          break;
        default:
          cardColor = kLightGreenAccent;
          iconColor = kDarkGreen;
      }
    }

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: iconColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Text Input Fields
  Widget _buildInputField(String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kMediumGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kMediumGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kMediumGreen.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kMediumGreen, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      style: const TextStyle(color: kDarkGreen),
    );
  }
}