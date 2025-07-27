import 'package:flutter/material.dart';
import '../models/financial_health_score_model.dart';
import '../services/financial_health_score_service.dart';

enum FinancialHealthScoreViewState {
  initial,
  loading,
  loaded,
  error,
}

class FinancialHealthScoreViewModel extends ChangeNotifier {
  final FinancialHealthScoreService _service = FinancialHealthScoreService();
  
  FinancialHealthScoreViewState _state = FinancialHealthScoreViewState.initial;
  String? _errorMessage;
  
  // Data models
  FinancialHealthScoreModel? _financialHealthScore;
  List<KeyMetricModel> _keyMetrics = [];
  List<ScoreBreakdownModel> _scoreBreakdown = [];
  List<FinancialInsightModel> _financialInsights = [];
  MonthlyTrendModel? _monthlyTrend;
  LanguageType _selectedLanguage = LanguageType.english;
  
  // Getters
  FinancialHealthScoreViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == FinancialHealthScoreViewState.loading;
  
  FinancialHealthScoreModel? get financialHealthScore => _financialHealthScore;
  List<KeyMetricModel> get keyMetrics => _keyMetrics;
  List<ScoreBreakdownModel> get scoreBreakdown => _scoreBreakdown;
  List<FinancialInsightModel> get financialInsights => _financialInsights;
  MonthlyTrendModel? get monthlyTrend => _monthlyTrend;
  LanguageType get selectedLanguage => _selectedLanguage;
  
  // Initialize data
  Future<void> initializeData() async {
    if (_state == FinancialHealthScoreViewState.loading) return;
    
    _setState(FinancialHealthScoreViewState.loading);
    
    try {
      // Load all data concurrently
      final results = await Future.wait([
        _service.getFinancialHealthScore(),
        _service.getKeyMetrics(),
        _service.getScoreBreakdown(),
        _service.getFinancialInsights(),
        _service.getMonthlyTrend(),
      ]);
      
      _financialHealthScore = results[0] as FinancialHealthScoreModel;
      _keyMetrics = results[1] as List<KeyMetricModel>;
      _scoreBreakdown = results[2] as List<ScoreBreakdownModel>;
      _financialInsights = results[3] as List<FinancialInsightModel>;
      _monthlyTrend = results[4] as MonthlyTrendModel;
      
      _setState(FinancialHealthScoreViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load financial health data: ${e.toString()}';
      _setState(FinancialHealthScoreViewState.error);
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == FinancialHealthScoreViewState.loading) return;
    
    _setState(FinancialHealthScoreViewState.loading);
    
    try {
      final jsonData = await _service.getAllFinancialHealthScoreData();
      
      // Load financial health score
      final healthScoreData = jsonData['financialHealthScore'] as Map<String, dynamic>;
      _financialHealthScore = FinancialHealthScoreModel(
        score: healthScoreData['score'] as int,
        maxScore: healthScoreData['maxScore'] as int,
        status: healthScoreData['status'] as String,
        statusColor: _parseColor(healthScoreData['statusColor'] as Map<String, dynamic>),
        description: healthScoreData['description'] as String,
      );
      
      // Load key metrics
      final keyMetricsData = jsonData['keyMetrics'] as List;
      _keyMetrics = keyMetricsData
          .map((metric) => KeyMetricModel(
                label: metric['label'] as String,
                value: metric['value'] as String,
                trend: metric['trend'] as String?,
                isPositiveTrend: metric['isPositiveTrend'] as bool,
                icon: _parseIcon(metric['icon'] as Map<String, dynamic>),
                status: metric['status'] as String?,
              ))
          .toList();
      
      // Load score breakdown
      final breakdownData = jsonData['scoreBreakdown'] as List;
      _scoreBreakdown = breakdownData
          .map((breakdown) => ScoreBreakdownModel(
                category: breakdown['category'] as String,
                percentage: (breakdown['percentage'] as num).toDouble(),
                color: _parseColor(breakdown['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Load financial insights
      final insightsData = jsonData['financialInsights'] as List;
      _financialInsights = insightsData
          .map((insight) => FinancialInsightModel(
                text: insight['text'] as String,
                icon: _parseIcon(insight['icon'] as Map<String, dynamic>),
                iconColor: _parseColor(insight['iconColor'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Load monthly trend
      final trendData = jsonData['monthlyTrend'] as Map<String, dynamic>;
      _monthlyTrend = MonthlyTrendModel(
        data: (trendData['data'] as List)
            .map((data) => (data as num).toDouble())
            .toList(),
        labels: (trendData['labels'] as List)
            .map((label) => label as String)
            .toList(),
      );
      
      _setState(FinancialHealthScoreViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load financial health data from JSON: ${e.toString()}';
      _setState(FinancialHealthScoreViewState.error);
    }
  }

  // Helper method to parse color from JSON
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  // Helper method to parse icon from JSON
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(iconJson['codePoint'] as int, fontFamily: iconJson['fontFamily'] as String);
  }
  
  // Refresh data
  Future<void> refreshData() async {
    _financialHealthScore = null;
    _keyMetrics = [];
    _scoreBreakdown = [];
    _financialInsights = [];
    _monthlyTrend = null;
    await initializeData();
  }
  
  // Apply financial optimization
  Future<void> applyFinancialOptimization() async {
    try {
      await _service.applyFinancialOptimization();
      // You could show a success message or update the UI here
    } catch (e) {
      _errorMessage = 'Failed to apply financial optimization: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Get detailed insight
  Future<void> getDetailedInsight(String insightType) async {
    try {
      await _service.getDetailedInsight(insightType);
      // You could show more details or navigate to a detail screen
    } catch (e) {
      _errorMessage = 'Failed to load detailed insight: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Language switching
  void setLanguage(LanguageType language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Handle key metric tap
  void onKeyMetricTap(KeyMetricModel metric) {
    // Handle tap on key metric
    print('Tapped on metric: ${metric.label}');
  }
  
  // Handle score breakdown tap
  void onScoreBreakdownTap(ScoreBreakdownModel breakdown) {
    // Handle tap on score breakdown
    print('Tapped on breakdown: ${breakdown.category}');
  }
  
  // Handle financial insight tap
  void onFinancialInsightTap(FinancialInsightModel insight) {
    // Handle tap on financial insight
    print('Tapped on insight: ${insight.text}');
  }
  
  // Private methods
  void _setState(FinancialHealthScoreViewState newState) {
    _state = newState;
    notifyListeners();
  }
} 