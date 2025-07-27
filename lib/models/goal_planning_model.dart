import 'package:flutter/material.dart';

enum GoalType { retirement, education, travel, home }

class GoalPlanningModel {
  final FinancialHealthSummary financialHealth;
  final List<GoalOverview> goalsOverview;
  final List<GoalDetail> goalDetails;
  final List<Recommendation> recommendations;

  GoalPlanningModel({
    required this.financialHealth,
    required this.goalsOverview,
    required this.goalDetails,
    required this.recommendations,
  });
}

class FinancialHealthSummary {
  final String status;
  final int totalGoals;
  final double monthlyContribution;
  final double completionPercentage;

  FinancialHealthSummary({
    required this.status,
    required this.totalGoals,
    required this.monthlyContribution,
    required this.completionPercentage,
  });
}

class GoalOverview {
  final String id;
  final String name;
  final IconData icon;
  final double progress;
  final double target;
  final Color color;

  GoalOverview({
    required this.id,
    required this.name,
    required this.icon,
    required this.progress,
    required this.target,
    required this.color,
  });
}

class GoalDetail {
  final String id;
  final String name;
  final double currentSavings;
  final double monthlyContribution;
  final int targetDate;
  final double probabilityOfSuccess;
  final List<ProjectedGrowthPoint> projectedGrowth;

  GoalDetail({
    required this.id,
    required this.name,
    required this.currentSavings,
    required this.monthlyContribution,
    required this.targetDate,
    required this.probabilityOfSuccess,
    required this.projectedGrowth,
  });
}

class ProjectedGrowthPoint {
  final int year;
  final double conservative;
  final double expected;
  final double optimistic;

  ProjectedGrowthPoint({
    required this.year,
    required this.conservative,
    required this.expected,
    required this.optimistic,
  });
}

class Recommendation {
  final String id;
  final String description;
  final double improvementPercentage;

  Recommendation({
    required this.id,
    required this.description,
    required this.improvementPercentage,
  });
} 