import 'package:flutter/material.dart';

enum LanguageType { english, hindi }

class IntegrationServiceModel {
  final String name;
  final String description;
  final IconData icon;
  final String? category;
  final IntegrationStatus status;
  final String? lastSync;
  final bool isConnected;
  final bool isRecommended;

  IntegrationServiceModel({
    required this.name,
    required this.description,
    required this.icon,
    this.category,
    required this.status,
    this.lastSync,
    required this.isConnected,
    this.isRecommended = false,
  });
}

enum IntegrationStatus {
  connected,
  disconnected,
  pending,
  error,
}

class DataPermissionModel {
  final String serviceName;
  final IconData icon;
  final List<DataPermissionItem> permissions;
  final String lastAccessed;

  DataPermissionModel({
    required this.serviceName,
    required this.icon,
    required this.permissions,
    required this.lastAccessed,
  });
}

class DataPermissionItem {
  final String dataType;
  final bool isEnabled;

  DataPermissionItem({
    required this.dataType,
    required this.isEnabled,
  });
}

class IntegrationSettingModel {
  final String name;
  final String description;
  final bool isEnabled;

  IntegrationSettingModel({
    required this.name,
    required this.description,
    required this.isEnabled,
  });
}

class IntegrationCategoryModel {
  final String name;
  final IconData icon;
  final List<IntegrationServiceModel> services;

  IntegrationCategoryModel({
    required this.name,
    required this.icon,
    required this.services,
  });
} 