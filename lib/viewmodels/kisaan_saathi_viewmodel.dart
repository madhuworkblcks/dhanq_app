import 'package:dhanq_app/utils/permission_helper.dart';
import 'package:flutter/material.dart';

import '../models/kisaan_saathi_model.dart';
import '../services/kisaan_saathi_service.dart';

enum KisaanSaathiViewState { initial, loading, loaded, error }

class KisaanSaathiViewModel extends ChangeNotifier {
  final KisaanSaathiService _service = KisaanSaathiService();

  KisaanSaathiViewState _state = KisaanSaathiViewState.initial;
  String? _errorMessage;
  LanguageType _selectedLanguage = LanguageType.english;

  // Data models
  FarmFinanceModel? _farmFinanceData;
  List<GovernmentSchemeModel> _governmentSchemes = [];
  WeatherMarketModel? _weatherMarketData;
  MicroLoanSHGModel? _microLoanSHGData;
  VoiceQueryModel? _voiceQueryData;

  // Getters
  KisaanSaathiViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == KisaanSaathiViewState.loading;

  LanguageType get selectedLanguage => _selectedLanguage;
  FarmFinanceModel? get farmFinanceData => _farmFinanceData;
  List<GovernmentSchemeModel> get governmentSchemes => _governmentSchemes;
  WeatherMarketModel? get weatherMarketData => _weatherMarketData;
  MicroLoanSHGModel? get microLoanSHGData => _microLoanSHGData;
  VoiceQueryModel? get voiceQueryData => _voiceQueryData;

