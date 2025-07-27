import 'package:flutter/material.dart';
import '../models/debt_doctor_model.dart';
import '../services/debt_doctor_service.dart';

enum DebtDoctorViewState {
  initial,
  loading,
  loaded,
  error,
}

class DebtDoctorViewModel extends ChangeNotifier {
  final DebtDoctorService _service = DebtDoctorService();
  
  DebtDoctorViewState _state = DebtDoctorViewState.initial;
  String? _errorMessage;
  DebtDoctorModel? _debtDoctorData;
  
  // Legacy data for backward compatibility
  DebtOverviewModel? _debtOverview;
  DebtBreakdownModel? _debtBreakdown;
  List<RepaymentStrategyModel>? _repaymentStrategies;
  CreditScoreModel? _creditScore;
  CreditScoreFactorsModel? _creditScoreFactors;
  
  // Getters
  DebtDoctorViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == DebtDoctorViewState.loading;
  
  // New getters for unified data model
  DebtDoctorModel? get debtDoctorData => _debtDoctorData;
  DebtOverviewModel? get debtOverview => _debtDoctorData?.debtOverview ?? _debtOverview;
  DebtBreakdownModel? get debtBreakdown => _debtBreakdown;
  List<DebtModel> get debts => _debtDoctorData?.debts ?? [];
  List<RepaymentStrategyModel> get repaymentStrategies => _debtDoctorData?.repaymentStrategies ?? _repaymentStrategies ?? [];
  CreditScoreModel? get creditScore => _debtDoctorData?.creditScore ?? _creditScore;
  List<CreditScoreFactor> get creditScoreFactors => _debtDoctorData?.creditScore.factors ?? _creditScoreFactors?.factors ?? [];
  List<InsightModel> get insights => _debtDoctorData?.insights ?? [];
  
  // Legacy getters for backward compatibility
  DebtBreakdownModel? get debtBreakdownModel => _debtBreakdown;
  List<RepaymentStrategyModel>? get repaymentStrategiesModel => _repaymentStrategies;
  CreditScoreFactorsModel? get creditScoreFactorsModel => _creditScoreFactors;
  
  // Create RepaymentStrategiesModel from list for UI compatibility
  RepaymentStrategiesModel? get repaymentStrategiesModelForUI {
    final strategies = repaymentStrategies;
    if (strategies.length >= 2) {
      return RepaymentStrategiesModel(
        avalanche: strategies.firstWhere((s) => s.name.toLowerCase().contains('avalanche'), orElse: () => strategies[0]),
        snowball: strategies.firstWhere((s) => s.name.toLowerCase().contains('snowball'), orElse: () => strategies[1]),
        recommendation: strategies.first.recommendation,
        savings: strategies.first.savings,
        timeSaved: strategies.first.timeSaved,
      );
    }
    return null;
  }
  
  // Create CreditScoreFactorsModel from list for UI compatibility
  CreditScoreFactorsModel? get creditScoreFactorsModelForUI {
    final factors = creditScoreFactors;
    if (factors.isNotEmpty) {
      return CreditScoreFactorsModel(factors: factors);
    }
    return null;
  }
  
  // Initialize data
  Future<void> initializeData() async {
    if (_state == DebtDoctorViewState.initial) {
      _state = DebtDoctorViewState.loading;
      notifyListeners();
      
      try {
        _debtDoctorData = await _service.getDebtDoctorData();
        
        // Load legacy data for backward compatibility
        await Future.wait([
          _loadLegacyData(),
        ]);
        
        _state = DebtDoctorViewState.loaded;
      } catch (e) {
        _errorMessage = 'Failed to load debt data: ${e.toString()}';
        _state = DebtDoctorViewState.error;
      }
      notifyListeners();
    }
  }

  // Load legacy data for backward compatibility
  Future<void> _loadLegacyData() async {
    try {
      _debtOverview = await _service.getDebtOverview();
      
      // Create DebtBreakdownModel from the new data structure
      if (_debtDoctorData != null) {
        final breakdownMap = _debtDoctorData!.debtBreakdown;
        final totalAmount = _debtDoctorData!.debtOverview.totalDebt;
        final items = breakdownMap.entries.map((entry) => DebtBreakdownItem(
          type: entry.key,
          amount: totalAmount * entry.value / 100,
          color: _getCategoryColor(entry.key),
          percentage: entry.value,
        )).toList();
        _debtBreakdown = DebtBreakdownModel(items: items, totalAmount: totalAmount);
      } else {
        _debtBreakdown = await _service.getDebtBreakdown();
      }
      
      _repaymentStrategies = await _service.getRepaymentStrategies();
      _creditScore = await _service.getCreditScore();
      final factors = await _service.getCreditScoreFactors();
      _creditScoreFactors = CreditScoreFactorsModel(factors: factors);
    } catch (e) {
      print('Legacy data loading failed: $e');
    }
  }

  // Helper method to get color for debt category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'creditCards':
        return Colors.red;
      case 'personalLoans':
        return Colors.orange;
      case 'homeLoan':
        return Colors.blue;
      case 'studentLoan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  // Refresh data
  Future<void> refreshData() async {
    _state = DebtDoctorViewState.loading;
    notifyListeners();
    await initializeData();
  }
  
  // Apply avalanche strategy
  Future<void> applyAvalancheStrategy() async {
    try {
      await _service.applyAvalancheStrategy();
      // You could show a success message or update the UI here
    } catch (e) {
      _errorMessage = 'Failed to apply strategy: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Handle debt breakdown item tap
  void onDebtBreakdownItemTap(DebtBreakdownItem item) {
    // Handle tap on debt breakdown item
    print('Tapped on ${item.type}: ${item.formattedAmount}');
  }
  
  // Handle repayment strategy tap
  void onRepaymentStrategyTap(RepaymentStrategyModel strategy) {
    // Handle tap on repayment strategy
    print('Tapped on ${strategy.name}');
  }
  
  // Handle credit score factor tap
  void onCreditScoreFactorTap(CreditScoreFactor factor) {
    // Handle tap on credit score factor
    print('Tapped on ${factor.factor}: ${factor.impact}');
  }

  // Handle debt tap
  void onDebtTap(DebtModel debt) {
    // Handle tap on individual debt
    print('Tapped on ${debt.name}: ${debt.formattedBalance}');
  }

  // Handle insight tap
  void onInsightTap(InsightModel insight) {
    // Handle tap on insight
    print('Tapped on insight: ${insight.title}');
  }
} 