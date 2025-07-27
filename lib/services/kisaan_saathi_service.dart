import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/kisaan_saathi_model.dart';

class KisaanSaathiService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load Kisaan Saathi data from JSON file
  Future<Map<String, dynamic>> _loadKisaanSaathiData() async {
    try {
      // load from http url https://dhanqserv-43683479109.us-central1.run.app/api/kisaan-saathi/12345
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/rural-kisan-saathi/12345',
        ),
      );
      final jsonString = response.body;
      // final jsonString = await rootBundle.loadString(
      //   'assets/kisaan_saathi.json',
      // );
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load Kisaan Saathi data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'farmFinance': {
        'upcomingPayments': [
          {
            'item': 'Seeds & Fertilizers',
            'amount': 4500.0,
            'dueDate': '2024-03-15',
            'category': 'Inputs',
          },
        ],
        'harvestIncomes': [
          {
            'crop': 'Wheat',
            'expectedIncome': 35000.0,
            'expectedDate': '2024-04-15',
            'status': 'Growing',
          },
        ],
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

  Future<FarmFinanceModel> getFarmFinanceData() async {
    await _simulateDelay();

    final jsonData = await _loadKisaanSaathiData();
    final farmFinanceData = jsonData['farmFinance'] as Map<String, dynamic>;

    // Parse upcoming payments
    final upcomingPaymentsData = farmFinanceData['upcomingPayments'] as List;
    final upcomingPayments =
        upcomingPaymentsData
            .map(
              (payment) => UpcomingPaymentModel(
                item: payment['item'] as String,
                amount: (payment['amount'] as num).toDouble(),
                dueDate: _parseDate(payment['dueDate'] as String),
                category: payment['category'] as String,
              ),
            )
            .toList();

    // Parse harvest incomes
    final harvestIncomesData = farmFinanceData['harvestIncomes'] as List;
    final harvestIncomes =
        harvestIncomesData
            .map(
              (income) => HarvestIncomeModel(
                crop: income['crop'] as String,
                expectedIncome: (income['expectedIncome'] as num).toDouble(),
                expectedDate: _parseDate(income['expectedDate'] as String),
                status: income['status'] as String,
              ),
            )
            .toList();

    return FarmFinanceModel(
      upcomingPayments: upcomingPayments,
      harvestIncomes: harvestIncomes,
    );
  }

  Future<List<GovernmentSchemeModel>> getGovernmentSchemes() async {
    await _simulateDelay();

    final jsonData = await _loadKisaanSaathiData();
    final schemesData = jsonData['governmentSchemes'] as List;

    return schemesData
        .map(
          (scheme) => GovernmentSchemeModel(
            name: scheme['name'] as String,
            status: scheme['status'] as String,
            nextInstallment: _parseDate(scheme['nextInstallment'] as String),
            isEligible: scheme['isEligible'] as bool,
            description: scheme['description'] as String,
            actionText: scheme['actionText'] as String,
          ),
        )
        .toList();
  }

  Future<WeatherMarketModel> getWeatherMarketData() async {
    await _simulateDelay();

    final jsonData = await _loadKisaanSaathiData();
    final weatherMarketData = jsonData['weatherMarket'] as Map<String, dynamic>;

    // Parse market prices
    final marketPricesData = weatherMarketData['marketPrices'] as List;
    final marketPrices =
        marketPricesData
            .map(
              (price) => MarketPriceModel(
                crop: price['crop'] as String,
                price: (price['price'] as num).toDouble(),
                unit: price['unit'] as String,
                change: price['change'] as double?,
              ),
            )
            .toList();

    // Parse weather forecast
    final weatherForecastData =
        weatherMarketData['weatherForecast'] as Map<String, dynamic>;
    final weatherForecast = WeatherForecastModel(
      condition: weatherForecastData['condition'] as String,
      description: weatherForecastData['description'] as String,
      recommendation: weatherForecastData['recommendation'] as String,
      icon: _parseIcon(weatherForecastData['icon'] as Map<String, dynamic>),
    );

    return WeatherMarketModel(
      marketPrices: marketPrices,
      weatherForecast: weatherForecast,
    );
  }

  Future<MicroLoanSHGModel> getMicroLoanSHGData() async {
    await _simulateDelay();

    final jsonData = await _loadKisaanSaathiData();
    final microLoanSHGData = jsonData['microLoanSHG'] as Map<String, dynamic>;

    // Parse loan payments
    final loanPaymentsData = microLoanSHGData['loanPayments'] as List;
    final loanPayments =
        loanPaymentsData
            .map(
              (payment) => LoanPaymentModel(
                dueDate: _parseDate(payment['dueDate'] as String),
                amount: (payment['amount'] as num).toDouble(),
                loanType: payment['loanType'] as String,
                status: payment['status'] as String,
              ),
            )
            .toList();

    // Parse SHG meetings
    final shgMeetingsData = microLoanSHGData['shgMeetings'] as List;
    final shgMeetings =
        shgMeetingsData
            .map(
              (meeting) => SHGMeetingModel(
                meetingDate: _parseDate(meeting['meetingDate'] as String),
                topic: meeting['topic'] as String,
                location: meeting['location'] as String,
                status: meeting['status'] as String,
              ),
            )
            .toList();

    return MicroLoanSHGModel(
      loanPayments: loanPayments,
      shgMeetings: shgMeetings,
    );
  }

  Future<VoiceQueryModel> getVoiceQueryData() async {
    await _simulateDelay();

    final jsonData = await _loadKisaanSaathiData();
    final voiceQueryData = jsonData['voiceQuery'] as Map<String, dynamic>;

    return VoiceQueryModel(
      prompt: voiceQueryData['prompt'] as String,
      suggestedQuery: voiceQueryData['suggestedQuery'] as String,
      isListening: voiceQueryData['isListening'] as bool? ?? false,
    );
  }

  Future<void> processVoiceQuery(String query) async {
    await _simulateDelay();
    // Simulate processing voice query
    print('Processing voice query: $query');
  }

  Future<void> startVoiceListening() async {
    await _simulateDelay();
    // Simulate starting voice listening
    print('Voice listening started');
  }

  Future<void> stopVoiceListening() async {
    await _simulateDelay();
    // Simulate stopping voice listening
    print('Voice listening stopped');
  }

  Future<void> checkSchemeStatus(String schemeName) async {
    await _simulateDelay();
    // Simulate checking scheme status
    print('Checking status for: $schemeName');
  }

  Future<void> viewMarketPrices() async {
    await _simulateDelay();
    // Simulate viewing market prices
    print('Viewing market prices');
  }

  Future<void> repayLoan(String loanId) async {
    await _simulateDelay();
    // Simulate loan repayment
    print('Processing loan repayment for: $loanId');
  }

  Future<void> joinSHGMeeting(String meetingId) async {
    await _simulateDelay();
    // Simulate joining SHG meeting
    print('Joining SHG meeting: $meetingId');
  }

  // Load all Kisaan Saathi data at once
  Future<Map<String, dynamic>> getAllKisaanSaathiData() async {
    await _simulateDelay();
    return await _loadKisaanSaathiData();
  }
}
