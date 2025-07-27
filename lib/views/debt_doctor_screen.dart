import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt_doctor_model.dart';
import '../viewmodels/debt_doctor_viewmodel.dart';

class DebtDoctorScreen extends StatefulWidget {
  const DebtDoctorScreen({super.key});

  @override
  State<DebtDoctorScreen> createState() => _DebtDoctorScreenState();
}

class _DebtDoctorScreenState extends State<DebtDoctorScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DebtDoctorViewModel(),
      child: Consumer<DebtDoctorViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == DebtDoctorViewState.initial) {
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

  Widget _buildBody(DebtDoctorViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == DebtDoctorViewState.error) {
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

            // Debt Repayment Strategies Section
            _buildDebtRepaymentSection(viewModel),

            // Credit Score Improvement Section
            _buildCreditScoreSection(viewModel),

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
              'Debt-Doctor',
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

  Widget _buildDebtRepaymentSection(DebtDoctorViewModel viewModel) {
    if (viewModel.debtOverview == null ||
        viewModel.debtBreakdown == null ||
        viewModel.repaymentStrategies == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Debt Repayment Strategies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Debt Overview Cards
          _buildDebtOverviewCards(viewModel.debtOverview!),
          const SizedBox(height: 20),

          // Debt Breakdown
          _buildDebtBreakdown(viewModel.debtBreakdown!),
          const SizedBox(height: 20),

          // Repayment Strategies
          if (viewModel.repaymentStrategiesModelForUI != null)
            _buildRepaymentStrategies(viewModel.repaymentStrategiesModelForUI!, viewModel),
        ],
      ),
    );
  }

  Widget _buildDebtOverviewCards(DebtOverviewModel overview) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Debt',
            overview.formattedTotalDebt,
            Colors.red,
            Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Interest Paid',
            overview.formattedInterestPaid,
            Colors.orange,
            Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Potential Savings',
            overview.formattedPotentialSavings,
            Colors.green,
            Icons.savings,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtBreakdown(DebtBreakdownModel breakdown) {
    return Container(
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
            'Debt Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal bar chart
          SizedBox(height: 40, child: _buildDebtBreakdownChart(breakdown)),

          const SizedBox(height: 16),

          // Legend
          ...breakdown.items
              .map((item) => _buildDebtBreakdownLegend(item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDebtBreakdownChart(DebtBreakdownModel breakdown) {
    return CustomPaint(
      painter: DebtBreakdownChartPainter(breakdown.items),
      size: const Size(double.infinity, 40),
    );
  }

  Widget _buildDebtBreakdownLegend(DebtBreakdownItem item) {
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
              item.type,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            item.formattedAmount,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentStrategies(
    RepaymentStrategiesModel strategies,
    DebtDoctorViewModel viewModel,
  ) {
    return Container(
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
            'Avalanche vs Snowball Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Strategy comparison
          Row(
            children: [
              Expanded(
                child: _buildStrategyCard(strategies.avalanche, viewModel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStrategyCard(strategies.snowball, viewModel),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Payoff chart
          SizedBox(height: 120, child: _buildPayoffChart(strategies)),

          const SizedBox(height: 16),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6D2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              strategies.recommendation,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => viewModel.applyAvalancheStrategy(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Avalanche Strategy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(
    RepaymentStrategyModel strategy,
    DebtDoctorViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onRepaymentStrategyTap(strategy),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: strategy.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: strategy.color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strategy.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: strategy.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strategy.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Interest: ${strategy.formattedInterest}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              'Payoff time: ${strategy.formattedPayoffTime}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoffChart(RepaymentStrategiesModel strategies) {
    return CustomPaint(
      painter: PayoffChartPainter(strategies.avalanche, strategies.snowball),
      size: const Size(double.infinity, 120),
    );
  }

  Widget _buildCreditScoreSection(DebtDoctorViewModel viewModel) {
    if (viewModel.creditScore == null || viewModel.creditScoreFactors == null) {
      return const SizedBox.shrink();
    }

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
          // Section Title with red accent
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Credit Score Improvement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Credit Score Display
          _buildCreditScoreDisplay(viewModel.creditScore!),
          const SizedBox(height: 20),

          // Credit Score Factors
          if (viewModel.creditScoreFactorsModelForUI != null)
            _buildCreditScoreFactors(viewModel.creditScoreFactorsModelForUI!, viewModel),
        ],
      ),
    );
  }

  Widget _buildCreditScoreDisplay(CreditScoreModel creditScore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Credit Score',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Score progress bar
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left:
                    (creditScore.scorePercentage / 100) *
                        (MediaQuery.of(context).size.width - 80) -
                    10,
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Score labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Poor', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Fair', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Good', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              'Excellent',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Current score and potential increase
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              creditScore.formattedScore,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  creditScore.formattedPotentialIncrease,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Credit score trend chart
        SizedBox(height: 80, child: _buildCreditScoreTrendChart(creditScore)),
      ],
    );
  }

  Widget _buildCreditScoreTrendChart(CreditScoreModel creditScore) {
    return CustomPaint(
      painter: CreditScoreTrendPainter(
        creditScore.trendData,
        creditScore.trendLabels,
      ),
      size: const Size(double.infinity, 80),
    );
  }

  Widget _buildCreditScoreFactors(
    CreditScoreFactorsModel factors,
    DebtDoctorViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Score Factors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        ...factors.factors
            .map((factor) => _buildCreditScoreFactor(factor, viewModel))
            .toList(),
      ],
    );
  }

  Widget _buildCreditScoreFactor(
    CreditScoreFactor factor,
    DebtDoctorViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onCreditScoreFactorTap(factor),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  factor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: factor.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    factor.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: factor.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Impact: ${factor.impact}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Contribution: ${factor.formattedContribution}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            LinearProgressIndicator(
              value: factor.contribution / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(factor.statusColor),
            ),
          ],
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
              const Text(
                'Menu Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Data'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<DebtDoctorViewModel>().refreshData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
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

// Custom painter for debt breakdown chart
class DebtBreakdownChartPainter extends CustomPainter {
  final List<DebtBreakdownItem> items;

  DebtBreakdownChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    double currentX = 0;

    for (final item in items) {
      final segmentWidth = (item.percentage / 100) * size.width;

      final paint =
          Paint()
            ..color = item.color
            ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, segmentWidth, size.height),
        paint,
      );

      currentX += segmentWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for payoff chart
class PayoffChartPainter extends CustomPainter {
  final RepaymentStrategyModel avalanche;
  final RepaymentStrategyModel snowball;

  PayoffChartPainter(this.avalanche, this.snowball);

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = 185000.0;
    final maxMonths = 72.0;

    // Draw grid lines
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 1;

    for (int i = 0; i <= 6; i++) {
      final y = (i / 6) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw avalanche line
    final avalanchePaint =
        Paint()
          ..color = avalanche.color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final avalanchePath = Path();
    for (int i = 0; i < avalanche.payoffData.length; i++) {
      final x = (i / (avalanche.payoffData.length - 1)) * size.width;
      final y = (avalanche.payoffData[i] / maxValue) * size.height;

      if (i == 0) {
        avalanchePath.moveTo(x, y);
      } else {
        avalanchePath.lineTo(x, y);
      }
    }
    canvas.drawPath(avalanchePath, avalanchePaint);

    // Draw snowball line
    final snowballPaint =
        Paint()
          ..color = snowball.color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final snowballPath = Path();
    for (int i = 0; i < snowball.payoffData.length; i++) {
      final x = (i / (snowball.payoffData.length - 1)) * size.width;
      final y = (snowball.payoffData[i] / maxValue) * size.height;

      if (i == 0) {
        snowballPath.moveTo(x, y);
      } else {
        snowballPath.lineTo(x, y);
      }
    }
    canvas.drawPath(snowballPath, snowballPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for credit score trend chart
class CreditScoreTrendPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  CreditScoreTrendPainter(this.data, this.labels);

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
