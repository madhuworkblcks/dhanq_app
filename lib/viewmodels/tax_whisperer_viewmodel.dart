import 'package:flutter/material.dart';

import '../models/tax_whisperer_model.dart';
import '../services/tax_whisperer_service.dart';

enum TaxWhispererViewState { initial, loading, loaded, error }

class TaxWhispererViewModel extends ChangeNotifier {
  final TaxWhispererService _service = TaxWhispererService();

  TaxWhispererViewState _state = TaxWhispererViewState.initial;
  String? _errorMessage;

  // Data models
  TaxHealthScoreModel? _taxHealthScore;
  TaxLiabilityForecastModel? _taxLiabilityForecast;
  List<PersonalizedDeductionModel> _personalizedDeductions = [];

  // Getters
  TaxWhispererViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TaxWhispererViewState.loading;

  TaxHealthScoreModel? get taxHealthScore => _taxHealthScore;
  TaxLiabilityForecastModel? get taxLiabilityForecast => _taxLiabilityForecast;
  List<PersonalizedDeductionModel> get personalizedDeductions =>
      _personalizedDeductions;

  // Initialize data
  Future<void> initializeData() async {
    if (_state == TaxWhispererViewState.loading) return;

    _setState(TaxWhispererViewState.loading);

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _service.getTaxHealthScore(),
        _service.getTaxLiabilityForecast(),
        _service.getPersonalizedDeductions(),
      ]);

      _taxHealthScore = results[0] as TaxHealthScoreModel;
      _taxLiabilityForecast = results[1] as TaxLiabilityForecastModel;
      _personalizedDeductions = results[2] as List<PersonalizedDeductionModel>;

      _setState(TaxWhispererViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load tax data: ${e.toString()}';
      _setState(TaxWhispererViewState.error);
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == TaxWhispererViewState.loading) return;

    _setState(TaxWhispererViewState.loading);

    try {
      final jsonData = await _service.getAllTaxWhispererData();

      // Load tax health score
      final taxHealthScoreData =
          jsonData['taxHealthScore'] as Map<String, dynamic>;
      _taxHealthScore = TaxHealthScoreModel(
        score: taxHealthScoreData['score'] as int,
        maxScore: taxHealthScoreData['maxScore'] as int,
        status: taxHealthScoreData['status'] as String,
        statusColor: _parseColor(
          taxHealthScoreData['statusColor'] as Map<String, dynamic>,
        ),
        description: taxHealthScoreData['description'] as String,
        quickImprovements:
            (taxHealthScoreData['quickImprovements'] as List)
                .map(
                  (improvement) => QuickImprovementModel(
                    title: improvement['title'] as String,
                    isCompleted: improvement['isCompleted'] as bool,
                  ),
                )
                .toList(),
      );

      // Load tax liability forecast
      final forecastData =
          jsonData['taxLiabilityForecast'] as Map<String, dynamic>;
      _taxLiabilityForecast = TaxLiabilityForecastModel(
        quarterlyTaxes:
            (forecastData['quarterlyTaxes'] as List).map((tax) {
              final dueDateData = tax['dueDate'] as Map<String, dynamic>;
              return QuarterlyTaxModel(
                quarter: tax['quarter'] as String,
                dueDate: DateTime(
                  dueDateData['year'] as int,
                  dueDateData['month'] as int,
                  dueDateData['day'] as int,
                ),
                amount: (tax['amount'] as num).toDouble(),
                percentageChange:
                    tax['percentageChange'] != null
                        ? (tax['percentageChange'] as num).toDouble()
                        : null,
                isDecrease: tax['isDecrease'] as bool,
              );
            }).toList(),
        chartData:
            (forecastData['chartData'] as List)
                .map((data) => (data as num).toDouble())
                .toList(),
      );

      // Load personalized deductions
      final deductionsData = jsonData['personalizedDeductions'] as List;
      _personalizedDeductions =
          deductionsData
              .map(
                (deduction) => PersonalizedDeductionModel(
                  title: deduction['title'] as String,
                  description: deduction['description'] as String,
                  estimatedValue:
                      (deduction['estimatedValue'] as num).toDouble(),
                  status: deduction['status'] as String,
                  statusColor: _parseColor(
                    deduction['statusColor'] as Map<String, dynamic>,
                  ),
                  actionText: deduction['actionText'] as String,
                  actionColor: _parseColor(
                    deduction['actionColor'] as Map<String, dynamic>,
                  ),
                  icon: _parseIcon(deduction['icon'] as Map<String, dynamic>),
                ),
              )
              .toList();

      _setState(TaxWhispererViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load tax data from JSON: ${e.toString()}';
      _setState(TaxWhispererViewState.error);
    }
  }

  // Helper method to parse color from JSON
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  // Helper method to parse icon from JSON
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Helper method to set state
  void _setState(TaxWhispererViewState state) {
    _state = state;
    notifyListeners();
  }

  // Refresh data
  Future<void> refreshData() async {
    _taxHealthScore = null;
    _taxLiabilityForecast = null;
    _personalizedDeductions = [];
    await initializeData();
  }

  // Apply tax optimization
  Future<void> applyTaxOptimization() async {
    try {
      await _service.applyTaxOptimization();
      // You could show a success message or update the UI here
    } catch (e) {
      _errorMessage = 'Failed to apply tax optimization: ${e.toString()}';
      notifyListeners();
    }
  }

  // Learn more about deduction
  Future<void> learnMoreAboutDeduction(String deductionType) async {
    try {
      await _service.learnMoreAboutDeduction(deductionType);
      // You could show more details or navigate to a detail screen
    } catch (e) {
      _errorMessage = 'Failed to load deduction details: ${e.toString()}';
      notifyListeners();
    }
  }

  // Handle quick improvement tap
  void onQuickImprovementTap(QuickImprovementModel improvement) {
    // Handle tap on quick improvement
    print('Tapped on improvement: ${improvement.title}');
  }

  // Handle quarterly tax tap
  void onQuarterlyTaxTap(QuarterlyTaxModel tax) {
    // Handle tap on quarterly tax
    print('Tapped on ${tax.quarter}: ${tax.formattedAmount}');
  }

  // Handle deduction tap
  void onDeductionTap(PersonalizedDeductionModel deduction) {
    // Handle tap on deduction
    print('Tapped on ${deduction.title}: ${deduction.formattedValue}');
  }
}
