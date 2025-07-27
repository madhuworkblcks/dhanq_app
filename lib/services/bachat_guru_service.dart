import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/bachat_guru_model.dart';

class BachatGuruService {
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Load Bachat Guru data from JSON file
  Future<Map<String, dynamic>> _loadBachatGuruData() async {
    try {
      // Load JSON from url
      final response = await http.get(
        Uri.parse(
          'https://dhanqserv-43683479109.us-central1.run.app/api/rural_savings_summary/12345',
        ),
      );
      final jsonString = response.body;
      // final jsonString = await rootBundle.loadString('assets/bachat_guru.json');
      final jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Failed to load Bachat Guru data: $e');
      // Return fallback data if JSON loading fails
      return _getFallbackData();
    }
  }

  // Fallback data if JSON loading fails
  Map<String, dynamic> _getFallbackData() {
    return {
      'savingsSummary': {
        'totalSavings': 4500.0,
        'progress': 3,
        'goal': 10,
        'status': 'Growing steadily!',
        'streakCount': 3,
      },
      'savingsTips': [
        {
          'title': 'Small Daily Savings',
          'description': 'Save ₹20 from your daily tea budget',
          'color': {
            'value': 4294967244,
            'alpha': 255,
            'red': 255,
            'green': 249,
            'blue': 196,
            'opacity': 1.0,
          },
        },
      ],
    };
  }

  // Helper method to convert JSON icon to Flutter IconData
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Helper method to parse color from JSON
  Color _parseColor(Map<String, dynamic> colorJson) {
    return Color(colorJson['value'] as int);
  }

  Future<SavingsSummaryModel> getSavingsSummary() async {
    await _simulateDelay();

    final jsonData = await _loadBachatGuruData();
    final savingsSummaryData =
        jsonData['savingsSummary'] as Map<String, dynamic>;

    return SavingsSummaryModel(
      totalSavings: (savingsSummaryData['totalSavings'] as num).toDouble(),
      progress: savingsSummaryData['progress'] as int,
      goal: savingsSummaryData['goal'] as int,
      status: savingsSummaryData['status'] as String,
      streakCount: savingsSummaryData['streakCount'] as int,
    );
  }

  Future<List<SavingsTipModel>> getSavingsTips() async {
    await _simulateDelay();

    final jsonData = await _loadBachatGuruData();
    final savingsTipsData = jsonData['savingsTips'] as List;

    return savingsTipsData
        .map(
          (tip) => SavingsTipModel(
            title: tip['title'] as String,
            description: tip['description'] as String,
            color: _parseColor(tip['color'] as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<List<SavingsOptionModel>> getSavingsOptions() async {
    await _simulateDelay();

    final jsonData = await _loadBachatGuruData();
    final savingsOptionsData = jsonData['savingsOptions'] as List;

    return savingsOptionsData
        .map(
          (option) => SavingsOptionModel(
            name: option['name'] as String,
            minAmount: option['minAmount'] as String,
            returns: option['returns'] as String,
            period: option['period'] as String,
            icon: _parseIcon(option['icon'] as Map<String, dynamic>),
            color: _parseColor(option['color'] as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<List<CommunityChallengeModel>> getCommunityChallenges() async {
    await _simulateDelay();

    final jsonData = await _loadBachatGuruData();
    final communityChallengesData = jsonData['communityChallenges'] as List;

    return communityChallengesData
        .map(
          (challenge) => CommunityChallengeModel(
            title: challenge['title'] as String,
            description: challenge['description'] as String,
            targetAmount: (challenge['targetAmount'] as num).toDouble(),
            savedAmount: (challenge['savedAmount'] as num).toDouble(),
            months: challenge['months'] as int,
            icon: _parseIcon(challenge['icon'] as Map<String, dynamic>),
            color: _parseColor(challenge['color'] as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<List<AchievementModel>> getAchievements() async {
    await _simulateDelay();

    final jsonData = await _loadBachatGuruData();
    final achievementsData = jsonData['achievements'] as List;

    return achievementsData
        .map(
          (achievement) => AchievementModel(
            title: achievement['title'] as String,
            icon: _parseIcon(achievement['icon'] as Map<String, dynamic>),
            color: _parseColor(achievement['color'] as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  // Load all Bachat Guru data at once
  Future<Map<String, dynamic>> getAllBachatGuruData() async {
    await _simulateDelay();
    return await _loadBachatGuruData();
  }
}
