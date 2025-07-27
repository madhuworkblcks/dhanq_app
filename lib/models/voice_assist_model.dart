import 'package:flutter/material.dart';

enum LanguageType { english, hindi }

class VoiceAssistModel {
  final BudgetSummary budgetSummary;
  final List<ChatMessage> chatMessages;
  final WeeklySpendingSummary weeklySpending;
  final LanguageType selectedLanguage;

  VoiceAssistModel({
    required this.budgetSummary,
    required this.chatMessages,
    required this.weeklySpending,
    required this.selectedLanguage,
  });
}

class BudgetSummary {
  final String month;
  final double budget;
  final double spent;
  final double saved;
  final double progressPercent;

  BudgetSummary({
    required this.month,
    required this.budget,
    required this.spent,
    required this.saved,
  }) : progressPercent = spent / budget;

  String get formattedBudget => '₹${budget.toStringAsFixed(0)}';
  String get formattedSpent => '₹${spent.toStringAsFixed(0)}';
  String get formattedSaved => '₹${saved.toStringAsFixed(0)}';
  String get spentPercentage => '${(progressPercent * 100).toInt()}%';
  String get savedPercentage => '${((saved / budget) * 100).toInt()}%';
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? category;
  final IconData? categoryIcon;
  final double? amount;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.category,
    this.categoryIcon,
    this.amount,
  });
}

class WeeklySpendingSummary {
  final double totalSpent;
  final List<DailySpending> dailySpending;
  final String highestDay;
  final double highestAmount;
  final String mainCategory;

  WeeklySpendingSummary({
    required this.totalSpent,
    required this.dailySpending,
    required this.highestDay,
    required this.highestAmount,
    required this.mainCategory,
  });

  String get formattedTotalSpent => '₹${totalSpent.toStringAsFixed(0)}';
  String get formattedHighestAmount => '₹${highestAmount.toStringAsFixed(0)}';
}

class DailySpending {
  final String day;
  final double amount;
  final bool isHighest;

  DailySpending({
    required this.day,
    required this.amount,
    required this.isHighest,
  });

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  double get progressPercent => amount / 1000; // Assuming max is 1000 for visualization
} 