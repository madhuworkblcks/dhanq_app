import 'package:flutter/material.dart';

class FarmFinanceModel {
  final List<UpcomingPaymentModel> upcomingPayments;
  final List<HarvestIncomeModel> harvestIncomes;

  FarmFinanceModel({
    required this.upcomingPayments,
    required this.harvestIncomes,
  });
}

class UpcomingPaymentModel {
  final String item;
  final double amount;
  final DateTime dueDate;
  final String category;

  UpcomingPaymentModel({
    required this.item,
    required this.amount,
    required this.dueDate,
    required this.category,
  });

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  String get formattedDueDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }
}

class HarvestIncomeModel {
  final String crop;
  final double expectedIncome;
  final DateTime expectedDate;
  final String status;

  HarvestIncomeModel({
    required this.crop,
    required this.expectedIncome,
    required this.expectedDate,
    required this.status,
  });

  String get formattedIncome => '₹${expectedIncome.toStringAsFixed(0)}';
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[expectedDate.month - 1];
  }
}

class GovernmentSchemeModel {
  final String name;
  final String status;
  final DateTime nextInstallment;
  final bool isEligible;
  final String description;
  final String actionText;

  GovernmentSchemeModel({
    required this.name,
    required this.status,
    required this.nextInstallment,
    required this.isEligible,
    required this.description,
    required this.actionText,
  });

  String get formattedInstallment {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[nextInstallment.month - 1];
  }
}

class WeatherMarketModel {
  final List<MarketPriceModel> marketPrices;
  final WeatherForecastModel weatherForecast;

  WeatherMarketModel({
    required this.marketPrices,
    required this.weatherForecast,
  });
}

class MarketPriceModel {
  final String crop;
  final double price;
  final String unit;
  final double? change;

  MarketPriceModel({
    required this.crop,
    required this.price,
    required this.unit,
    this.change,
  });

  String get formattedPrice => '₹${price.toStringAsFixed(0)}/$unit';
  String get formattedChange {
    if (change == null) return '';
    final changeText = change! >= 0 ? '+' : '';
    return '$changeText${change!.toStringAsFixed(0)}%';
  }
}

class WeatherForecastModel {
  final String condition;
  final String description;
  final String recommendation;
  final IconData icon;

  WeatherForecastModel({
    required this.condition,
    required this.description,
    required this.recommendation,
    required this.icon,
  });
}

class MicroLoanSHGModel {
  final List<LoanPaymentModel> loanPayments;
  final List<SHGMeetingModel> shgMeetings;

  MicroLoanSHGModel({
    required this.loanPayments,
    required this.shgMeetings,
  });
}

class LoanPaymentModel {
  final DateTime dueDate;
  final double amount;
  final String loanType;
  final String status;

  LoanPaymentModel({
    required this.dueDate,
    required this.amount,
    required this.loanType,
    required this.status,
  });

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  String get formattedDueDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }
}

class SHGMeetingModel {
  final DateTime meetingDate;
  final String topic;
  final String location;
  final String status;

  SHGMeetingModel({
    required this.meetingDate,
    required this.topic,
    required this.location,
    required this.status,
  });

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[meetingDate.month - 1]} ${meetingDate.day}, ${meetingDate.year}';
  }
}

class VoiceQueryModel {
  final String prompt;
  final String suggestedQuery;
  final bool isListening;

  VoiceQueryModel({
    required this.prompt,
    required this.suggestedQuery,
    this.isListening = false,
  });
}

enum LanguageType {
  english,
  hindi,
} 