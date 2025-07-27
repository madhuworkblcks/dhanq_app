import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/activity_model.dart';
import '../models/financial_service_model.dart';
import '../models/home_data_model.dart';
import '../models/portfolio_model.dart';

enum LocationType { urban, rural }

class HomeService {
  // Load JSON data from assets
  Future<HomeDataModel> getHomeData() async {
    try {
      // Load JSON file from assets
      // final jsonString = await rootBundle.loadString('assets/sample_home_data.json');
      // load json from below url using http package
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/portfolio/12345',
        ),
      );
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return HomeDataModel.fromJson(jsonData);
    } catch (e) {
      // Fallback to mock data if asset loading fails
      return await _loadLocalData();
    }
  }

  // Load data from local JSON file as fallback
  Future<HomeDataModel> _loadLocalData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, return mock data structure that matches JSON
    return HomeDataModel(
      portfolio: PortfolioModel(
        totalValue: 1250000,
        todayGain: 12500,
        totalGain: 150000,
        gainPercentage: 13.6,
      ),
      activities: [
        ActivityModel(
          id: '1',
          title: 'Stock Investment',
          description: 'Purchased TechCorp shares',
          amount: 25000,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: ActivityType.investment,
        ),
        ActivityModel(
          id: '2',
          title: 'Mutual Fund Dividend',
          description: 'Dividend received from Large Cap Fund',
          amount: 1500,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: ActivityType.dividend,
        ),
        ActivityModel(
          id: '3',
          title: 'Withdrawal',
          description: 'ATM withdrawal',
          amount: -5000,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: ActivityType.withdrawal,
        ),
        ActivityModel(
          id: '4',
          title: 'Fund Transfer',
          description: 'Transferred to savings account',
          amount: -10000,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          type: ActivityType.transfer,
        ),
      ],
      financialServices: {
        'urban': [
          FinancialServiceModel(
            id: 'asset_management',
            name: 'Asset Management',
            description: 'Comprehensive asset tracking and management',
            icon: Icons.business,
            color: Colors.blue,
            category: 'urban',
          ),
          FinancialServiceModel(
            id: 'smart_investor',
            name: 'Smart Investor Agent',
            description: 'AI-powered investment recommendations',
            icon: Icons.account_balance,
            color: Colors.green,
            category: 'urban',
          ),
          FinancialServiceModel(
            id: 'debt_doctor',
            name: 'Debt-Doctor',
            description: 'Debt management and optimization',
            icon: Icons.medical_services,
            color: Colors.red,
            category: 'urban',
          ),
          FinancialServiceModel(
            id: 'tax_whisperer',
            name: 'Tax Whisperer',
            description: 'Tax planning and optimization',
            icon: Icons.description,
            color: Colors.orange,
            category: 'urban',
          ),
          FinancialServiceModel(
            id: 'financial_health',
            name: 'Financial Health Score',
            description: 'Track your financial wellness',
            icon: Icons.favorite,
            color: Colors.pink,
            category: 'urban',
          ),
          FinancialServiceModel(
            id: 'fintech_integration',
            name: 'Fintech Connect',
            description: 'Connect with other financial services',
            icon: Icons.api,
            color: Colors.purple,
            category: 'urban',
          ),
        ],
        'rural': [
          FinancialServiceModel(
            id: 'kisaan_saathi',
            name: 'Kisaan Saathi',
            description: 'Agricultural financial assistance',
            icon: Icons.agriculture,
            color: Colors.green,
            category: 'rural',
          ),
          FinancialServiceModel(
            id: 'vyapar_margdarshak',
            name: 'Vyapar Margdarshak',
            description: 'Business guidance and support',
            icon: Icons.store,
            color: Colors.blue,
            category: 'rural',
          ),
          FinancialServiceModel(
            id: 'bachat_guru',
            name: 'Bachat Guru',
            description: 'Savings optimization expert',
            icon: Icons.savings,
            color: Colors.teal,
            category: 'rural',
          ),
          FinancialServiceModel(
            id: 'voice_assistant',
            name: 'Voice Assistant',
            description: 'Voice-controlled financial tracking',
            icon: Icons.mic,
            color: Colors.indigo,
            category: 'rural',
          ),
          FinancialServiceModel(
            id: 'financial_health_rural',
            name: 'Financial Health Score',
            description: 'Track your financial wellness',
            icon: Icons.favorite,
            color: Colors.pink,
            category: 'rural',
          ),
          FinancialServiceModel(
            id: 'fintech_integration_rural',
            name: 'Fintech Connect',
            description: 'Connect with other financial services',
            icon: Icons.api,
            color: Colors.brown,
            category: 'rural',
          ),
        ],
      },
      portfolioBreakdown: {
        'Stocks': 40.0,
        'Mutual Funds': 30.0,
        'Fixed Deposits': 20.0,
        'Cash': 10.0,
      },
      userProfile: UserProfileModel(
        name: 'John Doe',
        mobile: '9008358358',
        email: 'john.doe@example.com',
        onboardingCompleted: false,
      ),
    );
  }

  // Legacy methods for backward compatibility
  Future<PortfolioModel> getPortfolioData() async {
    final homeData = await getHomeData();
    return homeData.portfolio;
  }

  Future<List<ActivityModel>> getRecentActivities() async {
    final homeData = await getHomeData();
    return homeData.activities;
  }

  Future<List<FinancialServiceModel>> getFinancialServices(
    LocationType locationType,
  ) async {
    final homeData = await getHomeData();
    final key = locationType == LocationType.urban ? 'urban' : 'rural';
    return homeData.financialServices[key] ?? [];
  }

  Future<Map<String, double>> getPortfolioBreakdown() async {
    final homeData = await getHomeData();
    return homeData.portfolioBreakdown;
  }

  // Process voice query
  Future<String> processVoiceQuery(String query) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return 'I found information about $query. Here are the details...';
  }
}
