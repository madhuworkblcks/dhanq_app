import 'package:dhanq_app/models/portfolio_model.dart';
import 'package:flutter/material.dart';

class AssetManagementModel {
  final PortfolioModel portfolio;
  final List<AssetModel> assets;
  final Map<String, double> allocation;
  final List<TransactionModel> recentTransactions;
  final PerformanceModel performance;
  final List<InsightModel> insights;

  AssetManagementModel({
    required this.portfolio,
    required this.assets,
    required this.allocation,
    required this.recentTransactions,
    required this.performance,
    required this.insights,
  });

  factory AssetManagementModel.fromJson(Map<String, dynamic> json) {
    // Convert all values in allocation to double, even if they are int
    final rawAllocation = json['allocation'] as Map<String, dynamic>;
    final allocation = rawAllocation.map(
      (key, value) =>
          MapEntry(key, (value is int) ? value.toDouble() : value as double),
    );
    return AssetManagementModel(
      portfolio: PortfolioModel.fromJson(json['portfolio']),
      assets:
          (json['assets'] as List)
              .map((asset) => AssetModel.fromJson(asset))
              .toList(),
      allocation: allocation,
      recentTransactions:
          (json['recentTransactions'] as List)
              .map((transaction) => TransactionModel.fromJson(transaction))
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
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'allocation': allocation,
      'recentTransactions':
          recentTransactions
              .map((transaction) => transaction.toJson())
              .toList(),
      'performance': performance.toJson(),
      'insights': insights.map((insight) => insight.toJson()).toList(),
    };
  }
}

class AssetModel {
  final String id;
  final String name;
  final String type;
  final double value;
  final double percentage;
  final double change;
  final double changePercentage;
  final int quantity;
  final double avgPrice;
  final double currentPrice;

  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.percentage,
    required this.change,
    required this.changePercentage,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      value: json['value'].toDouble(),
      percentage: json['percentage'].toDouble(),
      change: json['change'].toDouble(),
      changePercentage: json['changePercentage'].toDouble(),
      quantity: json['quantity'],
      avgPrice: json['avgPrice'].toDouble(),
      currentPrice: json['currentPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'percentage': percentage,
      'change': change,
      'changePercentage': changePercentage,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
    };
  }

  String get formattedValue => '₹${_formatNumber(value)}';
  String get formattedChange =>
      '${change >= 0 ? '+' : ''}₹${_formatNumber(change)}';
  String get formattedChangePercentage =>
      '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%';
  Color get changeColor => change >= 0 ? Colors.green : Colors.red;

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}

class TransactionModel {
  final String id;
  final String type;
  final String asset;
  final int quantity;
  final double price;
  final double amount;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.asset,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      asset: json['asset'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      amount: json['amount'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'asset': asset,
      'quantity': quantity,
      'price': price,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get formattedAmount => '₹${_formatNumber(amount)}';
  String get formattedTime => _formatTime(timestamp);
  Color get typeColor => type == 'buy' ? Colors.green : Colors.red;
  IconData get typeIcon =>
      type == 'buy' ? Icons.arrow_upward : Icons.arrow_downward;

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class PerformanceModel {
  final double daily;
  final double weekly;
  final double monthly;
  final double yearly;

  PerformanceModel({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      daily: json['daily'].toDouble(),
      weekly: json['weekly'].toDouble(),
      monthly: json['monthly'].toDouble(),
      yearly: json['yearly'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily': daily,
      'weekly': weekly,
      'monthly': monthly,
      'yearly': yearly,
    };
  }
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

// Additional models for backward compatibility
class AssetAllocationModel {
  final double totalNetWorth;
  final double ytdChange;
  final List<AssetAllocationItem> allocations;

  AssetAllocationModel({
    required this.totalNetWorth,
    required this.ytdChange,
    required this.allocations,
  });

  String get formattedNetWorth => '₹${_formatNumber(totalNetWorth)}';
  String get formattedYtdChange =>
      '${ytdChange >= 0 ? '+' : ''}${ytdChange.toStringAsFixed(1)}% YTD';
  Color get ytdColor => ytdChange >= 0 ? Colors.green : Colors.red;
  bool get isYtdPositive => ytdChange >= 0;
}

class AssetAllocationItem {
  final String name;
  final double percentage;
  final double value;
  final Color color;

  AssetAllocationItem({
    required this.name,
    required this.percentage,
    required this.value,
    required this.color,
  });

  String get formattedValue => '₹${_formatNumber(value)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(0)}%';
}

class AssetCategoryModel {
  final String name;
  final double totalValue;
  final List<AssetModel> assets;

  AssetCategoryModel({
    required this.name,
    required this.totalValue,
    required this.assets,
  });

  String get formattedTotalValue => '₹${_formatNumber(totalValue)}';
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
