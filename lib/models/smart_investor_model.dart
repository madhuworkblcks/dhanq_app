import 'package:flutter/material.dart';

import 'asset_model.dart';
import 'portfolio_model.dart';

class SmartInvestorModel {
  final PortfolioModel portfolio;
  final Map<String, double> allocation;
  final List<AssetModel> assets;
  final MarketSentimentModel marketSentiment;
  final InterestRateImpactModel interestRateImpact;
  final List<RecommendationModel> recommendations;
  final PerformanceModel performance;
  final List<InsightModel> insights;

  SmartInvestorModel({
    required this.portfolio,
    required this.allocation,
    required this.assets,
    required this.marketSentiment,
    required this.interestRateImpact,
    required this.recommendations,
    required this.performance,
    required this.insights,
  });

  factory SmartInvestorModel.fromJson(Map<String, dynamic> json) {
    // Convert all values in allocation to double, even if they are int
    final rawAllocation = json['allocation'] as Map<String, dynamic>;
    final allocation = rawAllocation.map(
      (key, value) =>
          MapEntry(key, (value is int) ? value.toDouble() : value as double),
    );
    return SmartInvestorModel(
      portfolio: PortfolioModel.fromJson(json['portfolio']),
      allocation: allocation,
      assets:
          (json['assets'] as List)
              .map((asset) => AssetModel.fromJson(asset))
              .toList(),
      marketSentiment: MarketSentimentModel.fromJson(json['marketSentiment']),
      interestRateImpact: InterestRateImpactModel.fromJson(
        json['interestRateImpact'],
      ),
      recommendations:
          (json['recommendations'] as List)
              .map((rec) => RecommendationModel.fromJson(rec))
              .toList(),
      performance: PerformanceModel.fromJson(json['performance']),
      insights:
          (json['insights'] as List)
              .map((insight) => InsightModel.fromJson(insight))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolio': portfolio.toJson(),
      'allocation': allocation,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'marketSentiment': marketSentiment.toJson(),
      'interestRateImpact': interestRateImpact.toJson(),
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'performance': performance.toJson(),
      'insights': insights.map((insight) => insight.toJson()).toList(),
    };
  }
}

// Legacy model for backward compatibility
class PortfolioAllocationModel {
  final double equity;
  final double debt;
  final double gold;
  final double cash;

  PortfolioAllocationModel({
    required this.equity,
    required this.debt,
    required this.gold,
    required this.cash,
  });

  List<AllocationItem> get allocationItems => [
    AllocationItem(
      name: 'Equity',
      percentage: equity,
      color: const Color(0xFF1E3A8A),
    ),
    AllocationItem(
      name: 'Debt',
      percentage: debt,
      color: const Color(0xFFFFD700),
    ),
    AllocationItem(
      name: 'Gold',
      percentage: gold,
      color: const Color(0xFFFFB6C1),
    ),
    AllocationItem(
      name: 'Cash',
      percentage: cash,
      color: const Color(0xFFDEB887),
    ),
  ];
}

class AllocationItem {
  final String name;
  final double percentage;
  final Color color;

  AllocationItem({
    required this.name,
    required this.percentage,
    required this.color,
  });

  String get formattedPercentage => '${percentage.toStringAsFixed(0)}%';
}

class MarketSentimentModel {
  final String overallSentiment;
  final int confidence;
  final List<SentimentFactor> factors;

  MarketSentimentModel({
    required this.overallSentiment,
    required this.confidence,
    required this.factors,
  });

  factory MarketSentimentModel.fromJson(Map<String, dynamic> json) {
    return MarketSentimentModel(
      overallSentiment: json['overallSentiment'],
      confidence: json['confidence'],
      factors:
          (json['factors'] as List)
              .map((factor) => SentimentFactor.fromJson(factor))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallSentiment': overallSentiment,
      'confidence': confidence,
      'factors': factors.map((factor) => factor.toJson()).toList(),
    };
  }

