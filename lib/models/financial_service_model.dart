import 'package:flutter/material.dart';

class FinancialServiceModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String category;

  FinancialServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });

  factory FinancialServiceModel.fromJson(Map<String, dynamic> json) {
    return FinancialServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: _getIconFromString(json['icon']),
      color: _getColorFromString(json['color']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'color': _getStringFromColor(color),
      'category': category,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'business':
        return Icons.business;
      case 'account_balance':
        return Icons.account_balance;
      case 'medical_services':
        return Icons.medical_services;
      case 'description':
        return Icons.description;
      case 'favorite':
        return Icons.favorite;
      case 'api':
        return Icons.api;
      case 'track_changes':
        return Icons.track_changes;
      case 'agriculture':
        return Icons.agriculture;
      case 'store':
        return Icons.store;
      case 'savings':
        return Icons.savings;
      case 'mic':
        return Icons.mic;
      default:
        return Icons.business;
    }
  }

  static Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'indigo':
        return Colors.indigo;
      case 'teal':
        return Colors.teal;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.business) return 'business';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.medical_services) return 'medical_services';
    if (icon == Icons.description) return 'description';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.api) return 'api';
    if (icon == Icons.track_changes) return 'track_changes';
    if (icon == Icons.agriculture) return 'agriculture';
    if (icon == Icons.store) return 'store';
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.mic) return 'mic';
    return 'business';
  }

  static String _getStringFromColor(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.red) return 'red';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.brown) return 'brown';
    return 'blue';
  }
} 