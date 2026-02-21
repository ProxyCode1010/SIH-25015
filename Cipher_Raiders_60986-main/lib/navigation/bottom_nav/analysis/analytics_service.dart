// HTTP GET REQUEST BHEJNE K LIYE OR JSON DATA KO DART MEIN BADALNE K LIYE

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/analytics_model.dart'; // डमी डेटा के लिए

// import 'package:http/http.dart' as http; // असली API कॉल के लिए

// Service क्लास जो Flask API से डेटा Fetch करेगी
class AnalyticsService {
  // यहाँ पर आपके Flask Server का URL आएगा
  static const String _apiBaseUrl = 'http://<FLASK_SERVER_IP>:5000/api';

  // एक फंक्शन जो डमी डेटा जनरेट करता है
  Future<AnalyticsData> _fetchDummyData() async {
    // डमी डेटा जो Flask JSON की तरह दिखता है
    final Map<String, dynamic> dummyJson = {
      "total_plants": 2500,
      "infected_percentage": 12.5,
      "pesticide_used_ml": 450.8,
      "daily_trends": [
        {"date": "Mon", "infected_count": 5},
        {"date": "Tue", "infected_count": 8},
        {"date": "Wed", "infected_count": 12},
        {"date": "Thu", "infected_count": 15},
        {"date": "Fri", "infected_count": 10},
        {"date": "Sat", "infected_count": 18},
        {"date": "Sun", "infected_count": 22},
      ],
      "status_distribution": [
        {"status": "Infected", "percentage": 12.5, "count": 313},
        {"status": "Healthy", "percentage": 87.5, "count": 2187},
      ]
    };

    // 2 सेकंड का विलंब (delay) ताकि हम FutureBuilder में लोडिंग देख सकें
    await Future.delayed(const Duration(seconds: 2));

    return AnalyticsData.fromJson(dummyJson);
  }

  // मुख्य डेटा Fetch करने वाला फंक्शन
  Future<AnalyticsData> fetchDashboardData() async {
    // TODO: Real API Call - कल आप इस सेक्शन को अनकमेंट करके उपयोग कर सकते हैं

    // try {
    //   final response = await http.get(Uri.parse('$_apiBaseUrl/dashboard_data'));

    //   if (response.statusCode == 200) {
    //     // JSON स्ट्रिंग को Dart Map में बदलें
    //     final Map<String, dynamic> jsonResponse = json.decode(response.body);
    //     return AnalyticsData.fromJson(jsonResponse);
    //   } else {
    //     throw Exception('Failed to load dashboard data: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   // नेटवर्क एरर की स्थिति में, डमी डेटा दिखाएँ
    //   print('API Error: $e. Falling back to dummy data.');
    //   return _fetchDummyData();
    // }

    // डमी डेटा (आज के लिए)
    return _fetchDummyData();
  }
}