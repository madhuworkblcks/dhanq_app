import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kisaan_saathi_model.dart';
import '../viewmodels/kisaan_saathi_viewmodel.dart';

class KisaanSaathiScreen extends StatefulWidget {
  const KisaanSaathiScreen({super.key});

  @override
  State<KisaanSaathiScreen> createState() => _KisaanSaathiScreenState();
}

class _KisaanSaathiScreenState extends State<KisaanSaathiScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => KisaanSaathiViewModel(),
      child: Consumer<KisaanSaathiViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == KisaanSaathiViewState.initial) {
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

  Widget _buildBody(KisaanSaathiViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == KisaanSaathiViewState.error) {
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

            // Voice Assistant Section
            _buildVoiceAssistantSection(viewModel),

            // Farm Finance Section
            _buildFarmFinanceSection(viewModel),

            // Government Schemes Section
            _buildGovernmentSchemesSection(viewModel),

            // Weather & Market Section
            _buildWeatherMarketSection(viewModel),

            // Micro-Loans & SHG Section
            _buildMicroLoanSHGSection(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(KisaanSaathiViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: Colors.white,
      child: Row(
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
              'Kisaan Saathi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Language buttons
          Row(
            children: [
              _buildLanguageButton('EN', LanguageType.english, viewModel),
              const SizedBox(width: 8),
              _buildLanguageButton('हिं', LanguageType.hindi, viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    String text,
    LanguageType language,
    KisaanSaathiViewModel viewModel,
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

  Widget _buildVoiceAssistantSection(KisaanSaathiViewModel viewModel) {
    if (viewModel.voiceQueryData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.voiceQueryData!.prompt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: viewModel.onSuggestedQueryTap,
                  child: Text(
                    '"${viewModel.voiceQueryData!.suggestedQuery}"',
                    style: const TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1E3A8A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Voice button
          GestureDetector(
            onTap: () {
              if (viewModel.voiceQueryData!.isListening) {
                viewModel.stopVoiceListening();
              } else {
                viewModel.startVoiceListening(context);
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                viewModel.voiceQueryData!.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmFinanceSection(KisaanSaathiViewModel viewModel) {
    if (viewModel.farmFinanceData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Farm Finance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Content card
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
                // Upcoming payments
                ...viewModel.farmFinanceData!.upcomingPayments.map(
                  (payment) => _buildPaymentItem(payment),
                ),
                const Divider(height: 24),
                // Harvest incomes
                ...viewModel.farmFinanceData!.harvestIncomes.map(
                  (income) => _buildIncomeItem(income),
                ),
                const SizedBox(height: 16),
                // Voice prompt
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: const Color(0xFF1E3A8A),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Speak to learn more',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1E3A8A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(UpcomingPaymentModel payment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Due: ${payment.formattedDueDate}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            payment.formattedAmount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(HarvestIncomeModel income) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.crop,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Expected: ${income.formattedDate}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            income.formattedIncome,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentSchemesSection(KisaanSaathiViewModel viewModel) {
    if (viewModel.governmentSchemes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Government Schemes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Scheme cards
          ...viewModel.governmentSchemes.map(
            (scheme) => _buildSchemeCard(scheme, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(
    GovernmentSchemeModel scheme,
    KisaanSaathiViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scheme.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => viewModel.checkSchemeStatus(scheme.name),
                  child: Text(
                    scheme.actionText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.isEligible ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  scheme.isEligible ? Icons.check : Icons.warning,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  scheme.isEligible ? 'Eligible' : 'Check',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMarketSection(KisaanSaathiViewModel viewModel) {
    if (viewModel.weatherMarketData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Weather & Market',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Market prices card
          _buildMarketPricesCard(viewModel),
          const SizedBox(height: 12),

          // Weather forecast card
          _buildWeatherForecastCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildMarketPricesCard(KisaanSaathiViewModel viewModel) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Market Prices",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...viewModel.weatherMarketData!.marketPrices.map(
            (price) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price.crop,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    price.formattedPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: viewModel.viewMarketPrices,
            child: const Text(
              'View Prices >',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherForecastCard(KisaanSaathiViewModel viewModel) {
    final weather = viewModel.weatherMarketData!.weatherForecast;

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.condition,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.recommendation,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(weather.icon, color: const Color(0xFF1E3A8A), size: 32),
        ],
      ),
    );
  }

  Widget _buildMicroLoanSHGSection(KisaanSaathiViewModel viewModel) {
    if (viewModel.microLoanSHGData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'Micro-Loans & SHG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Loan payment card
          _buildLoanPaymentCard(viewModel),
          const SizedBox(height: 12),

          // SHG meeting card
          _buildSHGMeetingCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildLoanPaymentCard(KisaanSaathiViewModel viewModel) {
    final loan = viewModel.microLoanSHGData!.loanPayments.first;

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Payment Due',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loan.formattedDueDate} • Amount ${loan.formattedAmount}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => viewModel.repayLoan('LOAN001'),
            child: const Text(
              'Repay >',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSHGMeetingCard(KisaanSaathiViewModel viewModel) {
    final meeting = viewModel.microLoanSHGData!.shgMeetings.first;

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHG Meeting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meeting.formattedDate,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.group, color: const Color(0xFF1E3A8A), size: 24),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => viewModel.joinSHGMeeting('MEETING001'),
            child: const Text(
              'Join Meeting >',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
