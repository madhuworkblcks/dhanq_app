import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/asset_model.dart';
import '../models/portfolio_model.dart';
import '../models/smart_investor_model.dart';

class SmartInvestorService {
  // Load Smart Investor data from JSON file
  Future<SmartInvestorModel> getSmartInvestorData() async {
    try {
      // final jsonString = await rootBundle.loadString(
      //   'assets/smart_investor.json',
      // );
      // load json from below url using http package
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/smart-investor/12345',
        ),
      );
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return SmartInvestorModel.fromJson(jsonData);
    } catch (e) {
      // Fallback to mock data if asset loading fails
      return await _loadLocalData();
    }
  }

  // Load data from local JSON file as fallback (mock data)
  Future<SmartInvestorModel> _loadLocalData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return SmartInvestorModel(
      portfolio: PortfolioModel(
        totalValue: 1250000,
        todayGain: 12500,
        totalGain: 125000,
        gainPercentage: 11.1,
      ),
      allocation: {
        'Stocks': 45.0,
        'Mutual Funds': 30.0,
        'Bonds': 15.0,
        'Cash': 10.0,
      },
      assets: [
        AssetModel(
          id: '1',
          name: 'Reliance Industries',
          type: 'Stocks',
          value: 225000,
          percentage: 18.0,
          change: 4500,
          changePercentage: 2.0,
          quantity: 100,
          avgPrice: 2200,
          currentPrice: 2250,
        ),
        AssetModel(
          id: '2',
          name: 'TCS',
          type: 'Stocks',
          value: 180000,
          percentage: 14.4,
          change: 3600,
          changePercentage: 2.0,
          quantity: 60,
          avgPrice: 2900,
          currentPrice: 3000,
        ),
      ],
      marketSentiment: MarketSentimentModel(
        overallSentiment: 'Bullish',
        confidence: 75,
        factors: [
          SentimentFactor(
            factor: 'Economic Growth',
            impact: 'Positive',
            description: 'Strong GDP growth expected at 7.2%',
          ),
          SentimentFactor(
            factor: 'Interest Rates',
            impact: 'Neutral',
            description: 'RBI likely to maintain current rates',
          ),
        ],
      ),
      interestRateImpact: InterestRateImpactModel(
        currentRate: 6.5,
        projectedRate: 6.25,
        impactOnPortfolio: 'Positive',
        estimatedGain: 25000,
        reasoning: 'Lower rates typically boost equity valuations',
      ),
      recommendations: [
        RecommendationModel(
          id: '1',
          title: 'Increase Equity Allocation',
          description:
              'Consider increasing equity exposure to 60% given positive market sentiment',
          action: 'Rebalance Portfolio',
          priority: 'High',
          estimatedBenefit: 35000,
        ),
        RecommendationModel(
          id: '2',
          title: 'Add Mid-Cap Exposure',
          description: 'Include mid-cap funds for better growth potential',
          action: 'Add New Investment',
          priority: 'Medium',
          estimatedBenefit: 20000,
        ),
      ],
      performance: PerformanceModel(
        daily: 1.0,
        weekly: 2.5,
        monthly: 8.2,
        yearly: 11.1,
      ),
      insights: [
        InsightModel(
          id: '1',
          title: 'Portfolio Diversification',
          description:
              'Your portfolio is well-diversified across asset classes',
          type: 'positive',
          priority: 'medium',
        ),
        InsightModel(
          id: '2',
          title: 'High Cash Position',
          description: 'Consider reducing cash allocation for better returns',
          type: 'warning',
          priority: 'low',
        ),
      ],
    );
  }

  // Legacy methods for backward compatibility
  Future<PortfolioAllocationModel> getPortfolioAllocation() async {
    final data = await getSmartInvestorData();
    return PortfolioAllocationModel(
      equity: data.allocation['Stocks'] ?? 0,
      debt: data.allocation['Bonds'] ?? 0,
      gold: 0, // Not in new structure
      cash: data.allocation['Cash'] ?? 0,
    );
  }

  Future<List<ActionableInsightModel>> getActionableInsights() async {
    final data = await getSmartInvestorData();
    return data.recommendations
        .map(
          (rec) => ActionableInsightModel(
            id: rec.id,
            title: rec.title,
            description: rec.description,
            actionText: rec.action,
          ),
        )
        .toList();
  }

  Future<InterestRateImpactModel> getInterestRateImpact() async {
    final data = await getSmartInvestorData();
    return data.interestRateImpact;
  }

  Future<List<MarketSentimentModelLegacy>> getMarketSentimentAnalysis() async {
    final data = await getSmartInvestorData();
    return data.marketSentiment.factors
        .map(
          (factor) => MarketSentimentModelLegacy(
            id: factor.factor,
            title: 'Market Factor: ${factor.factor}',
            description: factor.description,
            actionText: 'Learn More',
          ),
        )
        .toList();
  }
}
