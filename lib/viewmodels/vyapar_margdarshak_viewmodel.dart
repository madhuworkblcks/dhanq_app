import 'package:flutter/material.dart';
import '../models/vyapar_margdarshak_model.dart';
import '../services/vyapar_margdarshak_service.dart';

enum VyaparMargdarshakViewState {
  initial,
  loading,
  loaded,
  error,
}

class VyaparMargdarshakViewModel extends ChangeNotifier {
  final VyaparMargdarshakService _service = VyaparMargdarshakService();
  
  VyaparMargdarshakViewState _state = VyaparMargdarshakViewState.initial;
  String? _errorMessage;
  LanguageType _selectedLanguage = LanguageType.english;
  BusinessTab _selectedTab = BusinessTab.businessHealth;
  
  // Data models
  BusinessSummaryModel? _todaySummary;
  MonthlyProfitModel? _monthlyProfit;
  List<QuickActionModel> _quickActions = [];
  BusinessGrowthModel? _businessGrowth;
  LoanOfferModel? _loanOffer;
  
  // Getters
  VyaparMargdarshakViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == VyaparMargdarshakViewState.loading;
  
  LanguageType get selectedLanguage => _selectedLanguage;
  BusinessTab get selectedTab => _selectedTab;
  BusinessSummaryModel? get todaySummary => _todaySummary;
  MonthlyProfitModel? get monthlyProfit => _monthlyProfit;
  List<QuickActionModel> get quickActions => _quickActions;
  BusinessGrowthModel? get businessGrowth => _businessGrowth;
  LoanOfferModel? get loanOffer => _loanOffer;
  
