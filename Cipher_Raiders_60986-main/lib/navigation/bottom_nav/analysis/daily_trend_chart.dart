// Line Chart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// imports को ठीक कर रहे हैं, जैसा कि आपने अपने query में उपयोग किया है:
import 'package:vrikshanova/navigation/bottom_nav/analysis/analytics_model.dart';
import 'package:vrikshanova/navigation/bottom_nav/analysis/analytics_service.dart';

// Vrikshanova Color Theme Definitions
const Color darkGreen = Color(0xFF1e5128);
const Color lightGreenAccent = Color(0xFFa8d5aa);
const Color veryDarkGreen = Color(0xFF0d3b1f);

class DailyTrendChart extends StatelessWidget {
  const DailyTrendChart({super.key});

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
        if (!snapshot.hasData || snapshot.data!.dailyTrends.isEmpty) {
          return _buildChartContainer(const Center(child: Text('No trend data available.')));
        }

        final trends = snapshot.data!.dailyTrends;
        return _buildChartContainer(
          Padding(
            padding: const EdgeInsets.only(right: 18.0, top: 10),
            child: LineChart(
              _buildLineChartData(trends),
              // त्रुटि 1 और 2 यहाँ से हटा दी गई हैं:
              // swapAnimationDuration: const Duration(milliseconds: 500),
              // swapAnimationCurve: Curves.easeIn,
            ),
          ),
        );
      },
    );
  }

  // LineChartData तैयार करने वाला फंक्शन
  LineChartData _buildLineChartData(List<DailyTrend> trends) {
    // डेटा को FlSpot में बदलें
    List<FlSpot> spots = trends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.infectedCount.toDouble());
    }).toList();

    // अधिकतम वैल्यू (y-axis limits के लिए)
    double maxY = trends.map((t) => t.infectedCount).reduce((a, b) => a > b ? a : b).toDouble() * 1.1;
    if (maxY == 0) maxY = 5; // अगर कोई संक्रमण नहीं है

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        // त्रुटि 3 यहाँ से हटा दी गई है:
        // getHorizontalId: (value) => 2.0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: veryDarkGreen.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // x-axis पर दिन (Mon, Tue, etc.) दिखाएँ
              if (value.toInt() < trends.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(trends[value.toInt()].date, style: const TextStyle(color: veryDarkGreen, fontSize: 10)),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            // interval को 1 के बजाय डायनामिक बनाएं ताकि y-axis साफ दिखे
            interval: (maxY / 4).ceilToDouble() == 0 ? 1 : (maxY / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              // y-axis पर संक्रमण गणना (Infected Count) दिखाएँ
              if (value > 0) {
                return Text(value.toInt().toString(), style: const TextStyle(color: veryDarkGreen, fontSize: 10));
              }
              return const Text('');
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: veryDarkGreen.withOpacity(0.2), width: 1),
      ),
      minX: 0,
      maxX: (trends.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: darkGreen, // Primary Color का उपयोग
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                darkGreen.withOpacity(0.3),
                darkGreen.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  // Chart Container को re-use करने के लिए helper function
  Widget _buildChartContainer(Widget child) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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