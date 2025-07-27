import 'package:flutter/material.dart';
import '../models/goal_planning_model.dart';
import '../services/goal_planning_service.dart';

enum GoalPlanningViewState { initial, loading, loaded, error }

class GoalPlanningViewModel extends ChangeNotifier {
  final GoalPlanningService _service = GoalPlanningService();

  GoalPlanningViewState _state = GoalPlanningViewState.initial;
  GoalPlanningModel? _data;
  String? _selectedGoalId;
  String? _errorMessage;

  // Getters
  GoalPlanningViewState get state => _state;
  GoalPlanningModel? get data => _data;
  String? get selectedGoalId => _selectedGoalId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == GoalPlanningViewState.loading;

  GoalDetail? get selectedGoalDetail {
    if (_data == null || _selectedGoalId == null) return null;
    return _data!.goalDetails.firstWhere(
      (goal) => goal.id == _selectedGoalId,
      orElse: () => _data!.goalDetails.first,
    );
  }

  // Initialize data
  Future<void> initializeData() async {
    if (_state == GoalPlanningViewState.initial) {
      _state = GoalPlanningViewState.loading;
      notifyListeners();

      try {
        _data = await _service.getGoalPlanningData();
        _selectedGoalId = _data!.goalDetails.first.id;
        _state = GoalPlanningViewState.loaded;
      } catch (e) {
        _errorMessage = e.toString();
        _state = GoalPlanningViewState.error;
      }

      notifyListeners();
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == GoalPlanningViewState.loading) return;
    
    _setState(GoalPlanningViewState.loading);
    
    try {
      final jsonData = await _service.getAllGoalPlanningData();
      final goalPlanningData = jsonData['goalPlanning'] as Map<String, dynamic>;
      
      // Parse financial health summary
      final financialHealthData = goalPlanningData['financialHealth'] as Map<String, dynamic>;
      final financialHealth = FinancialHealthSummary(
        status: financialHealthData['status'] as String,
        totalGoals: financialHealthData['totalGoals'] as int,
        monthlyContribution: (financialHealthData['monthlyContribution'] as num).toDouble(),
        completionPercentage: (financialHealthData['completionPercentage'] as num).toDouble(),
      );
      
      // Parse goals overview
      final goalsOverviewData = goalPlanningData['goalsOverview'] as List;
      final goalsOverview = goalsOverviewData
          .map((goal) => GoalOverview(
                id: goal['id'] as String,
                name: goal['name'] as String,
                icon: _parseIcon(goal['icon'] as Map<String, dynamic>),
                progress: (goal['progress'] as num).toDouble(),
                target: (goal['target'] as num).toDouble(),
                color: _parseColor(goal['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Parse goal details
      final goalDetailsData = goalPlanningData['goalDetails'] as List;
      final goalDetails = goalDetailsData
          .map((goal) => GoalDetail(
                id: goal['id'] as String,
                name: goal['name'] as String,
                currentSavings: (goal['currentSavings'] as num).toDouble(),
                monthlyContribution: (goal['monthlyContribution'] as num).toDouble(),
                targetDate: goal['targetDate'] as int,
                probabilityOfSuccess: (goal['probabilityOfSuccess'] as num).toDouble(),
                projectedGrowth: (goal['projectedGrowth'] as List)
                    .map((growth) => ProjectedGrowthPoint(
                          year: growth['year'] as int,
                          conservative: (growth['conservative'] as num).toDouble(),
                          expected: (growth['expected'] as num).toDouble(),
                          optimistic: (growth['optimistic'] as num).toDouble(),
                        ))
                    .toList(),
              ))
          .toList();
      
      // Parse recommendations
      final recommendationsData = goalPlanningData['recommendations'] as List;
      final recommendations = recommendationsData
          .map((rec) => Recommendation(
                id: rec['id'] as String,
                description: rec['description'] as String,
                improvementPercentage: (rec['improvementPercentage'] as num).toDouble(),
              ))
          .toList();
      
      _data = GoalPlanningModel(
        financialHealth: financialHealth,
        goalsOverview: goalsOverview,
        goalDetails: goalDetails,
        recommendations: recommendations,
      );
      
      _selectedGoalId = _data!.goalDetails.first.id;
      _setState(GoalPlanningViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load goal planning data from JSON: ${e.toString()}';
      _setState(GoalPlanningViewState.error);
    }
  }

  // Helper method to parse icon from JSON
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Helper method to parse color from JSON
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  // Helper method to set state
  void _setState(GoalPlanningViewState newState) {
    _state = newState;
    notifyListeners();
  }

  // Set selected goal
  void setSelectedGoal(String goalId) {
    _selectedGoalId = goalId;
    notifyListeners();
  }

  // Apply recommendation
  Future<void> applyRecommendation(String recommendationId) async {
    try {
      await _service.applyRecommendation(recommendationId);
      // Refresh data after applying recommendation
      await refreshData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    _state = GoalPlanningViewState.loading;
    notifyListeners();

    try {
      _data = await _service.getGoalPlanningData();
      _state = GoalPlanningViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = GoalPlanningViewState.error;
    }

    notifyListeners();
  }
} 