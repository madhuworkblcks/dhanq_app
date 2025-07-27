import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vyapar_margdarshak_model.dart';
import '../viewmodels/vyapar_margdarshak_viewmodel.dart';

class VyaparMargdarshakScreen extends StatefulWidget {
  const VyaparMargdarshakScreen({super.key});

  @override
  State<VyaparMargdarshakScreen> createState() =>
      _VyaparMargdarshakScreenState();
}

class _VyaparMargdarshakScreenState extends State<VyaparMargdarshakScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VyaparMargdarshakViewModel(),
      child: Consumer<VyaparMargdarshakViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == VyaparMargdarshakViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == VyaparMargdarshakViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header
            _buildHeader(viewModel),

            // Today's Summary Card
            _buildTodaySummaryCard(viewModel),

            // Navigation Tabs
            _buildNavigationTabs(viewModel),

            // Content based on selected tab
            _buildTabContent(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(VyaparMargdarshakViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              const Expanded(
                child: Text(
                  'Vyapar Margdarshak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Language buttons (updated)
              Row(
                children: [
                  _buildLanguageButton('EN', LanguageType.english, viewModel),
                  const SizedBox(width: 8),
                  _buildLanguageButton('हिं', LanguageType.hindi, viewModel),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Hello, Rahul's Store",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    String text,
    LanguageType language,
    VyaparMargdarshakViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedLanguage == language;
    return GestureDetector(
      onTap: () => viewModel.setLanguage(language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3A8A), width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.todaySummary == null) return const SizedBox.shrink();

    final summary = viewModel.todaySummary!;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  'Sales',
                  summary.formattedSales,
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Expenses',
                  summary.formattedExpenses,
                  Icons.receipt,
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Profit',
                  summary.formattedProfit,
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildNavigationTabs(VyaparMargdarshakViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTabButton(
            'Business Health',
            BusinessTab.businessHealth,
            viewModel,
          ),
          const SizedBox(width: 30),
          _buildTabButton(
            'Finance Options',
            BusinessTab.financeOptions,
            viewModel,
          ),
          const SizedBox(width: 30),
          _buildTabButton('Inventory', BusinessTab.inventory, viewModel),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String text,
    BusinessTab tab,
    VyaparMargdarshakViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedTab == tab;

    return GestureDetector(
      onTap: () => viewModel.setSelectedTab(tab),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(VyaparMargdarshakViewModel viewModel) {
    switch (viewModel.selectedTab) {
      case BusinessTab.businessHealth:
        return _buildBusinessHealthContent(viewModel);
      case BusinessTab.financeOptions:
        return _buildFinanceOptionsContent(viewModel);
      case BusinessTab.inventory:
        return _buildInventoryContent(viewModel);
    }
  }

  Widget _buildBusinessHealthContent(VyaparMargdarshakViewModel viewModel) {
    return Column(
      children: [
        // Monthly Profit Section
        _buildMonthlyProfitSection(viewModel),

        // Quick Actions Section
        _buildQuickActionsSection(viewModel),

        // Business Growth Section
        _buildBusinessGrowthSection(viewModel),

        // Loan Offer Section
        _buildLoanOfferSection(viewModel),
      ],
    );
  }

  Widget _buildMonthlyProfitSection(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.monthlyProfit == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Profit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Bar Chart
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        viewModel.monthlyProfit!.profitData
                            .map(
                              (profitData) =>
                                  _buildProfitBar(profitData, viewModel),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Month Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      viewModel.monthlyProfit!.profitData
                          .map(
                            (profitData) => Text(
                              profitData.month,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Last 6 months',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.monthlyProfit!.formattedTotalProfit,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitBar(
    ProfitDataModel profitData,
    VyaparMargdarshakViewModel viewModel,
  ) {
    final height = (profitData.profit / 5000) * 80; // Max height 80
    final color =
        profitData.isCurrentMonth
            ? const Color(0xFF8B4513)
            : const Color(0xFFFFF3E0);

    return GestureDetector(
      onTap: () => viewModel.onProfitBarTap(profitData),
      child: Column(
        children: [
          Container(
            width: 30,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.quickActions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  viewModel.quickActions[0],
                  viewModel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  viewModel.quickActions[1],
                  viewModel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    QuickActionModel action,
    VyaparMargdarshakViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.handleQuickAction(action),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                action.icon,
                color: const Color(0xFF1E3A8A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessGrowthSection(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.businessGrowth == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Growth',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children:
                viewModel.businessGrowth!.metrics
                    .map(
                      (metric) => Expanded(
                        child: _buildGrowthMetricCard(metric, viewModel),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetricCard(
    GrowthMetricModel metric,
    VyaparMargdarshakViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => viewModel.onGrowthMetricTap(metric),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(metric.icon, color: metric.percentageColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  metric.formattedPercentage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: metric.percentageColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.comparison,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanOfferSection(VyaparMargdarshakViewModel viewModel) {
    if (viewModel.loanOffer == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: viewModel.applyForLoan,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.loanOffer!.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.loanOffer!.description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceOptionsContent(VyaparMargdarshakViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Finance Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for finance options
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Finance options will be displayed here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContent(VyaparMargdarshakViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder for inventory
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Inventory details will be displayed here',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
