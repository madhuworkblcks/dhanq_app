import 'package:dhanq_app/services/home_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/integrations_model.dart';
import '../viewmodels/integrations_viewmodel.dart';

class IntegrationsScreen extends StatefulWidget {
  final LocationType locationType;
  const IntegrationsScreen({super.key, required this.locationType});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IntegrationsViewModel(),
      child: Consumer<IntegrationsViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == IntegrationsViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(IntegrationsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == IntegrationsViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Recommended for You Section
            _buildRecommendedSection(viewModel),

            // Connected Services Section
            _buildConnectedServicesSection(viewModel),

            // Available Integrations Section
            _buildAvailableIntegrationsSection(viewModel),

            // Data Sharing Permissions Section
            _buildDataPermissionsSection(viewModel),

            // Integration Settings Section
            _buildIntegrationSettingsSection(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<IntegrationsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          color: Colors.white,
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              const Expanded(
                child: Text(
                  'Integrations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Language buttons
              if (widget.locationType == LocationType.rural) ...[
                Row(
                  children: [
                    _buildLanguageButton('EN', LanguageType.english, viewModel),
                    const SizedBox(width: 8),
                    _buildLanguageButton('हि', LanguageType.hindi, viewModel),
                  ],
                ),
                const SizedBox(width: 12),
              ],
              const SizedBox(width: 12),
              // Menu button
              GestureDetector(
                onTap: () {
                  // Show menu options
                  _showMenuOptions(context);
                },
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(
    String text,
    LanguageType language,
    IntegrationsViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedLanguage == language;
    return GestureDetector(
      onTap: () => viewModel.setLanguage(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3A8A), width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Data'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<IntegrationsViewModel>().refreshData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Report'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement export functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSection(IntegrationsViewModel viewModel) {
    if (viewModel.recommendedServices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal scrollable list
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.recommendedServices.length,
              itemBuilder: (context, index) {
                return _buildRecommendedServiceCard(
                  viewModel.recommendedServices[index],
                  viewModel,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedServiceCard(
    IntegrationServiceModel service,
    IntegrationsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onRecommendedServiceTap(service),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and service name in a row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E6D2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    service.icon,
                    color: const Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              service.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Spacer(),
            // Connect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => viewModel.connectService(service.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedServicesSection(IntegrationsViewModel viewModel) {
    if (viewModel.connectedServices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Connected services list
          ...viewModel.connectedServices
              .map((service) => _buildConnectedServiceCard(service, viewModel))
              .toList(),

          const SizedBox(height: 16),

          // Connect new service button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Color(0xFF1E3A8A), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Connect a New Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedServiceCard(
    IntegrationServiceModel service,
    IntegrationsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onConnectedServiceTap(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6D2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                service.icon,
                color: const Color(0xFF1E3A8A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Connected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (service.lastSync != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last sync: ${service.lastSync}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            // Toggle switch
            Switch(
              value: service.isConnected,
              onChanged: (value) {
                if (value) {
                  viewModel.connectService(service.name);
                } else {
                  viewModel.disconnectService(service.name);
                }
              },
              activeColor: const Color(0xFF1E3A8A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableIntegrationsSection(IntegrationsViewModel viewModel) {
    if (viewModel.availableIntegrations.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Integrations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ...viewModel.availableIntegrations
              .map((category) => _buildIntegrationCategory(category, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildIntegrationCategory(
    IntegrationCategoryModel category,
    IntegrationsViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6D2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  category.icon,
                  color: const Color(0xFF1E3A8A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Services in category
          ...category.services
              .map((service) => _buildAvailableServiceCard(service, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAvailableServiceCard(
    IntegrationServiceModel service,
    IntegrationsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onAvailableServiceTap(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6D2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                service.icon,
                color: const Color(0xFF1E3A8A),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Connect button
            ElevatedButton(
              onPressed: () => viewModel.connectService(service.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPermissionsSection(IntegrationsViewModel viewModel) {
    if (viewModel.dataPermissions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Data Sharing Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showPermissionsInfo(context),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info, size: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...viewModel.dataPermissions
              .map(
                (permission) => _buildDataPermissionCard(permission, viewModel),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDataPermissionCard(
    DataPermissionModel permission,
    IntegrationsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onDataPermissionTap(permission),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E6D2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    permission.icon,
                    color: const Color(0xFF1E3A8A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    permission.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Permissions list
            ...permission.permissions.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.dataType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: item.isEnabled,
                      onChanged: (value) {
                        viewModel.updateDataPermission(
                          permission.serviceName,
                          item.dataType,
                          value,
                        );
                      },
                      activeColor: const Color(0xFF1E3A8A),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Last accessed: ${permission.lastAccessed}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationSettingsSection(IntegrationsViewModel viewModel) {
    if (viewModel.integrationSettings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Integration Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ...viewModel.integrationSettings
              .map((setting) => _buildSettingCard(setting, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    IntegrationSettingModel setting,
    IntegrationsViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onSettingTap(setting),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    setting.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: setting.isEnabled,
              onChanged: (value) {
                viewModel.updateSetting(setting.name, value);
              },
              activeColor: const Color(0xFF1E3A8A),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Integrations'),
          content: const Text(
            'Search functionality for finding specific integrations will be implemented here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Data Sharing Permissions'),
          content: const Text(
            'Control what data each connected service can access. You can enable or disable specific data types for each integration.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
