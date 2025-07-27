import 'package:flutter/material.dart';

class TaxHealthScoreModel {
  final int score;
  final int maxScore;
  final String status;
  final Color statusColor;
  final String description;
  final List<QuickImprovementModel> quickImprovements;

  TaxHealthScoreModel({
    required this.score,
    required this.maxScore,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.quickImprovements,
  });

  String get formattedScore => '$score /$maxScore';
  double get scorePercentage => (score / maxScore) * 100;
}

class QuickImprovementModel {
  final String title;
  final bool isCompleted;

  QuickImprovementModel({
    required this.title,
    required this.isCompleted,
  });
}

class TaxLiabilityForecastModel {
  final List<QuarterlyTaxModel> quarterlyTaxes;
  final List<double> chartData;

  TaxLiabilityForecastModel({
    required this.quarterlyTaxes,
    required this.chartData,
  });
}

class QuarterlyTaxModel {
  final String quarter;
  final DateTime dueDate;
  final double amount;
  final double? percentageChange;
  final bool isDecrease;

  QuarterlyTaxModel({
    required this.quarter,
    required this.dueDate,
    required this.amount,
    this.percentageChange,
    required this.isDecrease,
  });

  String get formattedAmount => '\$${amount.toStringAsFixed(0)}';
  String get formattedDueDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }
  String get formattedChange {
    if (percentageChange == null) return '';
    final change = isDecrease ? '↓' : '↑';
    return '$change${percentageChange!.toStringAsFixed(0)}%';
  }
}

class PersonalizedDeductionModel {
  final String title;
  final String description;
  final double estimatedValue;
  final String status;
  final Color statusColor;
  final String actionText;
  final Color actionColor;
  final IconData icon;

  PersonalizedDeductionModel({
    required this.title,
    required this.description,
    required this.estimatedValue,
    required this.status,
    required this.statusColor,
    required this.actionText,
    required this.actionColor,
    required this.icon,
  });

  String get formattedValue => '\$${estimatedValue.toStringAsFixed(0)}';
} 