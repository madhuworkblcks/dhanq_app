import 'package:dhanq_app/utils/permission_helper.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/voice_assist_model.dart';
import '../services/voice_assist_service.dart';

enum VoiceAssistViewState { initial, loading, loaded, error }

class VoiceAssistViewModel extends ChangeNotifier {
  final VoiceAssistService _service = VoiceAssistService();

  VoiceAssistViewState _state = VoiceAssistViewState.initial;
  BudgetSummary? _budgetSummary;
  List<ChatMessage> _chatMessages = [];
  WeeklySpendingSummary? _weeklySpending;
  LanguageType _selectedLanguage = LanguageType.english;
  bool _isListening = false;
  String _voiceInput = '';

  // Getters
  VoiceAssistViewState get state => _state;
  BudgetSummary? get budgetSummary => _budgetSummary;
  List<ChatMessage> get chatMessages => _chatMessages;
  WeeklySpendingSummary? get weeklySpending => _weeklySpending;
  LanguageType get selectedLanguage => _selectedLanguage;
  bool get isListening => _isListening;
  String get voiceInput => _voiceInput;

  // Initialize data
  Future<void> initializeData() async {
    if (_state == VoiceAssistViewState.loading) return;

    _setState(VoiceAssistViewState.loading);

    try {
      await Future.wait([
        _loadBudgetSummary(),
        _loadChatMessages(),
        _loadWeeklySpending(),
      ]);

      _setState(VoiceAssistViewState.loaded);
    } catch (e) {
      _setState(VoiceAssistViewState.error);
    }
  }

  Future<void> _loadBudgetSummary() async {
    _budgetSummary = await _service.getBudgetSummary();
    notifyListeners();
  }

  Future<void> _loadChatMessages() async {
    _chatMessages = await _service.getChatMessages();
    notifyListeners();
  }

  Future<void> _loadWeeklySpending() async {
    _weeklySpending = await _service.getWeeklySpending();
    notifyListeners();
  }

  // Language switching
  void setLanguage(LanguageType language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Voice input handling
  void startListening(BuildContext context) async {
    final bool recordPermission =
        await PermissionHelper.getMicrophonePermission(context);
    if (!recordPermission) {
      return;
    }
    _isListening = true;
    _voiceInput = '';
    notifyListeners();
    // Start listening to audio and convert to text
    await _listenAndTranscribe(context);
  }

  Future<void> _listenAndTranscribe(BuildContext context) async {
    try {
      final speech = SpeechToText();
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            stopListening();
          }
        },
        onError: (error) {
          stopListening();
          debugPrint('Speech recognition error: $error');
        },
      );

      if (available) {
        await speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setVoiceInput(result.recognizedWords);
              stopListening();
            }
          },
          localeId: _selectedLanguage == LanguageType.hindi ? 'hi_IN' : 'en_US',
        );
      } else {
        debugPrint('Speech recognition not available');
        stopListening();
      }
    } catch (e) {
      debugPrint('Error during speech recognition: $e');
      stopListening();
    }
  }

  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  void setVoiceInput(String input) {
    _voiceInput = input;
    notifyListeners();
  }

  // Process voice input
  Future<void> processVoiceInput(String input) async {
    if (input.trim().isEmpty) return;

    // Add user message
    final userMessage = await _service.processVoiceInput(
      input,
      _selectedLanguage,
    );
    _chatMessages.add(userMessage);
    notifyListeners();

    // Generate response
    final response = await _service.generateResponse(
      userMessage,
      _selectedLanguage,
    );
    _chatMessages.add(response);
    notifyListeners();

    // Clear input
    _voiceInput = '';
    notifyListeners();
  }

  // Add text message
  Future<void> sendTextMessage(String message) async {
    if (message.trim().isEmpty) return;

    await processVoiceInput(message);
  }

  // Refresh data
  Future<void> refreshData() async {
    await initializeData();
  }

  // Helper methods
  void _setState(VoiceAssistViewState state) {
    _state = state;
    notifyListeners();
  }

  // Get localized text
  String getLocalizedText(String englishText, String hindiText) {
    return _selectedLanguage == LanguageType.hindi ? hindiText : englishText;
  }

  // Get greeting message
  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting =
          _selectedLanguage == LanguageType.hindi ? 'सुप्रभात' : 'Good morning';
    } else if (hour < 17) {
      greeting =
          _selectedLanguage == LanguageType.hindi
              ? 'सुधोपहर'
              : 'Good afternoon';
    } else {
      greeting =
          _selectedLanguage == LanguageType.hindi ? 'सुसंध्या' : 'Good evening';
    }

    return '$greeting, Rajan! ${_selectedLanguage == LanguageType.hindi ? 'मैं आपकी कैसे मदद कर सकता हूं?' : 'How can I help you today?'}';
  }
}
