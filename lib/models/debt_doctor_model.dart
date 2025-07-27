import 'package:flutter/material.dart';

class DebtDoctorModel {
  final DebtOverviewModel debtOverview;
  final Map<String, double> debtBreakdown;
  final List<DebtModel> debts;
  final List<RepaymentStrategyModel> repaymentStrategies;
  final CreditScoreModel creditScore;
  final List<InsightModel> insights;

  DebtDoctorModel({
    required this.debtOverview,
    required this.debtBreakdown,
    required this.debts,
    required this.repaymentStrategies,
    required this.creditScore,
    required this.insights,
  });

  factory DebtDoctorModel.fromJson(Map<String, dynamic> json) {
    return DebtDoctorModel(
      debtOverview: DebtOverviewModel.fromJson(json['debtOverview']),
      debtBreakdown: (json['debtBreakdown'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value is int) ? value.toDouble() : value as double),
      ),
      debts:
          (json['debts'] as List)
              .map((debt) => DebtModel.fromJson(debt))
              .toList(),
      repaymentStrategies:
          (json['repaymentStrategies'] as List)
              .map((strategy) => RepaymentStrategyModel.fromJson(strategy))
              .toList(),
      creditScore: CreditScoreModel.fromJson(json['creditScore']),
      insights:
          (json['insights'] as List)
              .map((insight) => InsightModel.fromJson(insight))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtOverview': debtOverview.toJson(),
      'debtBreakdown': debtBreakdown,
      'debts': debts.map((debt) => debt.toJson()).toList(),
      'repaymentStrategies':
          repaymentStrategies.map((strategy) => strategy.toJson()).toList(),
      'creditScore': creditScore.toJson(),
      'insights': insights.map((insight) => insight.toJson()).toList(),
    };
  }
}

class DebtOverviewModel {
  final double totalDebt;
  final double monthlyPayment;
  final double totalInterest;
  final double debtToIncomeRatio;
  final int creditScore;
  final String paymentHistory;
  final double utilizationRate;

  DebtOverviewModel({
    required this.totalDebt,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.debtToIncomeRatio,
    required this.creditScore,
    required this.paymentHistory,
    required this.utilizationRate,
  });

  factory DebtOverviewModel.fromJson(Map<String, dynamic> json) {
    return DebtOverviewModel(
      totalDebt: json['totalDebt'].toDouble(),
      monthlyPayment: json['monthlyPayment'].toDouble(),
      totalInterest: json['totalInterest'].toDouble(),
      debtToIncomeRatio: json['debtToIncomeRatio'].toDouble(),
      creditScore: json['creditScore'],
      paymentHistory: json['paymentHistory'],
      utilizationRate: json['utilizationRate'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDebt': totalDebt,
      'monthlyPayment': monthlyPayment,
      'totalInterest': totalInterest,
      'debtToIncomeRatio': debtToIncomeRatio,
      'creditScore': creditScore,
      'paymentHistory': paymentHistory,
      'utilizationRate': utilizationRate,
    };
  }

  String get formattedTotalDebt => '₹${_formatNumber(totalDebt)}';
  String get formattedMonthlyPayment => '₹${_formatNumber(monthlyPayment)}';
  String get formattedTotalInterest => '₹${_formatNumber(totalInterest)}';
  String get formattedDebtToIncomeRatio =>
      '${debtToIncomeRatio.toStringAsFixed(1)}%';
  String get formattedUtilizationRate =>
      '${utilizationRate.toStringAsFixed(1)}%';

  // Additional getters for UI compatibility
  String get formattedInterestPaid => formattedTotalInterest;
  String get formattedPotentialSavings =>
      '₹${_formatNumber(totalInterest * 0.3)}'; // 30% potential savings
}

class DebtModel {
  final String id;
  final String name;
  final String type;
  final double balance;
  final double interestRate;
  final double minimumPayment;
  final DateTime dueDate;
  final String category;

  DebtModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.interestRate,
    required this.minimumPayment,
    required this.dueDate,
    required this.category,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      balance: json['balance'].toDouble(),
      interestRate: json['interestRate'].toDouble(),
      minimumPayment: json['minimumPayment'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
    };
  }

  String get formattedBalance => '₹${_formatNumber(balance)}';
  String get formattedInterestRate => '${interestRate.toStringAsFixed(1)}%';
  String get formattedMinimumPayment => '₹${_formatNumber(minimumPayment)}';
  String get formattedDueDate => _formatDate(dueDate);
  Color get categoryColor => _getCategoryColor(category);
}

class RepaymentStrategyModel {
  final String id;
  final String name;
  final String description;
  final double totalInterest;
  final int payoffTime;
  final double monthlyPayment;
  final double savings;
  final int timeSaved;
  final String recommendation;
  final List<double> payoffData;

  RepaymentStrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalInterest,
    required this.payoffTime,
    required this.monthlyPayment,
    required this.savings,
    required this.timeSaved,
    required this.recommendation,
    required this.payoffData,
  });

  factory RepaymentStrategyModel.fromJson(Map<String, dynamic> json) {
    return RepaymentStrategyModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      totalInterest: json['totalInterest'].toDouble(),
      payoffTime: json['payoffTime'],
      monthlyPayment: json['monthlyPayment'].toDouble(),
      savings: json['savings'].toDouble(),
      timeSaved: json['timeSaved'],
      recommendation: json['recommendation'],
      payoffData:
          (json['payoffData'] as List)
              .map((e) => (e is int) ? e.toDouble() : e as double)
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalInterest': totalInterest,
      'payoffTime': payoffTime,
      'monthlyPayment': monthlyPayment,
      'savings': savings,
      'timeSaved': timeSaved,
      'recommendation': recommendation,
      'payoffData': payoffData,
    };
  }

  String get formattedTotalInterest => '₹${_formatNumber(totalInterest)}';
  String get formattedPayoffTime => '${payoffTime} months';
  String get formattedMonthlyPayment => '₹${_formatNumber(monthlyPayment)}';
  String get formattedSavings => '₹${_formatNumber(savings)}';
  String get formattedTimeSaved => '${timeSaved} months';
  Color get strategyColor => _getStrategyColor(name);

  // Additional getters for UI compatibility
  Color get color => strategyColor;
  String get formattedInterest => formattedTotalInterest;
}

class CreditScoreModel {
  final int score;
  final String category;
  final List<CreditScoreFactor> factors;
  final List<double> trend;
  final List<String> improvementTips;

  CreditScoreModel({
    required this.score,
    required this.category,
    required this.factors,
    required this.trend,
    required this.improvementTips,
  });

  factory CreditScoreModel.fromJson(Map<String, dynamic> json) {
    return CreditScoreModel(
      score: json['score'],
      category: json['category'],
      factors:
          (json['factors'] as List)
              .map((factor) => CreditScoreFactor.fromJson(factor))
              .toList(),
      trend:
          (json['trend'] as List)
              .map((e) => (e is int) ? e.toDouble() : e as double)
              .toList(),
      improvementTips:
          (json['improvementTips'] as List).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'category': category,
      'factors': factors.map((factor) => factor.toJson()).toList(),
      'trend': trend,
      'improvementTips': improvementTips,
    };
  }

  String get formattedScore => '$score';
  double get scorePercentage =>
      (score / 850) * 100; // Assuming max score is 850
  Color get categoryColor => _getCreditScoreColor(score);

  // Additional getters for UI compatibility
  List<double> get trendData => trend;
  List<String> get trendLabels {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return months.take(trend.length).toList();
  }

  String get formattedPotentialIncrease {
    if (trend.length >= 2) {
      final increase = trend.last - trend.first;
      return increase >= 0 ? '+${increase.toInt()}' : '${increase.toInt()}';
    }
    return '0';
  }
}

class CreditScoreFactor {
  final String factor;
  final String impact;
  final double contribution;
  final String description;

  CreditScoreFactor({
    required this.factor,
    required this.impact,
    required this.contribution,
    required this.description,
  });

  factory CreditScoreFactor.fromJson(Map<String, dynamic> json) {
    return CreditScoreFactor(
      factor: json['factor'],
      impact: json['impact'],
      contribution: json['contribution'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factor': factor,
      'impact': impact,
      'contribution': contribution,
      'description': description,
    };
  }

  String get formattedContribution => '${contribution.toStringAsFixed(0)}%';
  Color get impactColor => _getImpactColor(impact);

  // Additional getters for UI compatibility
  String get name => factor;
  String get status => impact;
  Color get statusColor => impactColor;
}

class InsightModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String priority;

  InsightModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'priority': priority,
    };
  }

  Color get typeColor {
    switch (type) {
      case 'positive':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'positive':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'negative':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}

// Legacy models for backward compatibility
class DebtBreakdownItem {
  final String type;
  final double amount;
  final Color color;
  final double percentage;

  DebtBreakdownItem({
    required this.type,
    required this.amount,
    required this.color,
    required this.percentage,
  });

  String get formattedAmount => '₹${_formatNumber(amount)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

class DebtBreakdownModel {
  final List<DebtBreakdownItem> items;
  final double totalAmount;

  DebtBreakdownModel({required this.items, required this.totalAmount});

  String get formattedTotalAmount => '₹${_formatNumber(totalAmount)}';
}

class RepaymentStrategiesModel {
  final RepaymentStrategyModel avalanche;
  final RepaymentStrategyModel snowball;
  final String recommendation;
  final double savings;
  final int timeSaved;

  RepaymentStrategiesModel({
    required this.avalanche,
    required this.snowball,
    required this.recommendation,
    required this.savings,
    required this.timeSaved,
  });

  String get formattedSavings => '₹${_formatNumber(savings)}';
  String get formattedTimeSaved => '$timeSaved months';
}

class CreditScoreFactorsModel {
  final List<CreditScoreFactor> factors;

  CreditScoreFactorsModel({required this.factors});
}

// Helper functions
String _formatNumber(double number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else {
    return number.toStringAsFixed(0);
  }
}

String _formatDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'creditCards':
      return Colors.red;
    case 'personalLoans':
      return Colors.orange;
    case 'homeLoan':
      return Colors.blue;
    case 'studentLoan':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

Color _getStrategyColor(String name) {
  switch (name.toLowerCase()) {
    case 'avalanche':
      return Colors.green;
    case 'snowball':
      return Colors.blue;
    case 'consolidation':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

Color _getCreditScoreColor(int score) {
  if (score >= 750) return Colors.green;
  if (score >= 650) return Colors.orange;
  return Colors.red;
}

Color _getImpactColor(String impact) {
  switch (impact.toLowerCase()) {
    case 'excellent':
      return Colors.green;
    case 'good':
      return Colors.blue;
    case 'fair':
      return Colors.orange;
    case 'poor':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
