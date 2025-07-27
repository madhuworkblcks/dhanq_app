import 'package:flutter/material.dart';

import '../models/asset_model.dart';
import '../models/portfolio_model.dart';
import '../services/asset_service.dart';

enum AssetViewState { initial, loading, loaded, error }

enum AssetTab { overview, assets, liabilities, recurring }

class AssetViewModel extends ChangeNotifier {
  final AssetService _service = AssetService();

  AssetViewState _state = AssetViewState.initial;
  AssetManagementModel? _assetData;
  String? _errorMessage;
  AssetTab _selectedTab = AssetTab.assets;

  // Getters
  AssetViewState get state => _state;
  AssetManagementModel? get assetData => _assetData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AssetViewState.loading;
  AssetTab get selectedTab => _selectedTab;

  // Legacy getters for backward compatibility
  PortfolioModel? get portfolioData => _assetData?.portfolio;
  List<AssetModel> get assets => _assetData?.assets ?? [];
  Map<String, double> get allocation => _assetData?.allocation ?? {};
  List<TransactionModel> get recentTransactions => _assetData?.recentTransactions ?? [];
  PerformanceModel? get performance => _assetData?.performance;
  List<InsightModel> get insights => _assetData?.insights ?? [];

  // Additional getters for UI compatibility
  AssetAllocationModel? get assetAllocation {
    if (_assetData == null) return null;
    return AssetAllocationModel(
      totalNetWorth: _assetData!.portfolio.totalValue,
      ytdChange: _assetData!.portfolio.gainPercentage,
      allocations: _assetData!.allocation.entries.map((entry) => 
        AssetAllocationItem(
          name: entry.key,
          percentage: entry.value,
          value: _assetData!.portfolio.totalValue * entry.value / 100,
          color: _getColorForAssetType(entry.key),
        )
      ).toList(),
    );
  }

  List<AssetCategoryModel> get assetCategories {
    if (_assetData == null) return [];
    
    // Group assets by type
    final Map<String, List<AssetModel>> groupedAssets = {};
    for (final asset in _assetData!.assets) {
      groupedAssets.putIfAbsent(asset.type, () => []).add(asset);
    }
    
    return groupedAssets.entries.map((entry) => 
      AssetCategoryModel(
        name: entry.key,
        totalValue: entry.value.fold(0.0, (sum, asset) => sum + asset.value),
        assets: entry.value,
      )
    ).toList();
  }

  List<AssetModel> get liabilities => []; // Placeholder for future implementation
  List<AssetModel> get recurringAssets => []; // Placeholder for future implementation

  // Helper method to get color for asset type
  Color _getColorForAssetType(String type) {
    switch (type) {
      case 'Stocks':
        return Colors.orange;
      case 'Mutual Funds':
        return Colors.blue;
      case 'Fixed Deposits':
        return Colors.green;
      case 'Cash':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  // Initialize data
  Future<void> initializeData() async {
    if (_state == AssetViewState.initial) {
      _state = AssetViewState.loading;
      notifyListeners();

      try {
        _assetData = await _service.getAssetManagementData();
        _state = AssetViewState.loaded;
      } catch (e) {
        _errorMessage = e.toString();
        _state = AssetViewState.error;
      }

      notifyListeners();
    }
  }

  // Set selected tab
  void setSelectedTab(AssetTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Refresh data
  Future<void> refreshData() async {
    _state = AssetViewState.loading;
    notifyListeners();

    try {
      _assetData = await _service.getAssetManagementData();
      _state = AssetViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AssetViewState.error;
    }

    notifyListeners();
  }
}
