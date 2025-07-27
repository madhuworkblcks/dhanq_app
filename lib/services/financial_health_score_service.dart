import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/financial_health_score_model.dart';

class FinancialHealthScoreService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load financial health score data from JSON file
  Future<Map<String, dynamic>> _loadFinancialHealthScoreData() async {
    try {
      // Load JSON from http URL https://dhanqserv-43683479109.us-central1.run.app/api/health-score/12345
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/health-score/12345',
        ),
      );
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load financial health score data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'financialHealthScore': {
        'score': 87,
        'maxScore': 100,
        'status': 'Good',
        'statusColor': {
          'value': 4280391411,
          'alpha': 255,
          'red': 34,
          'green': 197,
          'blue': 94,
          'opacity': 1.0,
        },
        'description':
            "Your financial health is on the right track, with some opportunities for improvement.",
      },
    };
  }

  // Helper method to convert JSON color to Flutter Color
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  // Helper method to convert JSON icon to Flutter IconData
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  Future<FinancialHealthScoreModel> getFinancialHealthScore() async {
    await _simulateDelay();

    final jsonData = await _loadFinancialHealthScoreData();
    final healthScoreData =
        jsonData['financialHealthScore'] as Map<String, dynamic>;

    return FinancialHealthScoreModel(
      score: healthScoreData['score'] as int,
      maxScore: healthScoreData['maxScore'] as int,
      status: healthScoreData['status'] as String,
      statusColor: _parseColor(
        healthScoreData['statusColor'] as Map<String, dynamic>,
      ),
      description: healthScoreData['description'] as String,
    );
  }

  Future<List<KeyMetricModel>> getKeyMetrics() async {
    await _simulateDelay();

    final jsonData = await _loadFinancialHealthScoreData();
    final keyMetricsData = jsonData['keyMetrics'] as List;

    return keyMetricsData
        .map(
          (metric) => KeyMetricModel(
            label: metric['label'] as String,
            value: metric['value'] as String,
            trend: metric['trend'] as String?,
            isPositiveTrend: metric['isPositiveTrend'] as bool,
            icon: _parseIcon(metric['icon'] as Map<String, dynamic>),
            status: metric['status'] as String?,
          ),
        )
        .toList();
  }

  Future<List<ScoreBreakdownModel>> getScoreBreakdown() async {
    await _simulateDelay();

    final jsonData = await _loadFinancialHealthScoreData();
    final breakdownData = jsonData['scoreBreakdown'] as List;

    return breakdownData
        .map(
          (breakdown) => ScoreBreakdownModel(
            category: breakdown['category'] as String,
            percentage: (breakdown['percentage'] as num).toDouble(),
            color: _parseColor(breakdown['color'] as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<List<FinancialInsightModel>> getFinancialInsights() async {
    await _simulateDelay();

    final jsonData = await _loadFinancialHealthScoreData();
    final insightsData = jsonData['financialInsights'] as List;

    return insightsData
        .map(
          (insight) => FinancialInsightModel(
            text: insight['text'] as String,
            icon: _parseIcon(insight['icon'] as Map<String, dynamic>),
            iconColor: _parseColor(
              insight['iconColor'] as Map<String, dynamic>,
            ),
          ),
        )
        .toList();
  }

  Future<MonthlyTrendModel> getMonthlyTrend() async {
    await _simulateDelay();

    final jsonData = await _loadFinancialHealthScoreData();
    final trendData = jsonData['monthlyTrend'] as Map<String, dynamic>;

    return MonthlyTrendModel(
      data:
          (trendData['data'] as List)
              .map((data) => (data as num).toDouble())
              .toList(),
      labels:
          (trendData['labels'] as List)
              .map((label) => label as String)
              .toList(),
    );
  }

  Future<void> applyFinancialOptimization() async {
    await _simulateDelay();
    // Simulate applying financial optimization
    print('Financial optimization applied successfully!');
  }

  Future<void> getDetailedInsight(String insightType) async {
    await _simulateDelay();
    // Simulate getting detailed insight
    print('Getting detailed insight for $insightType');
  }

  // Load all financial health score data at once
  Future<Map<String, dynamic>> getAllFinancialHealthScoreData() async {
    await _simulateDelay();
    return await _loadFinancialHealthScoreData();
  }
}
