import 'package:flutter/material.dart';

import '../models/bachat_guru_model.dart';
import '../services/bachat_guru_service.dart';

enum BachatGuruViewState { initial, loading, loaded, error }

class BachatGuruViewModel extends ChangeNotifier {
  final BachatGuruService _service = BachatGuruService();

  BachatGuruViewState _state = BachatGuruViewState.initial;
  String? _errorMessage;

  SavingsSummaryModel? _savingsSummary;
  List<SavingsTipModel> _savingsTips = [];
  List<SavingsOptionModel> _savingsOptions = [];
  List<CommunityChallengeModel> _communityChallenges = [];
  List<AchievementModel> _achievements = [];

  LanguageType _selectedLanguage = LanguageType.english;

  // Getters
  BachatGuruViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == BachatGuruViewState.loading;

  SavingsSummaryModel? get savingsSummary => _savingsSummary;
  List<SavingsTipModel> get savingsTips => _savingsTips;
  List<SavingsOptionModel> get savingsOptions => _savingsOptions;
  List<CommunityChallengeModel> get communityChallenges => _communityChallenges;
  List<AchievementModel> get achievements => _achievements;
  LanguageType get selectedLanguage => _selectedLanguage;

  // Setters
  void setLanguage(LanguageType language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initializeData() async {
    if (_state == BachatGuruViewState.loading) return;
    _setState(BachatGuruViewState.loading);
    try {
      final results = await Future.wait([
        _service.getSavingsSummary(),
        _service.getSavingsTips(),
        _service.getSavingsOptions(),
        _service.getCommunityChallenges(),
        _service.getAchievements(),
      ]);
      _savingsSummary = results[0] as SavingsSummaryModel;
      _savingsTips = results[1] as List<SavingsTipModel>;
      _savingsOptions = results[2] as List<SavingsOptionModel>;
      _communityChallenges = results[3] as List<CommunityChallengeModel>;
      _achievements = results[4] as List<AchievementModel>;
      _setState(BachatGuruViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load Bachat Guru data: ${e.toString()}';
      _setState(BachatGuruViewState.error);
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == BachatGuruViewState.loading) return;
    _setState(BachatGuruViewState.loading);
    
    try {
      final jsonData = await _service.getAllBachatGuruData();
      
      // Load savings summary
      final savingsSummaryData = jsonData['savingsSummary'] as Map<String, dynamic>;
      _savingsSummary = SavingsSummaryModel(
        totalSavings: (savingsSummaryData['totalSavings'] as num).toDouble(),
        progress: savingsSummaryData['progress'] as int,
        goal: savingsSummaryData['goal'] as int,
        status: savingsSummaryData['status'] as String,
        streakCount: savingsSummaryData['streakCount'] as int,
      );
      
      // Load savings tips
      final savingsTipsData = jsonData['savingsTips'] as List;
      _savingsTips = savingsTipsData
          .map((tip) => SavingsTipModel(
                title: tip['title'] as String,
                description: tip['description'] as String,
                color: _parseColor(tip['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Load savings options
      final savingsOptionsData = jsonData['savingsOptions'] as List;
      _savingsOptions = savingsOptionsData
          .map((option) => SavingsOptionModel(
                name: option['name'] as String,
                minAmount: option['minAmount'] as String,
                returns: option['returns'] as String,
                period: option['period'] as String,
                icon: _parseIcon(option['icon'] as Map<String, dynamic>),
                color: _parseColor(option['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Load community challenges
      final communityChallengesData = jsonData['communityChallenges'] as List;
      _communityChallenges = communityChallengesData
          .map((challenge) => CommunityChallengeModel(
                title: challenge['title'] as String,
                description: challenge['description'] as String,
                targetAmount: (challenge['targetAmount'] as num).toDouble(),
                savedAmount: (challenge['savedAmount'] as num).toDouble(),
                months: challenge['months'] as int,
                icon: _parseIcon(challenge['icon'] as Map<String, dynamic>),
                color: _parseColor(challenge['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      // Load achievements
      final achievementsData = jsonData['achievements'] as List;
      _achievements = achievementsData
          .map((achievement) => AchievementModel(
                title: achievement['title'] as String,
                icon: _parseIcon(achievement['icon'] as Map<String, dynamic>),
                color: _parseColor(achievement['color'] as Map<String, dynamic>),
              ))
          .toList();
      
      _setState(BachatGuruViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load Bachat Guru data from JSON: ${e.toString()}';
      _setState(BachatGuruViewState.error);
    }
  }

  // Helper method to parse icon from JSON
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

  // Refresh data
  Future<void> refreshData() async {
    _savingsSummary = null;
    _savingsTips = [];
    _savingsOptions = [];
    _communityChallenges = [];
    _achievements = [];
    await initializeData();
  }

  // Private methods
  void _setState(BachatGuruViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
