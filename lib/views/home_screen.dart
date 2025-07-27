import 'package:dhanq_app/views/bachat_guru_screen.dart';
import 'package:dhanq_app/views/voice_assist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_model.dart';
import '../models/financial_service_model.dart';
import '../services/auth_service.dart';
import '../services/home_service.dart';
import '../viewmodels/home_viewmodel.dart';
import 'asset_management_screen.dart';
import 'debt_doctor_screen.dart';
import 'financial_health_score_screen.dart';
import 'goal_planning_screen.dart';
import 'integrations_screen.dart';
import 'kisaan_saathi_screen.dart';
import 'login_screen.dart';
import 'smart_investor_screen.dart';
import 'tax_whisperer_screen.dart';
import 'vyapar_margdarshak_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data when the widget is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == HomeViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: _buildBody(viewModel),
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildBody(HomeViewModel viewModel) {
    if (viewModel.isLoading || viewModel.isOnboardingLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            const SizedBox(height: 16),
            Text(
              viewModel.isOnboardingLoading
                  ? 'Setting up your personalized experience...'
                  : 'Loading...',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
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

            // Search Bar
            _buildSearchBar(viewModel),

            // Portfolio Section
            _buildPortfolioSection(viewModel),

            // Financial Services Section
            _buildFinancialServicesSection(viewModel),

            // Recent Activity Section
            _buildRecentActivitySection(viewModel),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Q',
                          style: TextStyle(
                            color: Color(0xFFEB5D37),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // App Name
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Dhan',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Q',
                        style: TextStyle(
                          color: Color(0xFFEB5D37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Onboard Button (only if not completed)
              if (!viewModel.onboardingCompleted)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E3A8A),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => _showOnboardSurvey(context, viewModel),
                    child: const Text(
                      'Onboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              // Profile Button
              GestureDetector(
                onTap: () => _showProfileSheet(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.person, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Location Segmented Control
          _buildLocationSegmentedControl(viewModel),
        ],
      ),
    );
  }

  Widget _buildLocationSegmentedControl(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegmentButton('Urban', LocationType.urban, viewModel),
          _buildSegmentButton('Rural', LocationType.rural, viewModel),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    String text,
    LocationType type,
    HomeViewModel viewModel,
  ) {
    final isSelected = viewModel.locationType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setLocationType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: const Color(0xFF1E3A8A), width: 1)
                    : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: viewModel.searchController,
              onChanged: viewModel.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search for services...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (viewModel.isListening) {
                viewModel.stopListening();
              } else {
                viewModel.startVoiceListening(context);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    viewModel.isListening
                        ? Colors.red
                        : const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                viewModel.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(HomeViewModel viewModel) {
    if (viewModel.portfolioData == null) return const SizedBox.shrink();

    final portfolio = viewModel.portfolioData!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: viewModel.onPortfolioDetails,
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPortfolioItem(
                  'Total Value',
                  portfolio.formattedTotalValue,
                ),
              ),
              Expanded(
                child: _buildPortfolioItem(
                  'Today\'s Gain',
                  portfolio.formattedTodayGain,
                  portfolio.todayGainColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPortfolioItem(
                  'Total Gain',
                  portfolio.formattedTotalGain,
                  portfolio.totalGainColor,
                ),
              ),
              Expanded(
                child: _buildPortfolioItem(
                  'Gain %',
                  portfolio.formattedGainPercentage,
                  portfolio.gainPercentageColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialServicesSection(HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemCount: viewModel.financialServices.length,
            itemBuilder: (context, index) {
              final service = viewModel.financialServices[index];
              return _buildServiceCard(service, viewModel);
            },
          ),
          // Goal Planning Card (Full Width) - Only for Urban
          if (viewModel.locationType == LocationType.urban) ...[
            const SizedBox(height: 8),
            _buildGoalPlanningCard(viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalPlanningCard(HomeViewModel viewModel) {
    return GestureDetector(
      onTap: () => _handleGoalPlanningTap(viewModel),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A).withOpacity(0.05),
              const Color(0xFF1E3A8A).withOpacity(0.02),
            ],
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E3A8A),
                        const Color(0xFF1E3A8A).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goal Planning',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Advanced Financial Planning',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildFeatureChip('Retirement'),
                const SizedBox(width: 8),
                _buildFeatureChip('Education'),
                const SizedBox(width: 8),
                _buildFeatureChip('Travel'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleGoalPlanningTap(HomeViewModel viewModel) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GoalPlanningScreen()));
  }

  Widget _buildServiceCard(
    FinancialServiceModel service,
    HomeViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () => _handleServiceTap(service, viewModel),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                service.icon,
                size: 18,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleServiceTap(
    FinancialServiceModel service,
    HomeViewModel viewModel,
  ) {
    viewModel.onServiceSelected(service);

    // Navigate to specific screens based on service
    switch (service.name) {
      case 'Asset Management':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AssetManagementScreen(),
          ),
        );
        break;
      case 'Smart Investor Agent':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SmartInvestorScreen()),
        );
        break;
      case 'Debt-Doctor':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DebtDoctorScreen()),
        );
        break;
      case 'Tax Whisperer':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TaxWhispererScreen()),
        );
        break;
      case 'Financial Health Score':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => FinancialHealthScoreScreen(
                  locationType: viewModel.locationType,
                ),
          ),
        );
        break;
      case 'Fintech Connect':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    IntegrationsScreen(locationType: viewModel.locationType),
          ),
        );
        break;
      case 'Kisaan Saathi':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const KisaanSaathiScreen()),
        );
        break;
      case 'Vyapar Margdarshak':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const VyaparMargdarshakScreen(),
          ),
        );
        break;
      case 'Bachat Guru':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const BachatGuruScreen()),
        );
        break;
      case 'Voice Assistant':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const VoiceAssistScreen()),
        );
        break;
      // Add other service navigations here
      default:
        // Show a placeholder dialog for other services
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(service.name),
                content: Text('${service.name} feature coming soon!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
    }
  }

  Widget _buildRecentActivitySection(HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: viewModel.onSeeAllActivities,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...viewModel.recentActivities
              .take(3)
              .map((activity) => _buildActivityItem(activity, viewModel))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityModel activity, HomeViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.onActivitySelected(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
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
                color: activity.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(activity.icon, color: activity.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: activity.amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showProfileSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String mobile = prefs.getString('mobile_number') ?? '';
    // Replace with actual user data
    final String name = 'Lakshmana';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mobile,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  // Clear stored data using AuthService
                  final authService = AuthService();
                  await authService.logout();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showOnboardSurvey(BuildContext context, HomeViewModel viewModel) {
    final _formKey = GlobalKey<FormState>();
    double monthlyIncome = 50000;
    String? placeOfStay;
    String? languagePref;
    double monthlyExpense = 30000;
    double bankBalance = 100000;
    double loans = 0;
    List<String> selectedGoals = [];

    final List<String> financeGoals = [
      'Loan free in 2 years',
      'New business after 3 years',
      'Buy car in 3 years',
      'Buy house in 5 years',
      'Financial freedom in 5 years',
      'Clear Student loan in 4 years',
      'Earn on investment',
      'Child Education support',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.only(top: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Welcome to Dhan',
                                      style: TextStyle(
                                        color: Color(0xFF1E3A8A),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Q!',
                                      style: TextStyle(
                                        color: Color(0xFFEB5D37),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'We\'d love to learn more about your financial journey. This will help us tailor our services to your needs.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        _buildSliderField(
                          label: 'Monthly Income (मासिक आय)',
                          value: monthlyIncome,
                          onChanged:
                              (val) => setState(() => monthlyIncome = val),
                          min: 10000,
                          max: 10000000,
                        ),
                        _buildSurveyDropdown(
                          label: 'Place of Stay (शहर/गाँव)',
                          items: const ['City (शहर)', 'Village (गाँव)'],
                          onSaved: (val) => placeOfStay = val,
                        ),
                        _buildSurveyDropdown(
                          label: 'Language Preference (भाषा पसंद)',
                          items: const ['Hindi', 'Telugu', 'Tamil', 'Kannada'],
                          onSaved: (val) => languagePref = val,
                        ),
                        _buildSliderField(
                          label: 'Monthly Expense (मासिक खर्च)',
                          value: monthlyExpense,
                          onChanged:
                              (val) => setState(() => monthlyExpense = val),
                          min: 10000,
                          max: 10000000,
                        ),
                        _buildSliderField(
                          label: 'Bank Balance (बैंक बैलेंस)',
                          value: bankBalance,
                          onChanged: (val) => setState(() => bankBalance = val),
                          min: 10000,
                          max: 10000000,
                        ),
                        _buildSliderField(
                          label: 'Loans (ऋण)',
                          value: loans,
                          onChanged: (val) => setState(() => loans = val),
                          min: 0,
                          max: 10000000,
                        ),
                        _buildMultiSelectField(
                          label: 'Finance Goals (वित्तीय लक्ष्य)',
                          options: financeGoals,
                          selectedOptions: selectedGoals,
                          onChanged:
                              (val) => setState(() => selectedGoals = val),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                viewModel.completeOnboarding();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text(
                              'Complete Onboarding',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSurveyField({
    required String label,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
        ),
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSurveyDropdown({
    required String label,
    required List<String> items,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
        ),
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: (_) {},
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1E3A8A),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFF1E3A8A),
              overlayColor: const Color(0xFF1E3A8A).withOpacity(0.2),
              valueIndicatorColor: const Color(0xFF1E3A8A),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 99,
              label: '₹${(value / 1000).toStringAsFixed(0)}K',
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${(min / 1000).toStringAsFixed(0)}K',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '₹${(max / 1000000).toStringAsFixed(0)}M',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E3A8A)),
            ),
            child: Column(
              children:
                  options.map((option) {
                    final isSelected = selectedOptions.contains(option);
                    return CheckboxListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        final newSelection = List<String>.from(selectedOptions);
                        if (value == true) {
                          newSelection.add(option);
                        } else {
                          newSelection.remove(option);
                        }
                        onChanged(newSelection);
                      },
                      activeColor: const Color(0xFF1E3A8A),
                      checkColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      dense: true,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
