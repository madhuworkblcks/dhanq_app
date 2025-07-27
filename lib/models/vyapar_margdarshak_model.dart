import 'package:flutter/material.dart';

class BusinessSummaryModel {
  final double sales;
  final double expenses;
  final double profit;
  final DateTime date;

  BusinessSummaryModel({
    required this.sales,
    required this.expenses,
    required this.profit,
    required this.date,
  });

  String get formattedSales => '₹${sales.toStringAsFixed(0)}';
  String get formattedExpenses => '₹${expenses.toStringAsFixed(0)}';
  String get formattedProfit => '₹${profit.toStringAsFixed(0)}';
}

class MonthlyProfitModel {
  final List<ProfitDataModel> profitData;
  final double totalProfit;

  MonthlyProfitModel({
    required this.profitData,
    required this.totalProfit,
  });

  String get formattedTotalProfit => '₹${totalProfit.toStringAsFixed(0)}';
}

class ProfitDataModel {
  final String month;
  final double profit;
  final bool isCurrentMonth;

  ProfitDataModel({
    required this.month,
    required this.profit,
    this.isCurrentMonth = false,
  });

  String get formattedProfit => '₹${profit.toStringAsFixed(0)}';
  double get heightPercentage => (profit / 5000) * 100; // Assuming max profit is 5000
}

class QuickActionModel {
  final String title;
  final IconData icon;
  final String action;

  QuickActionModel({
    required this.title,
    required this.icon,
    required this.action,
  });
}

class BusinessGrowthModel {
  final List<GrowthMetricModel> metrics;

  BusinessGrowthModel({
    required this.metrics,
  });
}

class GrowthMetricModel {
  final String title;
  final double percentage;
  final String comparison;
  final IconData icon;

  GrowthMetricModel({
    required this.title,
    required this.percentage,
    required this.comparison,
    required this.icon,
  });

  String get formattedPercentage {
    final sign = percentage >= 0 ? '+' : '';
    return '${sign}${percentage.toStringAsFixed(0)}%';
  }

  Color get percentageColor {
    if (title.toLowerCase() == 'expenses') {
      return percentage <= 0 ? Colors.green : Colors.red;
    }
    return percentage >= 0 ? Colors.green : Colors.red;
  }
}

class LoanOfferModel {
  final String title;
  final String description;
  final double maxAmount;
  final String eligibility;

  LoanOfferModel({
    required this.title,
    required this.description,
    required this.maxAmount,
    required this.eligibility,
  });

  String get formattedMaxAmount => '₹${(maxAmount / 1000).toStringAsFixed(0)}L';
}

enum BusinessTab {
  businessHealth,
  financeOptions,
  inventory,
}

class VyaparMargdarshakModel {
  final BusinessSummaryModel todaySummary;
  final MonthlyProfitModel monthlyProfit;
  final List<QuickActionModel> quickActions;
  final BusinessGrowthModel businessGrowth;
  final LoanOfferModel loanOffer;
  final BusinessTab selectedTab;

  VyaparMargdarshakModel({
    required this.todaySummary,
    required this.monthlyProfit,
    required this.quickActions,
    required this.businessGrowth,
    required this.loanOffer,
    this.selectedTab = BusinessTab.businessHealth,
  });
}

enum LanguageType {
  english,
  hindi,
} 