import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/integrations_model.dart';

class IntegrationsService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load integrations data from JSON file
  Future<Map<String, dynamic>> _loadIntegrationsData() async {
    try {
      // Load JSON from http URL or local asset
      final jsonString = await http
          .get(
            Uri.parse(
              'https://dhanqserv-43683479109.us-central1.run.app/api/external-providers/12345',
            ),
          )
          .then((response) => response.body);
      // final jsonString = await rootBundle.loadString('assets/integration.json');
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load integrations data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'integrationServices': [
        {
          'name': 'Mint',
          'description': 'Budget & expense tracking',
          'icon': {
            'codePoint': 59530,
            'fontFamily': 'MaterialIcons',
            'fontPackage': null,
            'matchTextDirection': false,
          },
          'category': 'Budgeting',
          'status': 'disconnected',
          'lastSync': null,
          'isConnected': false,
          'isRecommended': true,
        },
      ],
    };
  }

  // Helper method to convert JSON icon to Flutter IconData
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Helper method to convert JSON status string to IntegrationStatus enum
  IntegrationStatus _parseStatus(String statusString) {
    switch (statusString) {
      case 'connected':
        return IntegrationStatus.connected;
      case 'disconnected':
        return IntegrationStatus.disconnected;
      case 'pending':
        return IntegrationStatus.pending;
      case 'error':
        return IntegrationStatus.error;
      default:
        return IntegrationStatus.disconnected;
    }
  }

  Future<List<IntegrationServiceModel>> getRecommendedServices() async {
    await _simulateDelay();

    final jsonData = await _loadIntegrationsData();
    final servicesData = jsonData['integrationServices'] as List;

    return servicesData
        .where((service) => service['isRecommended'] == true)
        .map(
          (service) => IntegrationServiceModel(
            name: service['name'] as String,
            description: service['description'] as String,
            icon: _parseIcon(service['icon'] as Map<String, dynamic>),
            category: service['category'] as String?,
            status: _parseStatus(service['status'] as String),
            lastSync: service['lastSync'] as String?,
            isConnected: service['isConnected'] as bool,
            isRecommended: service['isRecommended'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<List<IntegrationServiceModel>> getConnectedServices() async {
    await _simulateDelay();

    final jsonData = await _loadIntegrationsData();
    final servicesData = jsonData['integrationServices'] as List;

    return servicesData
        .where((service) => service['isConnected'] == true)
        .map(
          (service) => IntegrationServiceModel(
            name: service['name'] as String,
            description: service['description'] as String,
            icon: _parseIcon(service['icon'] as Map<String, dynamic>),
            category: service['category'] as String?,
            status: _parseStatus(service['status'] as String),
            lastSync: service['lastSync'] as String?,
            isConnected: service['isConnected'] as bool,
            isRecommended: service['isRecommended'] as bool? ?? false,
          ),
        )
        .toList();
  }

  Future<List<IntegrationCategoryModel>> getAvailableIntegrations() async {
    await _simulateDelay();

    final jsonData = await _loadIntegrationsData();
    final categoriesData = jsonData['integrationCategories'] as List;

    return categoriesData
        .map(
          (category) => IntegrationCategoryModel(
            name: category['name'] as String,
            icon: _parseIcon(category['icon'] as Map<String, dynamic>),
            services:
                (category['services'] as List)
                    .map(
                      (service) => IntegrationServiceModel(
                        name: service['name'] as String,
                        description: service['description'] as String,
                        icon: _parseIcon(
                          service['icon'] as Map<String, dynamic>,
                        ),
                        category: service['category'] as String?,
                        status: _parseStatus(service['status'] as String),
                        lastSync: service['lastSync'] as String?,
                        isConnected: service['isConnected'] as bool,
                        isRecommended:
                            service['isRecommended'] as bool? ?? false,
                      ),
                    )
                    .toList(),
          ),
        )
        .toList();
  }

  Future<List<DataPermissionModel>> getDataPermissions() async {
    await _simulateDelay();

    final jsonData = await _loadIntegrationsData();
    final permissionsData = jsonData['dataPermissions'] as List;

    return permissionsData
        .map(
          (permission) => DataPermissionModel(
            serviceName: permission['serviceName'] as String,
            icon: _parseIcon(permission['icon'] as Map<String, dynamic>),
            lastAccessed: permission['lastAccessed'] as String,
            permissions:
                (permission['permissions'] as List)
                    .map(
                      (perm) => DataPermissionItem(
                        dataType: perm['dataType'] as String,
                        isEnabled: perm['isEnabled'] as bool,
                      ),
                    )
                    .toList(),
          ),
        )
        .toList();
  }

  Future<List<IntegrationSettingModel>> getIntegrationSettings() async {
    await _simulateDelay();

    final jsonData = await _loadIntegrationsData();
    final settingsData = jsonData['integrationSettings'] as List;

    return settingsData
        .map(
          (setting) => IntegrationSettingModel(
            name: setting['name'] as String,
            description: setting['description'] as String,
            isEnabled: setting['isEnabled'] as bool,
          ),
        )
        .toList();
  }

  Future<void> connectService(String serviceName) async {
    await _simulateDelay();
    // Simulate connecting a service
    print('Connecting to $serviceName...');
  }

  Future<void> disconnectService(String serviceName) async {
    await _simulateDelay();
    // Simulate disconnecting a service
    print('Disconnecting from $serviceName...');
  }

  Future<void> updateDataPermission(
    String serviceName,
    String dataType,
    bool isEnabled,
  ) async {
    await _simulateDelay();
    // Simulate updating data permission
    print('Updating $dataType permission for $serviceName to $isEnabled');
  }

  Future<void> updateSetting(String settingName, bool isEnabled) async {
    await _simulateDelay();
    // Simulate updating setting
    print('Updating $settingName to $isEnabled');
  }

  // Load all integrations data at once
  Future<Map<String, dynamic>> getAllIntegrationsData() async {
    await _simulateDelay();
    return await _loadIntegrationsData();
  }
}
