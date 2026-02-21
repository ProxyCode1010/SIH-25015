// PIE CHART
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/analytics_model.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/analytics_service.dart';


// Vrikshanova Color Theme Definitions
const Color darkGreen = Color(0xFF1e5128);
const Color lightGreenAccent = Color(0xFFa8d5aa);
const Color softGreenBackground = Color(0xFFf0f9f0);

class StatusPieChart extends StatelessWidget {
  const StatusPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // AnalyticsService से डमी डेटा Fetch करें
    return FutureBuilder<AnalyticsData>(
      future: AnalyticsService().fetchDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildChartContainer(const Center(child: CircularProgressIndicator(color: darkGreen)));
        }
        if (snapshot.hasError) {
          return _buildChartContainer(Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))));
        }
        if (!snapshot.hasData || snapshot.data!.statusDistribution.isEmpty) {
          return _buildChartContainer(const Center(child: Text('No status data available.')));
        }

        final distribution = snapshot.data!.statusDistribution;
        return _buildChartContainer(
          PieChart(
            PieChartData(
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: distribution.map((item) {
                // Infected पौधों को लाल (या आपकी थीम का गहरा रंग) दिखाएँ
                final isTouched = item.status == 'Infected';
                final color = item.status == 'Infected' ? darkGreen : lightGreenAccent;

                return PieChartSectionData(
                  color: color,
                  value: item.percentage,
                  title: '${item.percentage.toStringAsFixed(1)}%',
                  radius: isTouched ? 65 : 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Chart Container को re-use करने के लिए helper function
  Widget _buildChartContainer(Widget child) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // गोल किनारे
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: child,
    );
  }
}