  // Initialize data
  Future<void> initializeData() async {
    if (_state == KisaanSaathiViewState.loading) return;

    _setState(KisaanSaathiViewState.loading);

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _service.getFarmFinanceData(),
        _service.getGovernmentSchemes(),
        _service.getWeatherMarketData(),
        _service.getMicroLoanSHGData(),
        _service.getVoiceQueryData(),
      ]);

      _farmFinanceData = results[0] as FarmFinanceModel;
      _governmentSchemes = results[1] as List<GovernmentSchemeModel>;
      _weatherMarketData = results[2] as WeatherMarketModel;
      _microLoanSHGData = results[3] as MicroLoanSHGModel;
      _voiceQueryData = results[4] as VoiceQueryModel;

      _setState(KisaanSaathiViewState.loaded);
    } catch (e) {
      _errorMessage = 'Failed to load Kisaan Saathi data: ${e.toString()}';
      _setState(KisaanSaathiViewState.error);
    }
  }

  // Load all data from JSON at once
  Future<void> loadAllDataFromJSON() async {
    if (_state == KisaanSaathiViewState.loading) return;

    _setState(KisaanSaathiViewState.loading);

    try {
      final jsonData = await _service.getAllKisaanSaathiData();

      // Load farm finance data
      final farmFinanceData = jsonData['farmFinance'] as Map<String, dynamic>;
      final upcomingPaymentsData = farmFinanceData['upcomingPayments'] as List;
      final harvestIncomesData = farmFinanceData['harvestIncomes'] as List;

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

      _farmFinanceData = FarmFinanceModel(
        upcomingPayments: upcomingPayments,
        harvestIncomes: harvestIncomes,
      );

      // Load government schemes
      final schemesData = jsonData['governmentSchemes'] as List;
      _governmentSchemes =
          schemesData
              .map(
                (scheme) => GovernmentSchemeModel(
                  name: scheme['name'] as String,
                  status: scheme['status'] as String,
                  nextInstallment: _parseDate(
                    scheme['nextInstallment'] as String,
                  ),
                  isEligible: scheme['isEligible'] as bool,
                  description: scheme['description'] as String,
                  actionText: scheme['actionText'] as String,
                ),
              )
              .toList();

      // Load weather market data
      final weatherMarketData =
          jsonData['weatherMarket'] as Map<String, dynamic>;
      final marketPricesData = weatherMarketData['marketPrices'] as List;
      final weatherForecastData =
          weatherMarketData['weatherForecast'] as Map<String, dynamic>;

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

      final weatherForecast = WeatherForecastModel(
        condition: weatherForecastData['condition'] as String,
        description: weatherForecastData['description'] as String,
        recommendation: weatherForecastData['recommendation'] as String,
        icon: _parseIcon(weatherForecastData['icon'] as Map<String, dynamic>),
      );

      _weatherMarketData = WeatherMarketModel(
        marketPrices: marketPrices,
        weatherForecast: weatherForecast,
      );

      // Load micro loan SHG data
      final microLoanSHGData = jsonData['microLoanSHG'] as Map<String, dynamic>;
      final loanPaymentsData = microLoanSHGData['loanPayments'] as List;
      final shgMeetingsData = microLoanSHGData['shgMeetings'] as List;

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

      _microLoanSHGData = MicroLoanSHGModel(
        loanPayments: loanPayments,
        shgMeetings: shgMeetings,
      );

      // Load voice query data
      final voiceQueryData = jsonData['voiceQuery'] as Map<String, dynamic>;
      _voiceQueryData = VoiceQueryModel(
        prompt: voiceQueryData['prompt'] as String,
        suggestedQuery: voiceQueryData['suggestedQuery'] as String,
        isListening: voiceQueryData['isListening'] as bool? ?? false,
      );

      _setState(KisaanSaathiViewState.loaded);
    } catch (e) {
      _errorMessage =
          'Failed to load Kisaan Saathi data from JSON: ${e.toString()}';
      _setState(KisaanSaathiViewState.error);
    }
  }

  // Helper method to parse date from JSON string
  DateTime _parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  // Helper method to parse icon from JSON
  IconData _parseIcon(Map<String, dynamic> iconJson) {
    return IconData(
      iconJson['codePoint'] as int,
      fontFamily: iconJson['fontFamily'] as String,
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    _farmFinanceData = null;
    _governmentSchemes = [];
    _weatherMarketData = null;
    _microLoanSHGData = null;
    _voiceQueryData = null;
    await initializeData();
  }

  // Set language
  void setLanguage(LanguageType language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Handle voice query
  Future<void> handleVoiceQuery(String query) async {
    try {
      await _service.processVoiceQuery(query);
      // Refresh data after voice query
      await refreshData();
    } catch (e) {
      _errorMessage = 'Failed to process voice query: ${e.toString()}';
      notifyListeners();
    }
  }

  // Start voice listening
  Future<void> startVoiceListening(BuildContext context) async {
    try {
      final hasPermission = await PermissionHelper.getMicrophonePermission(
        context,
      );
      if (hasPermission) {
        await _service.startVoiceListening();
        // Update voice query data to show listening state
        if (_voiceQueryData != null) {
          _voiceQueryData = VoiceQueryModel(
            prompt: _voiceQueryData!.prompt,
            suggestedQuery: _voiceQueryData!.suggestedQuery,
            isListening: true,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to start voice listening: ${e.toString()}';
      notifyListeners();
    }
  }

  // Stop voice listening
  Future<void> stopVoiceListening() async {
    try {
      await _service.stopVoiceListening();
      // Update voice query data to show not listening state
      if (_voiceQueryData != null) {
        _voiceQueryData = VoiceQueryModel(
          prompt: _voiceQueryData!.prompt,
          suggestedQuery: _voiceQueryData!.suggestedQuery,
          isListening: false,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to stop voice listening: ${e.toString()}';
      notifyListeners();
    }
  }

  // Check scheme status
  Future<void> checkSchemeStatus(String schemeName) async {
    try {
      await _service.checkSchemeStatus(schemeName);
      // Refresh data after status check
      await refreshData();
    } catch (e) {
      _errorMessage = 'Failed to check scheme status: ${e.toString()}';
      notifyListeners();
    }
  }

  // View market prices
  Future<void> viewMarketPrices() async {
    try {
      await _service.viewMarketPrices();
      // Handle navigation or show detailed prices
    } catch (e) {
      _errorMessage = 'Failed to view market prices: ${e.toString()}';
      notifyListeners();
    }
  }

  // Repay loan
  Future<void> repayLoan(String loanId) async {
    try {
      await _service.repayLoan(loanId);
      // Refresh data after loan repayment
      await refreshData();
    } catch (e) {
      _errorMessage = 'Failed to process loan repayment: ${e.toString()}';
      notifyListeners();
    }
  }

  // Join SHG meeting
  Future<void> joinSHGMeeting(String meetingId) async {
    try {
      await _service.joinSHGMeeting(meetingId);
      // Handle meeting joining logic
    } catch (e) {
      _errorMessage = 'Failed to join SHG meeting: ${e.toString()}';
      notifyListeners();
    }
  }

  // Handle farm finance tap
  void onFarmFinanceTap() {
    print('Farm finance section tapped');
    // Navigate to detailed farm finance screen
  }

  // Handle government scheme tap
  void onGovernmentSchemeTap(GovernmentSchemeModel scheme) {
    print('Government scheme tapped: ${scheme.name}');
    // Handle scheme selection
  }

  // Handle weather market tap
  void onWeatherMarketTap() {
    print('Weather & market section tapped');
    // Navigate to detailed weather market screen
  }

  // Handle micro loan SHG tap
  void onMicroLoanSHGTap() {
    print('Micro loan & SHG section tapped');
    // Navigate to detailed micro loan SHG screen
  }

  // Handle suggested query tap
  void onSuggestedQueryTap() {
    if (_voiceQueryData != null) {
      handleVoiceQuery(_voiceQueryData!.suggestedQuery);
    }
  }

  // Private methods
  void _setState(KisaanSaathiViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
