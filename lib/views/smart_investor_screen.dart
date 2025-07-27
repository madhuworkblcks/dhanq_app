import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/smart_investor_model.dart';
import '../viewmodels/smart_investor_viewmodel.dart';

class SmartInvestorScreen extends StatefulWidget {
  const SmartInvestorScreen({super.key});

  @override
  State<SmartInvestorScreen> createState() => _SmartInvestorScreenState();
}

class _SmartInvestorScreenState extends State<SmartInvestorScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SmartInvestorViewModel(),
      child: Consumer<SmartInvestorViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == SmartInvestorViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5), // Light beige background
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(SmartInvestorViewModel viewModel) {
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

            // Portfolio Management Section
            _buildPortfolioManagementSection(viewModel),

            // Market Sentiment Analysis Section
            _buildMarketSentimentSection(viewModel),

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
              'Smart Investor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {
              // Show notifications
              _showNotifications(context);
            },
            child: const Icon(
              Icons.notifications,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioManagementSection(SmartInvestorViewModel viewModel) {
    if (viewModel.portfolioAllocation == null) return const SizedBox.shrink();

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
            'Portfolio Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Current Allocation
          const Text(
            'Current Allocation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Allocation Chart and Legend
          Row(
            children: [
              // Donut Chart
              Expanded(
                flex: 1,
                child: _buildAllocationChart(
                  viewModel.portfolioAllocation!.allocationItems,
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                flex: 1,
                child: _buildAllocationLegend(
                  viewModel.portfolioAllocation!.allocationItems,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actionable Insights
          ...viewModel.actionableInsights
              .map((insight) => _buildActionableInsightCard(insight, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildAllocationChart(List<AllocationItem> allocations) {
    return SizedBox(
      height: 100,
      child: CustomPaint(painter: AllocationChartPainter(allocations)),
    );
  }

  Widget _buildAllocationLegend(List<AllocationItem> allocations) {
    return Column(
      children: allocations.map((item) => _buildLegendItem(item)).toList(),
    );
  }

  Widget _buildLegendItem(AllocationItem item) {
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
            item.formattedPercentage,
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

  Widget _buildActionableInsightCard(
    ActionableInsightModel insight,
    SmartInvestorViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => viewModel.onActionableInsightTap(insight),
              child: Text(
                insight.actionText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: insight.accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSentimentSection(SmartInvestorViewModel viewModel) {
    if (viewModel.interestRateImpact == null) return const SizedBox.shrink();

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
            'Market Sentiment Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Interest Rate Impact Card
          _buildInterestRateImpactCard(
            viewModel.interestRateImpact!,
            viewModel,
          ),

          const SizedBox(height: 16),

          // Market Sentiment Cards
          ...viewModel.marketSentimentAnalysis
              .map(
                (sentiment) => _buildMarketSentimentCard(sentiment, viewModel),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInterestRateImpactCard(
    InterestRateImpactModel impact,
    SmartInvestorViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                impact.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                impact.timeframe,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Simple line chart
          SizedBox(height: 60, child: _buildLineChart(impact.chartData)),

          const SizedBox(height: 12),

          Text(
            impact.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => viewModel.onInterestRateImpactTap(),
              child: Text(
                impact.actionText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> data) {
    return CustomPaint(
      painter: LineChartPainter(data),
      size: const Size(double.infinity, 60),
    );
  }

  Widget _buildMarketSentimentCard(
    MarketSentimentModelLegacy sentiment,
    SmartInvestorViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sentiment.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sentiment.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => viewModel.onMarketSentimentTap(sentiment),
              child: Text(
                sentiment.actionText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: sentiment.accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
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
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Portfolio rebalancing reminder'),
                subtitle: const Text('Your equity exposure needs adjustment'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Market update available'),
                subtitle: const Text('New insights for your investments'),
                onTap: () {
                  Navigator.pop(context);
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

// Custom painter for allocation chart
class AllocationChartPainter extends CustomPainter {
  final List<AllocationItem> allocations;

  AllocationChartPainter(this.allocations);

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

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<double> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = const Color(0xFF1E3A8A)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
