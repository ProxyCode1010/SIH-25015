import 'package:flutter/material.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/daily_trend_chart.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/kpi_card.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/status_pie_chart.dart';
import 'package:vrikshanova/navigation/custom_navscreen.dart';

// --- Vrikshanova Color Theme Definitions ---
const Color darkGreen = Color(0xFF1e5128); // Primary
const Color lightGreenAccent = Color(0xFFa8d5aa); // Accent
const Color softGreenBackground = Color(0xFFf0f9f0); // Background
const Color veryDarkGreen = Color(0xFF0d3b1f);
const Color mediumGreen = Color(0xFF2d6a4f);
const Color cardColor = Color(0xFF2E5339); // Custom AppBar Card Color

class AnalyzePlant extends StatefulWidget {
  const AnalyzePlant({super.key});

  @override
  State<AnalyzePlant> createState() => _AnalyzePlantState();
}

class _AnalyzePlantState extends State<AnalyzePlant> {
  int _currentIndex = 2;

  // --- Custom AppBar Widget ---
  Widget _buildCustomAppBar() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: 80.0 + statusBarHeight,
      color: Colors.transparent,

      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Card(
            elevation: 6,
            color: cardColor, // Dark Greenish Color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                // Back Button (जैसा कि DiseaseCheck screen में था)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    // NOTE: Bottom Navigation screens पर back button अक्सर
                    // Navigation error या app close कर सकता है।
                    // इसे केवल तभी इस्तेमाल करें जब यह screen किसी और screen से PUSH हुई हो।
                    Navigator.pop(context);
                  },
                  splashColor: Colors.white24,
                ),

                // Title: Analytics Dashboard
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      'Analytics Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Actions: Setting/More Icon (Optional, Placeholder)
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                  onPressed: () { /* Settings action */ },
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

      // IMPORTANT CHANGE: Custom AppBar Integration
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: _buildCustomAppBar(),
      ),

      body: Container(
        color: softGreenBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // **Dashboard Content**
              _buildDashboardContent(context),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: CustomNavscreen(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        screenContext: context,
      ),
    );
  }

  // डैशबोर्ड के सभी कॉम्पोनेंट यहाँ बनाए गए हैं
  Widget _buildDashboardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. KPI Cards ---
        const Text(
          'Key Metrics',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: veryDarkGreen),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              // KpiCard का उपयोग (mediumGreen background)
              child: KpiCard(
                title: 'Infected Plants',
                value: '12%',
                color: mediumGreen,
                icon: Icons.bug_report,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // KpiCard का उपयोग (lightGreenAccent background)
              child: KpiCard(
                title: 'Pesticide Used',
                value: '450 ml',
                color: lightGreenAccent,
                icon: Icons.science,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 2. Status Distribution (Pie Chart) ---
        const Text(
          'Plant Status Distribution',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: veryDarkGreen),
        ),
        const SizedBox(height: 12),
        // Pie Chart Widget (External File)
        const StatusPieChart(),

        const SizedBox(height: 24),

        // --- 3. Trend Analysis (Line Chart) ---
        const Text(
          'Infection Trend (Last 7 Days)',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: veryDarkGreen),

        ),
        const SizedBox(height: 12),
        // Line Chart Widget (External File)
        const DailyTrendChart(),
      ],
    );
  }
}