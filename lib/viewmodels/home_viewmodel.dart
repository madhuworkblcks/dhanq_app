import 'dart:async';
import 'dart:io' show Platform;

import 'package:dhanq_app/models/voice_assist_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/activity_model.dart';
import '../models/financial_service_model.dart';
import '../models/home_data_model.dart';
import '../models/portfolio_model.dart';
import '../services/home_service.dart';
import '../services/voice_assist_service.dart';
import '../utils/bottom_sheet_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/epf_display_bottom_sheet.dart';
import '../widgets/mcp_webview_bottom_sheet.dart';
import '../widgets/transaction_display_bottom_sheet.dart';

enum HomeViewState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final HomeService _service = HomeService();
  final VoiceAssistService _voiceAssistService = VoiceAssistService();

  HomeViewState _state = HomeViewState.initial;
  HomeDataModel? _homeData;
  String? _errorMessage;
  LocationType _locationType = LocationType.urban;
  String _searchQuery = '';
  bool _isListening = false;
  bool _onboardingCompleted = false;
  bool _isOnboardingLoading = false;

  String mcpUrl =
      'https://fi-mcp-mock-server-43683479109.us-central1.run.app/mockWebPage?sessionId=mcp-session-594e48ea-fea1-40ef-8c52-7552dd9272af';
  // Getters
  HomeViewState get state => _state;
  HomeDataModel? get homeData => _homeData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == HomeViewState.loading;
  LocationType get locationType => _locationType;
  String get searchQuery => _searchQuery;
  bool get isListening => _isListening;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isOnboardingLoading => _isOnboardingLoading;

  LanguageType _selectedLanguage = LanguageType.english;
  String _voiceInput = '';
  final TextEditingController searchController = TextEditingController();

  // Getters
  LanguageType get selectedLanguage => _selectedLanguage;
  String get voiceInput => _voiceInput;

  // Legacy getters for backward compatibility
  PortfolioModel? get portfolioData => _homeData?.portfolio;
  List<ActivityModel> get recentActivities => _homeData?.activities ?? [];
  List<FinancialServiceModel> get financialServices {
    if (_homeData == null) return [];
    final key = _locationType == LocationType.urban ? 'urban' : 'rural';
    return _homeData!.financialServices[key] ?? [];
  }

  // Initialize data
  Future<void> initializeData() async {
    if (_state == HomeViewState.initial) {
      _state = HomeViewState.loading;
      notifyListeners();

      try {
        _homeData = await _service.getHomeData();
        _onboardingCompleted =
            _homeData?.userProfile.onboardingCompleted ?? false;
        _state = HomeViewState.loaded;
      } catch (e) {
        _errorMessage = e.toString();
        _state = HomeViewState.error;
      }

      notifyListeners();
    }
  }

  // Set location type
  void setLocationType(LocationType type) {
    _locationType = type;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    // Sync with search controller if it's different
    if (searchController.text != query) {
      searchController.text = query;
    }
    notifyListeners();
  }

  // Start voice listening
  Future<void> startVoiceListening(BuildContext context) async {
    try {
      debugPrint('=== Starting voice listening process ===');

      // Get detailed permission status first
      await PermissionHelper.getDetailedMicrophoneStatus();

      // Check if we already have permission
      bool hasPermission =
          await PermissionHelper.isMicrophonePermissionGranted();
      debugPrint(
        'Checking microphone permission status: ${await Permission.microphone.status}',
      );

      if (Platform.isIOS) {
        debugPrint('iOS permission is denied, but can be requested again');
      }

      debugPrint('Initial hasPermission check: $hasPermission');

      if (!hasPermission) {
        debugPrint('Permission not granted, requesting permission...');

        if (Platform.isIOS) {
          // For iOS, directly try the inconsistency handler since it's the most reliable
          debugPrint('Using iOS inconsistency handler directly...');
          hasPermission =
              await PermissionHelper.handleIOSPermissionInconsistency(context);
          debugPrint('iOS inconsistency handler result: $hasPermission');

          // If inconsistency handler fails, try the quirk handler as fallback
          if (!hasPermission) {
            debugPrint('Inconsistency handler failed, trying quirk handler...');
            hasPermission = await PermissionHelper.handleIOSPermissionQuirk(
              context,
            );
            debugPrint('iOS quirk handler result: $hasPermission');
          }
        } else {
          // For Android, use standard permission handling
          hasPermission = await PermissionHelper.getMicrophonePermission(
            context,
          );
          debugPrint('Android permission handling result: $hasPermission');
        }
      } else {
        debugPrint('Permission already granted, proceeding...');
      }

      if (!hasPermission) {
        debugPrint(
          '=== Microphone permission not granted after all attempts ===',
        );
        // Get final detailed status for debugging
        await PermissionHelper.getDetailedMicrophoneStatus();
        return;
      }

      // Permission is granted, proceed with voice listening
      debugPrint(
        '=== Microphone permission granted, starting voice listening ===',
      );

      _isListening = true;
      notifyListeners();
      // Start listening to audio and convert to text
      await _listenAndTranscribe(context);
    } catch (e) {
      debugPrint('Error in startVoiceListening: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> _listenAndTranscribe(BuildContext context) async {
    try {
      final speech = SpeechToText();

      // Initialize speech recognition - this will trigger permission request on iOS
      bool available = await speech.initialize(
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'notListening') {
            stopListening();
          }
        },
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          stopListening();

          // If permission is denied, show settings dialog
          if (error.errorMsg.contains('permission') ||
              error.errorMsg.contains('denied')) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Microphone Permission Required'),
                    content: const Text(
                      'Please enable microphone access in Settings to use voice input.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Open Settings'),
                        onPressed: () {
                          openAppSettings();
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        },
      );

      if (available) {
        String lastResult = '';
        DateTime lastResultTime = DateTime.now();

        await speech.listen(
          onResult: (result) {
            debugPrint(
              'Speech result: ${result.recognizedWords} (final: ${result.finalResult})',
            );

            if (result.recognizedWords.isNotEmpty) {
              lastResult = result.finalResult.toString();
              lastResultTime = DateTime.now();
            }

            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              debugPrint('Final result received: ${result.recognizedWords}');
              searchController.text =
                  result.recognizedWords; // Update search input box
              _voiceInput =
                  result.recognizedWords.toLowerCase(); // Set voice input
              setVoiceInput(result.recognizedWords.toLowerCase(), context);
              stopListening();
            } else if (result.recognizedWords.isNotEmpty) {
              debugPrint('Partial result: ${result.recognizedWords}');

              // For iOS, if we have a partial result and it's been stable for 2 seconds, treat it as final
              // if (DateTime.now().difference(lastResultTime).inSeconds >= 2) {
              //   debugPrint(
              //     'Treating stable partial result as final: $lastResult',
              //   );
              //   setVoiceInput(lastResult.toLowerCase(), context);
              //   stopListening();
              // }
            }
          },
          localeId: _selectedLanguage == LanguageType.hindi ? 'hi_IN' : 'en_US',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2), // Reduced pause time for iOS
          cancelOnError: true,
        );

        // Add a timeout to stop listening if no final result after 10 seconds
        Timer(const Duration(seconds: 4), () {
          if (_isListening && lastResult.isNotEmpty) {
            debugPrint('Timeout reached, using last result: $lastResult');
            searchController.text = lastResult; // Update search input box
            _voiceInput = lastResult.toLowerCase(); // Set voice input
            setVoiceInput(lastResult.toLowerCase(), context);
            speech.stop();
            stopListening();
          } else if (_isListening) {
            debugPrint('Timeout reached, no result available');
            stopListening();
          }
        });
      } else {
        debugPrint('Speech recognition not available');
        stopListening();
      }
    } catch (e) {
      debugPrint('Error during speech recognition: $e');
      stopListening();
    }
  }

  void stopListening() async {
    _isListening = false;
    notifyListeners();
  }

  Future<void> setVoiceInput(String input, BuildContext context) async {
    _voiceInput = input.toLowerCase();
    setSearchQuery(input); // Update search query with voice input
    searchController.text = input; // Set text in the search input box
    _isListening = false; // Stop listening after input is set
    notifyListeners();
    if (input.trim().isEmpty) {
      return;
    }
    try {
      final mcpResp = await _voiceAssistService.processVoiceMessageFromMCP(
        _voiceInput,
      );
      if (mcpResp != null && mcpResp.isNotEmpty) {
        // Handle MCP response if needed
        debugPrint('MCP Response: $mcpResp');
        if (mcpResp.contains('login_url')) {
          // Directly open in WebView with disabled drag
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            enableDrag: false,
            // Disable bottom sheet drag to allow WebView scrolling
            builder:
                (context) => MCPWebViewBottomSheet(
                  url: this.mcpUrl,
                  onClose: () => _handleMCPClose(context),
                ),
          );
        } else {
          if (input.contains('transaction')) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              builder:
                  (context) =>
                      TransactionDisplayBottomSheet(jsonResponse: mcpResp),
            );
            clearSearch();
            setVoiceInput('', context);
            // Handle other transaction related voice input
          } else if (_voiceInput.contains('epf') ||
              _voiceInput.contains('provident fund') ||
              mcpResp.contains('"uanAccounts"')) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              builder:
                  (context) => EPFDisplayBottomSheet(jsonResponse: mcpResp),
            );
            clearSearch();
            setVoiceInput('', context);
          } else if (input.contains('portfolio')) {
            // Handle portfolio related voice input
          } else {
            BottomSheetHelper.showNoDetailsFoundBottomSheet(context);
            clearSearch();
            setVoiceInput('', context);
            searchController.text = ''; // Set text in the search input box
          }
        }
      } else {
        BottomSheetHelper.showNoDetailsFoundBottomSheet(context);
        clearSearch();
        setVoiceInput('', context);
        searchController.text = ''; // Set text in the search input box
      }
    } catch (e) {
      debugPrint('Error processing MCP request: $e');
    }
  }

  // Process voice input
  Future<void> processVoiceInput(String input) async {
    if (input.trim().isEmpty) return;

    // Add user message
    final userMessage = await _voiceAssistService.processVoiceInput(
      input,
      _selectedLanguage,
    );
    notifyListeners();

    // Generate response
    final response = await _voiceAssistService.generateResponse(
      userMessage,
      _selectedLanguage,
    );
    notifyListeners();

    // Clear input
    _voiceInput = '';
    notifyListeners();
  }

  // Get localized text
  String getLocalizedText(String englishText, String hindiText) {
    return _selectedLanguage == LanguageType.hindi ? hindiText : englishText;
  }

  // Reset microphone permission (for testing)
  Future<void> resetMicrophonePermission() async {
    await PermissionHelper.resetMicrophonePermission();
  }

  // Handle permanently denied permission
  Future<bool> handlePermanentlyDeniedPermission(BuildContext context) async {
    return await PermissionHelper.handlePermanentlyDeniedPermission(context);
  }

  // Debug all permissions
  Future<void> debugAllPermissions() async {
    await PermissionHelper.debugAllPermissions();
  }

  // Handle MCP WebView close
  Future<void> _handleMCPClose(BuildContext context) async {
    debugPrint('MCP WebView closed, calling MCP URL again');

    try {
      // Call the MCP service again with the same voice input
      final mcpResp = await _voiceAssistService.processVoiceMessageFromMCP(
        _voiceInput,
      );
      if (mcpResp != null && mcpResp.isNotEmpty) {
        debugPrint('MCP Response after close: $mcpResp');

        // If the response still contains login_url, show the WebView again
        if (mcpResp.contains('login_url')) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            enableDrag: false,
            builder:
                (context) => MCPWebViewBottomSheet(
                  url: this.mcpUrl,
                  onClose: () => _handleMCPClose(context),
                ),
          );
        } else {
          if (_voiceInput.contains('transaction')) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              builder:
                  (context) =>
                      TransactionDisplayBottomSheet(jsonResponse: mcpResp),
            );
            clearSearch();
            setVoiceInput('', context);
            // Handle other transaction related voice input
          } else if (_voiceInput.contains('epf') ||
              _voiceInput.contains('provident fund') ||
              mcpResp.contains('"uanAccounts"')) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              builder:
                  (context) => EPFDisplayBottomSheet(jsonResponse: mcpResp),
            );
            clearSearch();
            setVoiceInput('', context);
          } else if (_voiceInput.contains('portfolio')) {
            // Handle portfolio related voice input
          }
        }
      }
    } catch (e) {
      debugPrint('Error calling MCP after close: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Handle service selection
  void onServiceSelected(FinancialServiceModel service) {
    // Handle service selection logic
  }

  // Handle activity selection
  void onActivitySelected(ActivityModel activity) {
    // Handle activity selection logic
  }

  // Handle portfolio details
  void onPortfolioDetails() {
    // Handle portfolio details navigation
  }

  // Handle see all activities
  void onSeeAllActivities() {
    // Handle see all activities navigation
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Complete onboarding
  void completeOnboarding() async {
    _isOnboardingLoading = true;
    _onboardingCompleted = true;
    notifyListeners();

    // Show 3-second loader
    await Future.delayed(const Duration(seconds: 3));

    // Refresh home page data
    await initializeData();

    _isOnboardingLoading = false;
    notifyListeners();
  }

  // Refresh data
  Future<void> refreshData() async {
    _state = HomeViewState.loading;
    notifyListeners();

    try {
      _homeData = await _service.getHomeData();
      _state = HomeViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = HomeViewState.error;
    }

    notifyListeners();
  }
}
