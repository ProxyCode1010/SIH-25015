// FLASK API INTEGRATION
// यह फाइल Flask API से आने वाले JSON डेटा की संरचना (structure) को परिभाषित करती है।
// यह डेटा टाइप-सेफ़्टी (Type Safety) सुनिश्चित करता है।

// --- मॉडल 1: DailyTrend (लाइन चार्ट के लिए) ---
class DailyTrend {
  final String date; // उदाहरण: "Mon", "Tue", आदि
  final int infectedCount;

  DailyTrend({required this.date, required this.infectedCount});

  // Flask JSON से Dart ऑब्जेक्ट में बदलने का तरीका
  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    return DailyTrend(
      date: json['date'] as String,
      // सुनिश्चित करें कि यह null न हो और integer में बदल जाए
      infectedCount: json['infected_count'] is int
          ? json['infected_count']
          : int.tryParse(json['infected_count'].toString()) ?? 0,
    );
  }
}

// --- मॉडल 2: StatusDistribution (पाई चार्ट के लिए) ---
class StatusDistribution {
  final String status; // 'Healthy' या 'Infected'
  final double percentage; // 0.0 से 100.0
  final int count;

  StatusDistribution({required this.status, required this.percentage, required this.count});

  // Flask JSON से Dart ऑब्जेक्ट में बदलने का तरीका
  factory StatusDistribution.fromJson(Map<String, dynamic> json) {
    return StatusDistribution(
      status: json['status'] as String,
      // सुनिश्चित करें कि यह double हो
      percentage: (json['percentage'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}


// --- मॉडल 3: AnalyticsData (संपूर्ण डैशबोर्ड डेटा के लिए) ---
class AnalyticsData {
  // KPI Metrics
  final int totalPlantsScanned;
  final double infectedPercentage; // उदाहरण: 12.0
  final double pesticideUsedMl; // उदाहरण: 450.5

  // Chart Data
  final List<DailyTrend> dailyTrends;
  final List<StatusDistribution> statusDistribution;

  AnalyticsData({
    required this.totalPlantsScanned,
    required this.infectedPercentage,
    required this.pesticideUsedMl,
    required this.dailyTrends,
    required this.statusDistribution,
  });

  // Flask JSON (जो एक बड़ा ऑब्जेक्ट होगा) से Dart ऑब्जेक्ट में बदलने का तरीका
  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    // DailyTrend लिस्ट को पार्स करें
    List<DailyTrend> trends = (json['daily_trends'] as List)
        .map((i) => DailyTrend.fromJson(i))
        .toList();

    // StatusDistribution लिस्ट को पार्स करें
    List<StatusDistribution> distribution = (json['status_distribution'] as List)
        .map((i) => StatusDistribution.fromJson(i))
        .toList();

    return AnalyticsData(
      totalPlantsScanned: json['total_plants'] as int,
      infectedPercentage: (json['infected_percentage'] as num).toDouble(),
      pesticideUsedMl: (json['pesticide_used_ml'] as num).toDouble(),
      dailyTrends: trends,
      statusDistribution: distribution,
    );
  }
}