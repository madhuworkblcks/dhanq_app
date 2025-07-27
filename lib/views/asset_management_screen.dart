import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/asset_model.dart';
import '../viewmodels/asset_viewmodel.dart';

class AssetManagementScreen extends StatefulWidget {
  const AssetManagementScreen({super.key});

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssetViewModel(),
      builder: (context, child) {
        // Initialize data after provider is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AssetViewModel>().initializeData();
        });
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5), // Light beige background
          body: Consumer<AssetViewModel>(
            builder: (context, viewModel, child) {
              return _buildBody(viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(AssetViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Net Worth Card
            _buildNetWorthCard(viewModel),

            // Asset Allocation Card
            _buildAssetAllocationCard(viewModel),

            // Navigation Tabs
            _buildNavigationTabs(viewModel),

            // Content based on selected tab
            _buildTabContent(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              'Asset Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Menu button
          GestureDetector(
            onTap: () {
              // Show menu options
              _showMenuOptions(context);
            },
            child: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard(AssetViewModel viewModel) {
    if (viewModel.assetAllocation == null) return const SizedBox.shrink();

    final allocation = viewModel.assetAllocation!;

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
            'Net Worth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  allocation.formattedNetWorth,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                allocation.formattedYtdChange,
                style: TextStyle(
                  fontSize: 14,
                  color: allocation.ytdColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini chart (simplified)
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: List.generate(10, (index) {
                final height = 20 + (index % 3) * 10.0;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    height: height,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAllocationCard(AssetViewModel viewModel) {
    if (viewModel.assetAllocation == null) return const SizedBox.shrink();

    final allocation = viewModel.assetAllocation!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            'Asset Allocation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut chart
              Expanded(
                flex: 1,
                child: _buildDonutChart(allocation.allocations),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                flex: 1,
                child: _buildAllocationLegend(allocation.allocations),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(List<AssetAllocationItem> allocations) {
    return SizedBox(
      height: 120,
      child: CustomPaint(painter: DonutChartPainter(allocations)),
    );
  }

  Widget _buildAllocationLegend(List<AssetAllocationItem> allocations) {
    return Column(
      children: allocations.map((item) => _buildLegendItem(item)).toList(),
    );
  }

  Widget _buildLegendItem(AssetAllocationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            '${item.formattedPercentage} (${item.formattedValue})',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(AssetViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTabButton('Assets', AssetTab.assets, viewModel),
          const SizedBox(width: 30),
          _buildTabButton('Liabilities', AssetTab.liabilities, viewModel),
          const SizedBox(width: 30),
          _buildTabButton('Recurring', AssetTab.recurring, viewModel),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, AssetTab tab, AssetViewModel viewModel) {
    final isSelected = viewModel.selectedTab == tab;

    return GestureDetector(
      onTap: () => viewModel.setSelectedTab(tab),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A), // Brown underline
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AssetViewModel viewModel) {
    switch (viewModel.selectedTab) {
      case AssetTab.assets:
        return _buildAssetsContent(viewModel);
      case AssetTab.liabilities:
        return _buildLiabilitiesContent(viewModel);
      case AssetTab.recurring:
        return _buildRecurringContent(viewModel);
      case AssetTab.overview:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAssetsContent(AssetViewModel viewModel) {
    return Column(
      children:
          viewModel.assetCategories
              .map((category) => _buildAssetCategoryCard(category))
              .toList(),
    );
  }

  Widget _buildAssetCategoryCard(AssetCategoryModel category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                category.formattedTotalValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...category.assets.map((asset) => _buildAssetItem(asset)).toList(),
        ],
      ),
    );
  }

  Widget _buildAssetItem(AssetModel asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              asset.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                asset.formattedValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${asset.formattedChange})',
                style: TextStyle(
                  fontSize: 12,
                  color: asset.changeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesContent(AssetViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: const Center(
        child: Text(
          'No liabilities found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildRecurringContent(AssetViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: const Center(
        child: Text(
          'No recurring assets found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                  context.read<AssetViewModel>().refreshData();
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
}

// Custom painter for donut chart
class DonutChartPainter extends CustomPainter {
  final List<AssetAllocationItem> allocations;

  DonutChartPainter(this.allocations);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final innerRadius = radius * 0.6;

    double startAngle = 0;

    for (final allocation in allocations) {
      final sweepAngle = (allocation.percentage / 100) * 2 * 3.14159;

      final paint =
          Paint()
            ..color = allocation.color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw inner circle to create donut effect
      final innerPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      canvas.drawCircle(center, innerRadius, innerPaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
