import 'package:dhanq_app/services/home_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/financial_health_score_model.dart';
import '../viewmodels/financial_health_score_viewmodel.dart';

class FinancialHealthScoreScreen extends StatefulWidget {
  final LocationType locationType;

  const FinancialHealthScoreScreen({super.key, required this.locationType});

  @override
  State<FinancialHealthScoreScreen> createState() =>
      _FinancialHealthScoreScreenState();
}

class _FinancialHealthScoreScreenState
    extends State<FinancialHealthScoreScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FinancialHealthScoreViewModel(),
      child: Consumer<FinancialHealthScoreViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == FinancialHealthScoreViewState.initial) {
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

  Widget _buildBody(FinancialHealthScoreViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == FinancialHealthScoreViewState.error) {
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

            // Financial Health Score Summary
            _buildFinancialHealthScoreSummary(viewModel),

            // Key Metrics Section
            _buildKeyMetricsSection(viewModel),

            // Score Breakdown Section
            _buildScoreBreakdownSection(viewModel),

            // Financial Insights Section
            _buildFinancialInsightsSection(viewModel),

            // Monthly Trend Section
            _buildMonthlyTrendSection(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<FinancialHealthScoreViewModel>(
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
                  'Financial Health Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Language buttons (show only if segment is Rural)
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
              // Info button
              GestureDetector(
                onTap: () {
                  // Show info/help
                  _showInfoDialog(context);
                },
                child: const Icon(
                  Icons.info_outline,
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
    FinancialHealthScoreViewModel viewModel,
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

  Widget _buildFinancialHealthScoreSummary(
    FinancialHealthScoreViewModel viewModel,
  ) {
    if (viewModel.financialHealthScore == null) return const SizedBox.shrink();

    final healthScore = viewModel.financialHealthScore!;

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
      child: Row(
        children: [
          // Score dial
          Expanded(flex: 1, child: _buildScoreDial(healthScore)),
          const SizedBox(width: 20),
          // Status and description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  healthScore.status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: healthScore.statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  healthScore.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDial(FinancialHealthScoreModel healthScore) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress circle with segmented colors
        SizedBox(
          height: 120,
          width: 120,
          child: CustomPaint(
            painter: SegmentedScoreDialPainter(healthScore.scorePercentage),
          ),
        ),
        // Score text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              healthScore.formattedScore,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              healthScore.formattedMaxScore,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyMetricsSection(FinancialHealthScoreViewModel viewModel) {
    if (viewModel.keyMetrics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 grid of metric cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: viewModel.keyMetrics.length,
            itemBuilder: (context, index) {
              return _buildKeyMetricCard(
                viewModel.keyMetrics[index],
                viewModel,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricCard(
    KeyMetricModel metric,
    FinancialHealthScoreViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onKeyMetricTap(metric),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(metric.icon, color: const Color(0xFF1E3A8A), size: 24),
                if (metric.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      metric.status!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (metric.trend != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    metric.isPositiveTrend
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: metric.trendColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metric.trend!,
                    style: TextStyle(
                      fontSize: 12,
                      color: metric.trendColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdownSection(FinancialHealthScoreViewModel viewModel) {
    if (viewModel.scoreBreakdown.isEmpty) return const SizedBox.shrink();

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
            'Score Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ...viewModel.scoreBreakdown
              .map(
                (breakdown) => _buildScoreBreakdownItem(breakdown, viewModel),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdownItem(
    ScoreBreakdownModel breakdown,
    FinancialHealthScoreViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onScoreBreakdownTap(breakdown),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  breakdown.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  breakdown.formattedPercentage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: breakdown.percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(breakdown.color),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialInsightsSection(
    FinancialHealthScoreViewModel viewModel,
  ) {
    if (viewModel.financialInsights.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ...viewModel.financialInsights
              .map((insight) => _buildFinancialInsightCard(insight, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFinancialInsightCard(
    FinancialInsightModel insight,
    FinancialHealthScoreViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onFinancialInsightTap(insight),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6D2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(insight.icon, color: insight.iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                insight.text,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendSection(FinancialHealthScoreViewModel viewModel) {
    if (viewModel.monthlyTrend == null) return const SizedBox.shrink();

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
            'Monthly Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Line chart
          SizedBox(
            height: 120,
            child: _buildLineChart(viewModel.monthlyTrend!),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(MonthlyTrendModel trend) {
    return CustomPaint(
      painter: LineChartPainter(trend.data, trend.labels),
      size: const Size(double.infinity, 120),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Financial Health Score'),
          content: const Text(
            'Your Financial Health Score is calculated based on multiple factors including savings rate, debt management, spending habits, and future planning. A higher score indicates better financial health.',
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

// Custom painter for segmented score dial
class SegmentedScoreDialPainter extends CustomPainter {
  final double percentage;

  SegmentedScoreDialPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Define color segments
    final segments = [
      {'start': 0.0, 'end': 0.25, 'color': Colors.red},
      {'start': 0.25, 'end': 0.5, 'color': Colors.blue},
      {'start': 0.5, 'end': 0.75, 'color': Colors.orange},
      {'start': 0.75, 'end': 1.0, 'color': Colors.green},
    ];

    for (final segment in segments) {
      final start = segment['start'] as double;
      final end = segment['end'] as double;
      final color = segment['color'] as Color;
      final startAngle = start * 2 * 3.14159;
      final endAngle = end * 2 * 3.14159;
      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }

    // Draw progress overlay
    final progressPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;

    final progressAngle = (percentage / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  LineChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3
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

      // Draw data points
      final pointPaint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);

    // Draw labels
    for (int i = 0; i < labels.length; i++) {
      final x = (i / (labels.length - 1)) * size.width;
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