  // Getters for backward compatibility
  String get title => 'Market Sentiment Analysis';
  String get description =>
      'Overall sentiment: $overallSentiment with $confidence% confidence';
  String get actionText => 'Learn More';
  String? get timeframe => 'Current Market';
  List<double>? get chartData => [
    65,
    70,
    75,
    80,
    75,
    70,
  ]; // Sample confidence trend
  Color get accentColor => const Color(0xFF1E3A8A); // Default blue accent color
}

class SentimentFactor {
  final String factor;
  final String impact;
  final String description;

  SentimentFactor({
    required this.factor,
    required this.impact,
    required this.description,
  });

  factory SentimentFactor.fromJson(Map<String, dynamic> json) {
    return SentimentFactor(
      factor: json['factor'],
      impact: json['impact'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'factor': factor, 'impact': impact, 'description': description};
  }
}

class InterestRateImpactModel {
  final double currentRate;
  final double projectedRate;
  final String impactOnPortfolio;
  final double estimatedGain;
  final String reasoning;

  InterestRateImpactModel({
    required this.currentRate,
    required this.projectedRate,
    required this.impactOnPortfolio,
    required this.estimatedGain,
    required this.reasoning,
  });

  factory InterestRateImpactModel.fromJson(Map<String, dynamic> json) {
    return InterestRateImpactModel(
      currentRate: json['currentRate'].toDouble(),
      projectedRate: json['projectedRate'].toDouble(),
      impactOnPortfolio: json['impactOnPortfolio'],
      estimatedGain: json['estimatedGain'].toDouble(),
      reasoning: json['reasoning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentRate': currentRate,
      'projectedRate': projectedRate,
      'impactOnPortfolio': impactOnPortfolio,
      'estimatedGain': estimatedGain,
      'reasoning': reasoning,
    };
  }

  // Getter for backward compatibility
  String get description => reasoning;

  // Getter for chart data (sample data for backward compatibility)
  List<double> get chartData => [20, 25, 30, 35, 40, 45];

  // Getter for title (for backward compatibility)
  String get title => 'Interest Rate Impact';

  // Getter for timeframe (for backward compatibility)
  String get timeframe => 'Last 6 months';

  // Getter for action text (for backward compatibility)
  String get actionText => 'Learn More';
}

class RecommendationModel {
  final String id;
  final String title;
  final String description;
  final String action;
  final String priority;
  final double estimatedBenefit;

  RecommendationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
    required this.estimatedBenefit,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      action: json['action'],
      priority: json['priority'],
      estimatedBenefit: json['estimatedBenefit'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'action': action,
      'priority': priority,
      'estimatedBenefit': estimatedBenefit,
    };
  }

  String get formattedBenefit => '₹${_formatNumber(estimatedBenefit)}';
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Legacy models for backward compatibility
class ActionableInsightModel {
  final String id;
  final String title;
  final String description;
  final String actionText;
  final Color accentColor;

  ActionableInsightModel({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    this.accentColor = const Color(0xFF1E3A8A),
  });
}

class MarketSentimentModelLegacy {
  final String id;
  final String title;
  final String description;
  final String actionText;
  final String? timeframe;
  final List<double>? chartData;
  final Color accentColor;

  MarketSentimentModelLegacy({
    required this.id,
    required this.title,
    required this.description,
    required this.actionText,
    this.timeframe,
    this.chartData,
    this.accentColor = const Color(0xFF1E3A8A),
  });
}

class InterestRateImpactModelLegacy {
  final String title;
  final String timeframe;
  final List<double> chartData;
  final String description;
  final String actionText;

  InterestRateImpactModelLegacy({
    required this.title,
    required this.timeframe,
    required this.chartData,
    required this.description,
    required this.actionText,
  });
}

String _formatNumber(double number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else {
    return number.toStringAsFixed(0);
  }
}
