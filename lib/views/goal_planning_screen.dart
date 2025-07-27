import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_planning_model.dart';
import '../viewmodels/goal_planning_viewmodel.dart';

class GoalPlanningScreen extends StatefulWidget {
  const GoalPlanningScreen({super.key});

  @override
  State<GoalPlanningScreen> createState() => _GoalPlanningScreenState();
}

class _GoalPlanningScreenState extends State<GoalPlanningScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoalPlanningViewModel(),
      child: Consumer<GoalPlanningViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == GoalPlanningViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: _buildAppBar(),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Goal Planning',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black87),
          onPressed: () {
            // Handle settings
          },
        ),
      ],
    );
  }

  Widget _buildBody(GoalPlanningViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      );
    }

    if (viewModel.state == GoalPlanningViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.data == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialHealthCard(viewModel.data!.financialHealth),
          const SizedBox(height: 24),
          _buildGoalsOverviewSection(viewModel),
          const SizedBox(height: 24),
          _buildGoalDetailsSection(viewModel),
          const SizedBox(height: 24),
          _buildRecommendationsSection(viewModel),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard(FinancialHealthSummary health) {
    return Container(
      width: double.infinity,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health: ${health.status}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Goals: ${health.totalGoals}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monthly Contribution: ₹${health.monthlyContribution.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: health.completionPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E3A8A), // Blue color
                    ),
                  ),
                ),
                Text(
                  '${health.completionPercentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsOverviewSection(GoalPlanningViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goals Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.data!.goalsOverview.length,
            itemBuilder: (context, index) {
              final goal = viewModel.data!.goalsOverview[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      children: [
                        Icon(
                          goal.icon,
                          color: const Color(0xFF1E3A8A), // Blue color
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${goal.progress.toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A), // Blue color
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1E3A8A), // Blue color
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                                                 'Target: ₹${(goal.target / 1000).toStringAsFixed(0)}K',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalDetailsSection(GoalPlanningViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildGoalTabs(viewModel),
        const SizedBox(height: 16),
        if (viewModel.selectedGoalDetail != null)
          _buildGoalDetailCard(viewModel.selectedGoalDetail!),
      ],
    );
  }

  Widget _buildGoalTabs(GoalPlanningViewModel viewModel) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.data!.goalDetails.length,
        itemBuilder: (context, index) {
          final goal = viewModel.data!.goalDetails[index];
          final isSelected = viewModel.selectedGoalId == goal.id;

          return GestureDetector(
            onTap: () => viewModel.setSelectedGoal(goal.id),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF1E3A8A) // Blue when selected
                        : Colors.grey[50], // Light grey when not selected
                borderRadius: BorderRadius.circular(20),
                border:
                    isSelected ? null : Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalDetailCard(GoalDetail goal) {
    return Container(
      width: double.infinity,
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
              Expanded(
                child: _buildDetailItem(
                  'Current Savings',
                                       '₹${(goal.currentSavings / 1000).toStringAsFixed(0)}K',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Monthly Contribution',
                                     '₹${goal.monthlyContribution.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Target Date',
                  goal.targetDate.toString(),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Probability of Success',
                  '${goal.probabilityOfSuccess.toInt()}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Projected Growth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _buildProjectedGrowthChart(goal.projectedGrowth),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectedGrowthChart(List<ProjectedGrowthPoint> data) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: ProjectedGrowthChartPainter(data),
    );
  }

  Widget _buildRecommendationsSection(GoalPlanningViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...viewModel.data!.recommendations.map(
          (recommendation) =>
              _buildRecommendationCard(recommendation, viewModel),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    Recommendation recommendation,
    GoalPlanningViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A), // Blue color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => viewModel.applyRecommendation(recommendation.id),
              child: const Text(
                'Apply',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectedGrowthChartPainter extends CustomPainter {
  final List<ProjectedGrowthPoint> data;

  ProjectedGrowthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final conservativePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF1E3A8A); // Blue

    final expectedPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF3B82F6); // Light blue

    final optimisticPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF10B981); // Green

    final textPaint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    // Find min and max values for scaling
    double minValue = double.infinity;
    double maxValue = 0;

    for (final point in data) {
      minValue = [
        minValue,
        point.conservative,
        point.expected,
        point.optimistic,
      ].reduce((a, b) => a < b ? a : b);
      maxValue = [
        maxValue,
        point.conservative,
        point.expected,
        point.optimistic,
      ].reduce((a, b) => a > b ? a : b);
    }

    final width = size.width;
    final height = size.height;
    final padding = 40.0;

    // Draw grid lines
    paint.color = Colors.grey[300]!;
    paint.strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (height - 2 * padding) * i / 4;
      canvas.drawLine(Offset(padding, y), Offset(width - padding, y), paint);
    }

    // Draw Y-axis labels
    final textStyle = TextStyle(color: Colors.black87, fontSize: 10);

    for (int i = 0; i <= 4; i++) {
      final value = maxValue - (maxValue - minValue) * i / 4;
      final y = padding + (height - 2 * padding) * i / 4;
      final textSpan = TextSpan(
                         text: '₹${(value / 1000).toStringAsFixed(0)}K',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Draw lines
    _drawLine(
      canvas,
      data,
      conservativePaint,
      width,
      height,
      padding,
      minValue,
      maxValue,
      (point) => point.conservative,
    );
    _drawLine(
      canvas,
      data,
      expectedPaint,
      width,
      height,
      padding,
      minValue,
      maxValue,
      (point) => point.expected,
    );
    _drawLine(
      canvas,
      data,
      optimisticPaint,
      width,
      height,
      padding,
      minValue,
      maxValue,
      (point) => point.optimistic,
    );

    // Draw legend
    final legendY = height - 20;
    final legendItems = [
      {'color': const Color(0xFF1E3A8A), 'label': 'Conservative'},
      {'color': const Color(0xFF3B82F6), 'label': 'Expected'},
      {'color': const Color(0xFF10B981), 'label': 'Optimistic'},
    ];

    double legendX = padding;
    for (final item in legendItems) {
      // Draw colored dot
      final dotPaint =
          Paint()
            ..color = item['color'] as Color
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(legendX, legendY), 4, dotPaint);

      // Draw label
      final textSpan = TextSpan(
        text: item['label'] as String,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(legendX + 8, legendY - textPainter.height / 2),
      );

      legendX += textPainter.width + 20;
    }
  }

  void _drawLine(
    Canvas canvas,
    List<ProjectedGrowthPoint> data,
    Paint paint,
    double width,
    double height,
    double padding,
    double minValue,
    double maxValue,
    double Function(ProjectedGrowthPoint) valueSelector,
  ) {
    final path = Path();
    bool first = true;

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final value = valueSelector(point);
      final x = padding + (width - 2 * padding) * i / (data.length - 1);
      final y =
          padding +
          (height - 2 * padding) *
              (1 - (value - minValue) / (maxValue - minValue));

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
