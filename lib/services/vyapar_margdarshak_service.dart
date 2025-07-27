import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/vyapar_margdarshak_model.dart';

class VyaparMargdarshakService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load Vyapar Margdarshak data from JSON file
  Future<Map<String, dynamic>> _loadVyaparMargdarshakData() async {
    try {
      // Load JSON from http URL
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/rural_business_summary/12345',
        ),
      );
      final jsonString = response.body;
      // final jsonString = await rootBundle.loadString(
      //   'assets/vyapar_margdarshak.json',
      // );
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load Vyapar Margdarshak data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'businessSummary': {
        'sales': 5200.0,
        'expenses': 1800.0,
        'profit': 3400.0,
        'date': '2024-01-15',
      },
      'monthlyProfit': {
        'profitData': [
          {'month': 'Jan', 'profit': 2800.0, 'isCurrentMonth': false},
        ],
        'totalProfit': 2800.0,
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

  // Helper method to parse date from JSON string
  DateTime _parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  Future<BusinessSummaryModel> getTodaySummary() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final businessSummaryData =
        jsonData['businessSummary'] as Map<String, dynamic>;

    return BusinessSummaryModel(
      sales: (businessSummaryData['sales'] as num).toDouble(),
      expenses: (businessSummaryData['expenses'] as num).toDouble(),
      profit: (businessSummaryData['profit'] as num).toDouble(),
      date: _parseDate(businessSummaryData['date'] as String),
    );
  }

  Future<MonthlyProfitModel> getMonthlyProfit() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final monthlyProfitData = jsonData['monthlyProfit'] as Map<String, dynamic>;

    // Parse profit data
    final profitDataList = monthlyProfitData['profitData'] as List;
    final profitData =
        profitDataList
            .map(
              (data) => ProfitDataModel(
                month: data['month'] as String,
                profit: (data['profit'] as num).toDouble(),
                isCurrentMonth: data['isCurrentMonth'] as bool? ?? false,
              ),
            )
            .toList();

    return MonthlyProfitModel(
      profitData: profitData,
      totalProfit: (monthlyProfitData['totalProfit'] as num).toDouble(),
    );
  }

  Future<List<QuickActionModel>> getQuickActions() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final quickActionsData = jsonData['quickActions'] as List;

    return quickActionsData
        .map(
          (action) => QuickActionModel(
            title: action['title'] as String,
            icon: _parseIcon(action['icon'] as Map<String, dynamic>),
            action: action['action'] as String,
          ),
        )
        .toList();
  }

  Future<BusinessGrowthModel> getBusinessGrowth() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final businessGrowthData =
        jsonData['businessGrowth'] as Map<String, dynamic>;

    // Parse growth metrics
    final metricsData = businessGrowthData['metrics'] as List;
    final metrics =
        metricsData
            .map(
              (metric) => GrowthMetricModel(
                title: metric['title'] as String,
                percentage: (metric['percentage'] as num).toDouble(),
                comparison: metric['comparison'] as String,
                icon: _parseIcon(metric['icon'] as Map<String, dynamic>),
              ),
            )
            .toList();

    return BusinessGrowthModel(metrics: metrics);
  }

  Future<LoanOfferModel> getLoanOffer() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final loanOfferData = jsonData['loanOffer'] as Map<String, dynamic>;

    return LoanOfferModel(
      title: loanOfferData['title'] as String,
      description: loanOfferData['description'] as String,
      maxAmount: (loanOfferData['maxAmount'] as num).toDouble(),
      eligibility: loanOfferData['eligibility'] as String,
    );
  }

  Future<void> recordSale(double amount, String description) async {
    await _simulateDelay();
    print('Recording sale: $amount - $description');
  }

  Future<void> recordExpense(double amount, String category) async {
    await _simulateDelay();
    print('Recording expense: $amount - $category');
  }

  Future<void> addInventory(String item, int quantity, double cost) async {
    await _simulateDelay();
    print('Adding inventory: $item - $quantity units at ₹${cost} each');
  }

  Future<void> viewReports() async {
    await _simulateDelay();
    print('Opening business reports');
  }

  Future<void> applyForLoan() async {
    await _simulateDelay();
    print('Applying for Mudra loan');
  }

  Future<void> checkEligibility() async {
    await _simulateDelay();
    print('Checking loan eligibility');
  }

  Future<Map<String, dynamic>> getBusinessHealthMetrics() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final businessHealthData =
        jsonData['businessHealthMetrics'] as Map<String, dynamic>;

    return businessHealthData;
  }

  Future<List<Map<String, dynamic>>> getFinanceOptions() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final financeOptionsData = jsonData['financeOptions'] as List;

    return financeOptionsData.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getInventoryData() async {
    await _simulateDelay();

    final jsonData = await _loadVyaparMargdarshakData();
    final inventoryData = jsonData['inventoryData'] as List;

    return inventoryData.cast<Map<String, dynamic>>();
  }

  // Load all Vyapar Margdarshak data at once
  Future<Map<String, dynamic>> getAllVyaparMargdarshakData() async {
    await _simulateDelay();
    return await _loadVyaparMargdarshakData();
  }
}
