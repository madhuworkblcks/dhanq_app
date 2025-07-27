import 'package:flutter/material.dart';

enum ActivityType { investment, dividend, withdrawal, transfer }

class ActivityModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final ActivityType type;

  ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.type,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  String get formattedAmount {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix₹${_formatNumber(amount.abs())}';
  }

  String get formattedTime {
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

  Color get amountColor {
    return amount >= 0 ? Colors.green : Colors.red;
  }

  IconData get typeIcon {
    switch (type) {
      case ActivityType.investment:
        return Icons.trending_up;
      case ActivityType.dividend:
        return Icons.account_balance;
      case ActivityType.withdrawal:
        return Icons.money_off;
      case ActivityType.transfer:
        return Icons.swap_horiz;
    }
  }

  Color get iconColor {
    switch (type) {
      case ActivityType.investment:
        return Colors.green;
      case ActivityType.dividend:
        return Colors.orange;
      case ActivityType.withdrawal:
        return Colors.red;
      case ActivityType.transfer:
        return Colors.blue;
    }
  }

  IconData get icon {
    return typeIcon; // Use the existing typeIcon getter
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
} 