  // Initialize data
  Future<void> initializeData() async {
    if (_state == VyaparMargdarshakViewState.loading) return;
    
    _setState(VyaparMargdarshakViewState.loading);
    
    try {
      // Load all data concurrently
      final results = await Future.wait([
        _service.getTodaySummary(),
        _service.getMonthlyProfit(),
        _service.getQuickActions(),
        _service.getBusinessGrowth(),
        _service.getLoanOffer(),
      ]);
      
      _todaySummary = results[0] as BusinessSummaryModel;
      _monthlyProfit = results[1] as MonthlyProfitModel;
      _quickActions = results[2] as List<QuickActionModel>;
      _businessGrowth = results[3] as BusinessGrowthModel;
      _loanOffer = results[4] as LoanOfferModel;
      
      _setState(VyaparMargdarshakViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load Vyapar Margdarshak data: ${e.toString()}';
      _setState(VyaparMargdarshakViewState.error);
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == VyaparMargdarshakViewState.loading) return;
    
    _setState(VyaparMargdarshakViewState.loading);
    
    try {
      final jsonData = await _service.getAllVyaparMargdarshakData();
      
      // Load business summary
      final businessSummaryData = jsonData['businessSummary'] as Map<String, dynamic>;
      _todaySummary = BusinessSummaryModel(
        sales: (businessSummaryData['sales'] as num).toDouble(),
        expenses: (businessSummaryData['expenses'] as num).toDouble(),
        profit: (businessSummaryData['profit'] as num).toDouble(),
        date: _parseDate(businessSummaryData['date'] as String),
      );
      
      // Load monthly profit
      final monthlyProfitData = jsonData['monthlyProfit'] as Map<String, dynamic>;
      final profitDataList = monthlyProfitData['profitData'] as List;
      final profitData = profitDataList
          .map((data) => ProfitDataModel(
                month: data['month'] as String,
                profit: (data['profit'] as num).toDouble(),
                isCurrentMonth: data['isCurrentMonth'] as bool? ?? false,
              ))
          .toList();
      
      _monthlyProfit = MonthlyProfitModel(
        profitData: profitData,
        totalProfit: (monthlyProfitData['totalProfit'] as num).toDouble(),
      );
      
      // Load quick actions
      final quickActionsData = jsonData['quickActions'] as List;
      _quickActions = quickActionsData
          .map((action) => QuickActionModel(
                title: action['title'] as String,
                icon: _parseIcon(action['icon'] as Map<String, dynamic>),
                action: action['action'] as String,
              ))
          .toList();
      
      // Load business growth
      final businessGrowthData = jsonData['businessGrowth'] as Map<String, dynamic>;
      final metricsData = businessGrowthData['metrics'] as List;
      final metrics = metricsData
          .map((metric) => GrowthMetricModel(
                title: metric['title'] as String,
                percentage: (metric['percentage'] as num).toDouble(),
                comparison: metric['comparison'] as String,
                icon: _parseIcon(metric['icon'] as Map<String, dynamic>),
              ))
          .toList();
      
      _businessGrowth = BusinessGrowthModel(
        metrics: metrics,
      );
      
      // Load loan offer
      final loanOfferData = jsonData['loanOffer'] as Map<String, dynamic>;
      _loanOffer = LoanOfferModel(
        title: loanOfferData['title'] as String,
        description: loanOfferData['description'] as String,
        maxAmount: (loanOfferData['maxAmount'] as num).toDouble(),
        eligibility: loanOfferData['eligibility'] as String,
      );
      
      _setState(VyaparMargdarshakViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load Vyapar Margdarshak data from JSON: ${e.toString()}';
      _setState(VyaparMargdarshakViewState.error);
    }
  }

  // Helper method to parse date from JSON string
  DateTime _parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  // Helper method to parse icon from JSON
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }
  
  // Refresh data
  Future<void> refreshData() async {
    _todaySummary = null;
    _monthlyProfit = null;
    _quickActions = [];
    _businessGrowth = null;
    _loanOffer = null;
    await initializeData();
  }
  
  // Set language
  void setLanguage(LanguageType language) {
    _selectedLanguage = language;
    notifyListeners();
  }
  
  // Set selected tab
  void setSelectedTab(BusinessTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }
  
  // Handle quick actions
  Future<void> handleQuickAction(QuickActionModel action) async {
    try {
      switch (action.action) {
        case 'record_sale':
          await _service.recordSale(0.0, 'New sale');
          break;
        case 'record_expense':
          await _service.recordExpense(0.0, 'New expense');
          break;
        case 'add_inventory':
          await _service.addInventory('New item', 1, 0.0);
          break;
        case 'view_reports':
          await _service.viewReports();
          break;
      }
      // Refresh data after action
      await refreshData();
    } catch (e) {
      _errorMessage = 'Failed to perform action: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Apply for loan
  Future<void> applyForLoan() async {
    try {
      await _service.applyForLoan();
      // Handle loan application success
    } catch (e) {
      _errorMessage = 'Failed to apply for loan: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Check loan eligibility
  Future<void> checkLoanEligibility() async {
    try {
      await _service.checkEligibility();
      // Handle eligibility check
    } catch (e) {
      _errorMessage = 'Failed to check eligibility: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Get business health metrics
  Future<Map<String, dynamic>> getBusinessHealthMetrics() async {
    try {
      return await _service.getBusinessHealthMetrics();
    } catch (e) {
      _errorMessage = 'Failed to get business health metrics: ${e.toString()}';
      notifyListeners();
      return {};
    }
  }
  
  // Get finance options
  Future<List<Map<String, dynamic>>> getFinanceOptions() async {
    try {
      return await _service.getFinanceOptions();
    } catch (e) {
      _errorMessage = 'Failed to get finance options: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Get inventory data
  Future<List<Map<String, dynamic>>> getInventoryData() async {
    try {
      return await _service.getInventoryData();
    } catch (e) {
      _errorMessage = 'Failed to get inventory data: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  // Handle tab content based on selected tab
  Widget getTabContent() {
    switch (_selectedTab) {
      case BusinessTab.businessHealth:
        return _buildBusinessHealthContent();
      case BusinessTab.financeOptions:
        return _buildFinanceOptionsContent();
      case BusinessTab.inventory:
        return _buildInventoryContent();
    }
  }
  
  Widget _buildBusinessHealthContent() {
    return Container(); // Will be implemented in the UI
  }
  
  Widget _buildFinanceOptionsContent() {
    return Container(); // Will be implemented in the UI
  }
  
  Widget _buildInventoryContent() {
    return Container(); // Will be implemented in the UI
  }
  
  // Handle growth metric tap
  void onGrowthMetricTap(GrowthMetricModel metric) {
    print('Growth metric tapped: ${metric.title}');
    // Navigate to detailed growth analysis
  }
  
  // Handle profit bar tap
  void onProfitBarTap(ProfitDataModel profitData) {
    print('Profit bar tapped: ${profitData.month}');
    // Navigate to detailed profit analysis
  }
  
  // Handle summary metric tap
  void onSummaryMetricTap(String metric) {
    print('Summary metric tapped: $metric');
    // Navigate to detailed metric view
  }
  
  // Private methods
  void _setState(VyaparMargdarshakViewState newState) {
    _state = newState;
    notifyListeners();
  }
} 