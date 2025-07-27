import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/tax_whisperer_model.dart';

class TaxWhispererService {
  // Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load tax whisperer data from JSON file
  Future<Map<String, dynamic>> _loadTaxWhispererData() async {
    try {
      // load from http url https://dhanqserv-43683479109.us-central1.run.app/api/tax-whisperer/12345
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/tax-whisperer/12345',
        ),
      );
      // final jsonString = await rootBundle.loadString('assets/tax_whisperer.json');
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load tax whisperer data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'taxHealthScore': {
        'score': 82,
        'maxScore': 100,
        'status': 'Good',
        'statusColor': {
          'value': 4280391411,
          'alpha': 255,
          'red': 34,
          'green': 197,
          'blue': 94,
          'opacity': 1.0,
        },
        'description':
            "You're on track, but there are a few opportunities to optimize your tax situation.",
        'quickImprovements': [
          {
            'title': 'Maximize your retirement contributions',
            'isCompleted': false,
          },
          {
            'title': 'Review home office deduction eligibility',
            'isCompleted': false,
          },
        ],
      },
    };
  }

  // Helper method to convert JSON color to Flutter Color
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  // Helper method to convert JSON icon to Flutter IconData
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  Future<TaxHealthScoreModel> getTaxHealthScore() async {
    await _simulateDelay();

    final jsonData = await _loadTaxWhispererData();
    final taxHealthScoreData =
        jsonData['taxHealthScore'] as Map<String, dynamic>;

    return TaxHealthScoreModel(
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
  }

  Future<TaxLiabilityForecastModel> getTaxLiabilityForecast() async {
    await _simulateDelay();

    final jsonData = await _loadTaxWhispererData();
    final forecastData =
        jsonData['taxLiabilityForecast'] as Map<String, dynamic>;

    return TaxLiabilityForecastModel(
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
  }

  Future<List<PersonalizedDeductionModel>> getPersonalizedDeductions() async {
    await _simulateDelay();

    final jsonData = await _loadTaxWhispererData();
    final deductionsData = jsonData['personalizedDeductions'] as List;

    return deductionsData
        .map(
          (deduction) => PersonalizedDeductionModel(
            title: deduction['title'] as String,
            description: deduction['description'] as String,
            estimatedValue: (deduction['estimatedValue'] as num).toDouble(),
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
  }

  Future<void> applyTaxOptimization() async {
    await _simulateDelay();
    // Simulate applying tax optimization
    print('Tax optimization applied successfully!');
  }

  Future<void> learnMoreAboutDeduction(String deductionType) async {
    await _simulateDelay();
    // Simulate learning more about deduction
    print('Learning more about $deductionType deduction');
  }

  // Load all tax whisperer data at once
  Future<Map<String, dynamic>> getAllTaxWhispererData() async {
    await _simulateDelay();
    return await _loadTaxWhispererData();
  }
}
