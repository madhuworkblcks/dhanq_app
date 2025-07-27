import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tax_whisperer_viewmodel.dart';
import '../models/tax_whisperer_model.dart';

class TaxWhispererScreen extends StatefulWidget {
  const TaxWhispererScreen({super.key});

  @override
  State<TaxWhispererScreen> createState() => _TaxWhispererScreenState();
}

class _TaxWhispererScreenState extends State<TaxWhispererScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaxWhispererViewModel(),
      child: Consumer<TaxWhispererViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == TaxWhispererViewState.initial) {
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

  Widget _buildBody(TaxWhispererViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == TaxWhispererViewState.error) {
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
            
            // Tax Health Score Section
            _buildTaxHealthScoreSection(viewModel),
            
            // Tax Liability Forecast Section
            _buildTaxLiabilityForecastSection(viewModel),
            
            // Personalized Deductions Section
            _buildPersonalizedDeductionsSection(viewModel),
            
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
              'Tax Whisperer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
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
  }

  Widget _buildTaxHealthScoreSection(TaxWhispererViewModel viewModel) {
    if (viewModel.taxHealthScore == null) return const SizedBox.shrink();

    final healthScore = viewModel.taxHealthScore!;

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
            'Tax Health Score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              // Circular gauge
              Expanded(
                flex: 1,
                child: _buildCircularGauge(healthScore),
              ),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Quick Improvements
          _buildQuickImprovements(healthScore.quickImprovements, viewModel),
        ],
      ),
    );
  }

  Widget _buildCircularGauge(TaxHealthScoreModel healthScore) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
            ),
          ),
          // Progress circle
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              value: healthScore.scorePercentage / 100,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(healthScore.statusColor),
            ),
          ),
          // Score text
          Text(
            healthScore.formattedScore,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickImprovements(List<QuickImprovementModel> improvements, TaxWhispererViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Improvements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...improvements.map((improvement) => _buildQuickImprovementItem(improvement, viewModel)).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickImprovementItem(QuickImprovementModel improvement, TaxWhispererViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onQuickImprovementTap(improvement),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: improvement.isCompleted ? Colors.green : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                improvement.title,
                style: TextStyle(
                  fontSize: 14,
                  color: improvement.isCompleted ? Colors.grey : Colors.black87,
                  decoration: improvement.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxLiabilityForecastSection(TaxWhispererViewModel viewModel) {
    if (viewModel.taxLiabilityForecast == null) return const SizedBox.shrink();

    final forecast = viewModel.taxLiabilityForecast!;

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
            'Tax Liability Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bar chart
          SizedBox(
            height: 120,
            child: _buildBarChart(forecast.chartData),
          ),
          
          const SizedBox(height: 16),
          
          // Quarterly tax cards
          ...forecast.quarterlyTaxes.map((tax) => _buildQuarterlyTaxCard(tax, viewModel)).toList(),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data) {
    return CustomPaint(
      painter: BarChartPainter(data),
      size: const Size(double.infinity, 120),
    );
  }

  Widget _buildQuarterlyTaxCard(QuarterlyTaxModel tax, TaxWhispererViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onQuarterlyTaxTap(tax),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Calendar icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Tax details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tax.quarter} Payment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Due: ${tax.formattedDueDate}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Amount and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  tax.formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (tax.formattedChange.isNotEmpty)
                  Text(
                    tax.formattedChange,
                    style: TextStyle(
                      fontSize: 12,
                      color: tax.isDecrease ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedDeductionsSection(TaxWhispererViewModel viewModel) {
    if (viewModel.personalizedDeductions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalized Deductions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your spending.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Deduction cards
          ...viewModel.personalizedDeductions.map((deduction) => 
            _buildDeductionCard(deduction, viewModel)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildDeductionCard(PersonalizedDeductionModel deduction, TaxWhispererViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onDeductionTap(deduction),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: deduction.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    deduction.icon,
                    color: deduction.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deduction.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: deduction.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          deduction.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: deduction.statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Estimated value
                Text(
                  deduction.formattedValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              deduction.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => viewModel.learnMoreAboutDeduction(deduction.title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deduction.actionColor,
                  foregroundColor: deduction.actionColor == Colors.grey ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  deduction.actionText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tax Whisperer'),
          content: const Text(
            'Tax Whisperer helps you optimize your tax situation by providing personalized insights and recommendations based on your financial data.',
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

// Custom painter for bar chart
class BarChartPainter extends CustomPainter {
  final List<double> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / data.length - 8;
    
    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * size.height;
      final x = i * (barWidth + 8);
      final y = size.height - barHeight;
      
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
      
      // Draw quarter labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Q${i + 1}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 