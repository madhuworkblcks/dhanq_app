import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/asset_model.dart';
import '../models/portfolio_model.dart';

class AssetService {
  // Load asset management data from JSON file
  Future<AssetManagementModel> getAssetManagementData() async {
    try {
      // Load JSON file from assets
      // final jsonString = await rootBundle.loadString(
      //   'assets/asset_management_data.json',
      // );
      // load json from below url using http package
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/asset-management/12345',
        ),
      );
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return AssetManagementModel.fromJson(jsonData);
    } catch (e) {
      // Fallback to mock data if asset loading fails
      return await _loadLocalData();
    }
  }

  // Load data from local JSON file as fallback
  Future<AssetManagementModel> _loadLocalData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data structure that matches JSON
    return AssetManagementModel(
      portfolio: PortfolioModel(
        totalValue: 1250000,
        todayGain: 12500,
        totalGain: 150000,
        gainPercentage: 13.6,
      ),
      assets: [
        AssetModel(
          id: '1',
          name: 'TechCorp Inc',
          type: 'Stocks',
          value: 500000,
          percentage: 40.0,
          change: 2500,
          changePercentage: 0.5,
          quantity: 1000,
          avgPrice: 500,
          currentPrice: 502.5,
        ),
        AssetModel(
          id: '2',
          name: 'Large Cap Fund',
          type: 'Mutual Funds',
          value: 375000,
          percentage: 30.0,
          change: 7500,
          changePercentage: 2.0,
          quantity: 1500,
          avgPrice: 250,
          currentPrice: 255,
        ),
        AssetModel(
          id: '3',
          name: 'Fixed Deposit',
          type: 'Fixed Deposits',
          value: 250000,
          percentage: 20.0,
          change: 1250,
          changePercentage: 0.5,
          quantity: 1,
          avgPrice: 250000,
          currentPrice: 251250,
        ),
        AssetModel(
          id: '4',
          name: 'Savings Account',
          type: 'Cash',
          value: 125000,
          percentage: 10.0,
          change: 1250,
          changePercentage: 1.0,
          quantity: 1,
          avgPrice: 125000,
          currentPrice: 126250,
        ),
      ],
      allocation: {
        'Stocks': 40.0,
        'Mutual Funds': 30.0,
        'Fixed Deposits': 20.0,
        'Cash': 10.0,
      },
      recentTransactions: [
        TransactionModel(
          id: '1',
          type: 'buy',
          asset: 'TechCorp Inc',
          quantity: 100,
          price: 500,
          amount: 50000,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TransactionModel(
          id: '2',
          type: 'sell',
          asset: 'Large Cap Fund',
          quantity: 50,
          price: 255,
          amount: 12750,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionModel(
          id: '3',
          type: 'buy',
          asset: 'Fixed Deposit',
          quantity: 1,
          price: 250000,
          amount: 250000,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      performance: PerformanceModel(
        daily: 0.5,
        weekly: 2.1,
        monthly: 8.5,
        yearly: 13.6,
      ),
      insights: [
        InsightModel(
          id: '1',
          title: 'High Concentration in Tech',
          description:
              'Your portfolio has 40% exposure to technology stocks. Consider diversifying to reduce risk.',
          type: 'warning',
          priority: 'high',
        ),
        InsightModel(
          id: '2',
          title: 'Good Cash Position',
          description:
              'You maintain a healthy 10% cash position for opportunities and emergencies.',
          type: 'positive',
          priority: 'medium',
        ),
        InsightModel(
          id: '3',
          title: 'Fixed Income Stability',
          description:
              'Your fixed deposits provide stable returns and help balance portfolio volatility.',
          type: 'positive',
          priority: 'low',
        ),
      ],
    );
  }

  // Legacy methods for backward compatibility
  Future<PortfolioModel> getPortfolioData() async {
    final assetData = await getAssetManagementData();
    return assetData.portfolio;
  }

  Future<List<AssetModel>> getAssets() async {
    final assetData = await getAssetManagementData();
    return assetData.assets;
  }

  Future<Map<String, double>> getAllocation() async {
    final assetData = await getAssetManagementData();
    return assetData.allocation;
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    final assetData = await getAssetManagementData();
    return assetData.recentTransactions;
  }

  Future<PerformanceModel> getPerformance() async {
    final assetData = await getAssetManagementData();
    return assetData.performance;
  }

  Future<List<InsightModel>> getInsights() async {
    final assetData = await getAssetManagementData();
    return assetData.insights;
  }
}
