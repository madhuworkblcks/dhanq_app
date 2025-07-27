import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/goal_planning_model.dart';

class GoalPlanningService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load goal planning data from JSON file
  Future<Map<String, dynamic>> _loadGoalPlanningData() async {
    try {
      // load from http url https://dhanqserv-43683479109.us-central1.run.app/api/goal-planning/12345
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/goal-planner/12345',
        ),
      );
      // load from assets/goal_planning.json
      // final jsonString = await rootBundle.loadString('assets/goal_planning.json');
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load goal planning data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'goalPlanning': {
        'financialHealth': {
          'status': 'Good',
          'totalGoals': 3,
          'monthlyContribution': 2850,
          'completionPercentage': 70,
        },
        'goalsOverview': [
          {
            'id': 'retirement',
            'name': 'Retirement',
            'icon': {
              'codePoint': 59530,
              'fontFamily': 'MaterialIcons',
              'fontPackage': null,
              'matchTextDirection': false,
            },
            'progress': 780000,
            'target': 1200000,
            'color': {
              'value': 4281545523,
              'alpha': 255,
              'red': 139,
              'green': 69,
              'blue': 19,
              'opacity': 1.0,
            },
          },
        ],
      },
    };
  }

  // Helper method to convert JSON icon to Flutter IconData
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Helper method to convert JSON color to Flutter Color
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  Future<GoalPlanningModel> getGoalPlanningData() async {
    await _simulateDelay();

    final jsonData = await _loadGoalPlanningData();
    final goalPlanningData = jsonData['goalPlanning'] as Map<String, dynamic>;

    // Parse financial health summary
    final financialHealthData =
        goalPlanningData['financialHealth'] as Map<String, dynamic>;
    final financialHealth = FinancialHealthSummary(
      status: financialHealthData['status'] as String,
      totalGoals: financialHealthData['totalGoals'] as int,
      monthlyContribution:
          (financialHealthData['monthlyContribution'] as num).toDouble(),
      completionPercentage:
          (financialHealthData['completionPercentage'] as num).toDouble(),
    );

    // Parse goals overview
    final goalsOverviewData = goalPlanningData['goalsOverview'] as List;
    final goalsOverview =
        goalsOverviewData
            .map(
              (goal) => GoalOverview(
                id: goal['id'] as String,
                name: goal['name'] as String,
                icon: _parseIcon(goal['icon'] as Map<String, dynamic>),
                progress: (goal['progress'] as num).toDouble(),
                target: (goal['target'] as num).toDouble(),
                color: _parseColor(goal['color'] as Map<String, dynamic>),
              ),
            )
            .toList();

    // Parse goal details
    final goalDetailsData = goalPlanningData['goalDetails'] as List;
    final goalDetails =
        goalDetailsData
            .map(
              (goal) => GoalDetail(
                id: goal['id'] as String,
                name: goal['name'] as String,
                currentSavings: (goal['currentSavings'] as num).toDouble(),
                monthlyContribution:
                    (goal['monthlyContribution'] as num).toDouble(),
                targetDate: goal['targetDate'] as int,
                probabilityOfSuccess:
                    (goal['probabilityOfSuccess'] as num).toDouble(),
                projectedGrowth:
                    (goal['projectedGrowth'] as List)
                        .map(
                          (growth) => ProjectedGrowthPoint(
                            year: growth['year'] as int,
                            conservative:
                                (growth['conservative'] as num).toDouble(),
                            expected: (growth['expected'] as num).toDouble(),
                            optimistic:
                                (growth['optimistic'] as num).toDouble(),
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();

    // Parse recommendations
    final recommendationsData = goalPlanningData['recommendations'] as List;
    final recommendations =
        recommendationsData
            .map(
              (rec) => Recommendation(
                id: rec['id'] as String,
                description: rec['description'] as String,
                improvementPercentage:
                    (rec['improvementPercentage'] as num).toDouble(),
              ),
            )
            .toList();

    return GoalPlanningModel(
      financialHealth: financialHealth,
      goalsOverview: goalsOverview,
      goalDetails: goalDetails,
      recommendations: recommendations,
    );
  }

  // Load all goal planning data at once
  Future<Map<String, dynamic>> getAllGoalPlanningData() async {
    await _simulateDelay();
    return await _loadGoalPlanningData();
  }

  Future<void> applyRecommendation(String recommendationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate applying recommendation
  }
}
