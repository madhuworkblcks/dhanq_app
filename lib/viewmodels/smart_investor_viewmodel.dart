import 'package:dhanq_app/models/asset_model.dart';
import 'package:flutter/material.dart';

import '../models/portfolio_model.dart';
import '../models/smart_investor_model.dart';
import '../services/smart_investor_service.dart';

enum SmartInvestorViewState { initial, loading, loaded, error }

class SmartInvestorViewModel extends ChangeNotifier {
  final SmartInvestorService _smartInvestorService = SmartInvestorService();

  SmartInvestorViewState _state = SmartInvestorViewState.initial;
  SmartInvestorModel? _smartInvestorData;
  String? _errorMessage;

  // Legacy data for backward compatibility
  PortfolioAllocationModel? _portfolioAllocation;
  List<ActionableInsightModel> _actionableInsights = [];
  InterestRateImpactModel? _interestRateImpact;
  List<MarketSentimentModelLegacy> _marketSentimentAnalysis = [];

  // Getters
  SmartInvestorViewState get state => _state;
  SmartInvestorModel? get smartInvestorData => _smartInvestorData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SmartInvestorViewState.loading;

  // Legacy getters for backward compatibility
  PortfolioAllocationModel? get portfolioAllocation => _portfolioAllocation;
  List<ActionableInsightModel> get actionableInsights => _actionableInsights;
  InterestRateImpactModel? get interestRateImpact => _interestRateImpact;
  List<MarketSentimentModelLegacy> get marketSentimentAnalysis =>
      _marketSentimentAnalysis;

  // New getters for the unified data model
  PortfolioModel? get portfolio => _smartInvestorData?.portfolio;
  Map<String, double> get allocation => _smartInvestorData?.allocation ?? {};
  List<AssetModel> get assets => _smartInvestorData?.assets ?? [];
  MarketSentimentModel? get marketSentiment =>
      _smartInvestorData?.marketSentiment;
  InterestRateImpactModel? get interestRateImpactData =>
      _smartInvestorData?.interestRateImpact;
  List<RecommendationModel> get recommendations =>
      _smartInvestorData?.recommendations ?? [];
  PerformanceModel? get performance => _smartInvestorData?.performance;
  List<InsightModel> get insights => _smartInvestorData?.insights ?? [];

  // Initialize data
  Future<void> initializeData() async {
    if (_state == SmartInvestorViewState.initial) {
      _state = SmartInvestorViewState.loading;
      notifyListeners();

      try {
        _smartInvestorData = await _smartInvestorService.getSmartInvestorData();

        // Load legacy data for backward compatibility
        await Future.wait([
          _loadPortfolioAllocation(),
          _loadActionableInsights(),
          _loadInterestRateImpact(),
          _loadMarketSentimentAnalysis(),
        ]);

        _state = SmartInvestorViewState.loaded;
      } catch (e) {
        _errorMessage = e.toString();
        _state = SmartInvestorViewState.error;
      }
      notifyListeners();
    }
  }

  // Load portfolio allocation (legacy)
  Future<void> _loadPortfolioAllocation() async {
    _portfolioAllocation = await _smartInvestorService.getPortfolioAllocation();
    notifyListeners();
  }

  // Load actionable insights (legacy)
  Future<void> _loadActionableInsights() async {
    _actionableInsights = await _smartInvestorService.getActionableInsights();
    notifyListeners();
  }

  // Load interest rate impact (legacy)
  Future<void> _loadInterestRateImpact() async {
    _interestRateImpact = await _smartInvestorService.getInterestRateImpact();
    notifyListeners();
  }

  // Load market sentiment analysis (legacy)
  Future<void> _loadMarketSentimentAnalysis() async {
    _marketSentimentAnalysis =
        await _smartInvestorService.getMarketSentimentAnalysis();
    notifyListeners();
  }

  // Handle actionable insight tap
  void onActionableInsightTap(ActionableInsightModel insight) {
    print('Actionable insight tapped: ${insight.title}');
    // Handle insight action
  }

  // Handle market sentiment tap
  void onMarketSentimentTap(MarketSentimentModelLegacy sentiment) {
    print('Market sentiment tapped: ${sentiment.title}');
    // Handle sentiment action
  }

  // Handle interest rate impact tap
  void onInterestRateImpactTap() {
    print('Interest rate impact tapped');
    // Handle interest rate impact action
  }

  // Handle recommendation tap
  void onRecommendationTap(RecommendationModel recommendation) {
    print('Recommendation tapped: ${recommendation.title}');
    // Handle recommendation action
  }

  // Refresh data
  Future<void> refreshData() async {
    _state = SmartInvestorViewState.loading;
    notifyListeners();
    await initializeData();
  }
}
