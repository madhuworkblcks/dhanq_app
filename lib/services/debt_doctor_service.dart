import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/debt_doctor_model.dart';

class DebtDoctorService {
  // Load Debt Doctor data from JSON file
  Future<DebtDoctorModel> getDebtDoctorData() async {
    try {
      // final jsonString = await rootBundle.loadString('assets/debt_doctor.json');
      // load json from below url using http package
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/debt-doctor/12345',
        ),
      );
      final jsonString = response.body;
      final jsonData = json.decode(jsonString);
      return DebtDoctorModel.fromJson(jsonData);
    } catch (e) {
      // Fallback to mock data if asset loading fails
      return await _loadLocalData();
    }
  }

  // Load data from local JSON file as fallback (mock data)
  Future<DebtDoctorModel> _loadLocalData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return DebtDoctorModel(
      debtOverview: DebtOverviewModel(
        totalDebt: 850000,
        monthlyPayment: 25000,
        totalInterest: 180000,
        debtToIncomeRatio: 35.0,
        creditScore: 720,
        paymentHistory: 'Good',
        utilizationRate: 65.0,
      ),
      debtBreakdown: {
        'creditCards': 45.0,
        'personalLoans': 30.0,
        'homeLoan': 15.0,
        'studentLoan': 10.0,
      },
      debts: [
        DebtModel(
          id: '1',
          name: 'HDFC Credit Card',
          type: 'Credit Card',
          balance: 150000,
          interestRate: 18.5,
          minimumPayment: 5000,
          dueDate: DateTime.now().add(const Duration(days: 15)),
          category: 'creditCards',
        ),
        DebtModel(
          id: '2',
          name: 'SBI Personal Loan',
          type: 'Personal Loan',
          balance: 200000,
          interestRate: 12.5,
          minimumPayment: 8000,
          dueDate: DateTime.now().add(const Duration(days: 10)),
          category: 'personalLoans',
        ),
      ],
      repaymentStrategies: [
        RepaymentStrategyModel(
          id: '1',
          name: 'Avalanche Method',
          description: 'Pay off highest interest rate debts first',
          totalInterest: 145000,
          payoffTime: 28,
          monthlyPayment: 25000,
          savings: 35000,
          timeSaved: 4,
          recommendation:
              'The Avalanche method saves you ₹35,000 in interest and pays off debt 4 months faster.',
          payoffData: [
            850000,
            800000,
            750000,
            700000,
            650000,
            600000,
            550000,
            500000,
            450000,
            400000,
            350000,
            300000,
            250000,
            200000,
            150000,
            100000,
            50000,
            0,
          ],
        ),
        RepaymentStrategyModel(
          id: '2',
          name: 'Snowball Method',
          description: 'Pay off smallest balance debts first',
          totalInterest: 165000,
          payoffTime: 32,
          monthlyPayment: 25000,
          savings: 15000,
          timeSaved: 0,
          recommendation:
              'The Snowball method provides psychological wins but costs ₹15,000 more in interest.',
          payoffData: [
            850000,
            820000,
            790000,
            760000,
            730000,
            700000,
            670000,
            640000,
            610000,
            580000,
            550000,
            520000,
            490000,
            460000,
            430000,
            400000,
            370000,
            340000,
            310000,
            280000,
            250000,
            220000,
            190000,
            160000,
            130000,
            100000,
            70000,
            40000,
            10000,
            0,
          ],
        ),
      ],
      creditScore: CreditScoreModel(
        score: 720,
        category: 'Good',
        factors: [
          CreditScoreFactor(
            factor: 'Payment History',
            impact: 'Excellent',
            contribution: 35.0,
            description: 'All payments made on time for the last 24 months',
          ),
          CreditScoreFactor(
            factor: 'Credit Utilization',
            impact: 'Good',
            contribution: 30.0,
            description: 'Using 65% of available credit limit',
          ),
        ],
        trend: [680, 690, 700, 710, 720],
        improvementTips: [
          'Reduce credit card utilization to below 30%',
          'Continue making all payments on time',
        ],
      ),
      insights: [
        InsightModel(
          id: '1',
          title: 'High Credit Card Utilization',
          description:
              'Your credit cards are using 65% of available limit. Aim for below 30% to improve credit score.',
          type: 'warning',
          priority: 'high',
        ),
        InsightModel(
          id: '2',
          title: 'Good Payment History',
          description:
              'Excellent payment history is helping maintain your credit score.',
          type: 'positive',
          priority: 'medium',
        ),
      ],
    );
  }

  // Legacy methods for backward compatibility
  Future<DebtOverviewModel> getDebtOverview() async {
    final data = await getDebtDoctorData();
    return data.debtOverview;
  }

  Future<DebtBreakdownModel> getDebtBreakdown() async {
    final data = await getDebtDoctorData();
    final breakdownMap = data.debtBreakdown;
    final totalAmount = data.debtOverview.totalDebt;
    final items =
        breakdownMap.entries
            .map(
              (entry) => DebtBreakdownItem(
                type: entry.key,
                amount: totalAmount * entry.value / 100,
                color: _getCategoryColor(entry.key),
                percentage: entry.value,
              ),
            )
            .toList();
    return DebtBreakdownModel(items: items, totalAmount: totalAmount);
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

  Future<List<RepaymentStrategyModel>> getRepaymentStrategies() async {
    final data = await getDebtDoctorData();
    return data.repaymentStrategies;
  }

  Future<CreditScoreModel> getCreditScore() async {
    final data = await getDebtDoctorData();
    return data.creditScore;
  }

  Future<List<CreditScoreFactor>> getCreditScoreFactors() async {
    final data = await getDebtDoctorData();
    return data.creditScore.factors;
  }

  Future<void> applyAvalancheStrategy() async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('Applying Avalanche strategy...');
  }
}
