import 'package:flutter/material.dart';

enum LanguageType { english, hindi }

class FinancialHealthScoreModel {
  final int score;
  final int maxScore;
  final String status;
  final Color statusColor;
  final String description;

  FinancialHealthScoreModel({
    required this.score,
    required this.maxScore,
    required this.status,
    required this.statusColor,
    required this.description,
  });

  String get formattedScore => '$score';
  String get formattedMaxScore => '/$maxScore';
  double get scorePercentage => (score / maxScore) * 100;
}

class KeyMetricModel {
  final String label;
  final String value;
  final String? trend;
  final bool isPositiveTrend;
  final IconData icon;
  final String? status;

  KeyMetricModel({
    required this.label,
    required this.value,
    this.trend,
    required this.isPositiveTrend,
    required this.icon,
    this.status,
  });

  Color get trendColor => isPositiveTrend ? Colors.green : Colors.red;
  String get trendIcon => isPositiveTrend ? '↑' : '↓';
}

class ScoreBreakdownModel {
  final String category;
  final double percentage;
  final Color color;

  ScoreBreakdownModel({
    required this.category,
    required this.percentage,
    required this.color,
  });

  String get formattedPercentage => '${percentage.toStringAsFixed(0)}%';
}

class FinancialInsightModel {
  final String text;
  final IconData icon;
  final Color iconColor;

  FinancialInsightModel({
    required this.text,
    required this.icon,
    required this.iconColor,
  });
}

class MonthlyTrendModel {
  final List<double> data;
  final List<String> labels;

  MonthlyTrendModel({
    required this.data,
    required this.labels,
  });
} 