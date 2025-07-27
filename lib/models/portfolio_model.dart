import 'package:flutter/material.dart';

class PortfolioModel {
  final double totalValue;
  final double todayGain;
  final double totalGain;
  final double gainPercentage;

  PortfolioModel({
    required this.totalValue,
    required this.todayGain,
    required this.totalGain,
    required this.gainPercentage,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      totalValue: json['totalValue'].toDouble(),
      todayGain: json['todayGain'].toDouble(),
      totalGain: json['totalGain'].toDouble(),
      gainPercentage: json['gainPercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalValue': totalValue,
      'todayGain': todayGain,
      'totalGain': totalGain,
      'gainPercentage': gainPercentage,
    };
  }

  String get formattedTotalValue => '₹${_formatNumber(totalValue)}';
  String get formattedTodayGain => '${todayGain >= 0 ? '+' : ''}₹${_formatNumber(todayGain)}';
  String get formattedTotalGain => '${totalGain >= 0 ? '+' : ''}₹${_formatNumber(totalGain)}';
  String get formattedGainPercentage => '${gainPercentage >= 0 ? '+' : ''}${gainPercentage.toStringAsFixed(2)}%';

  Color get todayGainColor => todayGain >= 0 ? Colors.green : Colors.red;
  Color get totalGainColor => totalGain >= 0 ? Colors.green : Colors.red;
  Color get gainPercentageColor => gainPercentage >= 0 ? Colors.green : Colors.red;
}

String _formatNumber(double number) {
  if (number >= 100000) {
    return '${(number / 100000).toStringAsFixed(1)}L';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toStringAsFixed(0);
} 