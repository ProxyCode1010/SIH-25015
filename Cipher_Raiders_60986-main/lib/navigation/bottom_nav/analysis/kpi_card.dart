// INFECTED PLANTS , PESTICIDE USED ( KEY PERFORMANCE INDICATOR ==> TELLS ABOUT THR METRICS OF PESTICIDE SPRINKLING
import 'package:flutter/material.dart';

// Vrikshanova Color Theme Definitions (Theme consistency के लिए)
const Color darkGreen = Color(0xFF1e5128);
const Color lightGreenAccent = Color(0xFFa8d5aa);
const Color mediumGreen = Color(0xFF2d6a4f);

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const KpiCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 6, // थोड़ा गहरा shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // ज्यादा गोल किनारे
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28, // थोड़ा बड़ा फ़ॉन्ट
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}