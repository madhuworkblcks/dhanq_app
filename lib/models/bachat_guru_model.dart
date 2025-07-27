import 'package:flutter/material.dart';

class SavingsSummaryModel {
  final double totalSavings;
  final int progress;
  final int goal;
  final String status;
  final int streakCount;

  SavingsSummaryModel({
    required this.totalSavings,
    required this.progress,
    required this.goal,
    required this.status,
    required this.streakCount,
  });

  String get formattedSavings => '₹${totalSavings.toStringAsFixed(0)}';
  double get progressPercent => goal > 0 ? progress / goal : 0.0;
}

class SavingsTipModel {
  final String title;
  final String description;
  final Color color;

  SavingsTipModel({
    required this.title,
    required this.description,
    required this.color,
  });
}

class SavingsOptionModel {
  final String name;
  final String minAmount;
  final String returns;
  final String period;
  final IconData icon;
  final Color color;

  SavingsOptionModel({
    required this.name,
    required this.minAmount,
    required this.returns,
    required this.period,
    required this.icon,
    required this.color,
  });
}

class CommunityChallengeModel {
  final String title;
  final String description;
  final double targetAmount;
  final double savedAmount;
  final int months;
  final IconData icon;
  final Color color;

  CommunityChallengeModel({
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.savedAmount,
    required this.months,
    required this.icon,
    required this.color,
  });

  double get progressPercent =>
      targetAmount > 0 ? savedAmount / targetAmount : 0.0;
  String get formattedTarget => '₹${targetAmount.toStringAsFixed(0)}';
}

class AchievementModel {
  final String title;
  final IconData icon;
  final Color color;

  AchievementModel({
    required this.title,
    required this.icon,
    required this.color,
  });
}

enum LanguageType { english, hindi }
