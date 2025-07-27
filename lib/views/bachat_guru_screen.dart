import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bachat_guru_model.dart';
import '../viewmodels/bachat_guru_viewmodel.dart';

class BachatGuruScreen extends StatefulWidget {
  const BachatGuruScreen({super.key});

  @override
  State<BachatGuruScreen> createState() => _BachatGuruScreenState();
}

class _BachatGuruScreenState extends State<BachatGuruScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BachatGuruViewModel(),
      child: Consumer<BachatGuruViewModel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == BachatGuruViewState.initial) {
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

  Widget _buildBody(BachatGuruViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.state == BachatGuruViewState.error) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSavingsSummary(viewModel),
            _buildSavingsTips(viewModel),
            _buildSavingsOptions(viewModel),
            _buildCommunityChallenges(viewModel),
            _buildAchievements(viewModel),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<BachatGuruViewModel>(
      builder: (context, viewModel, child) {
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
                  'Bachat Guru',
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
      },
    );
  }

  Widget _buildLanguageButton(
    String text,
    LanguageType language,
    BachatGuruViewModel viewModel,
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

  Widget _buildSavingsSummary(BachatGuruViewModel viewModel) {
    if (viewModel.savingsSummary == null) return const SizedBox.shrink();
    final summary = viewModel.savingsSummary!;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Power',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Savings',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            summary.formattedSavings,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            summary.status,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: summary.progressPercent,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF1E3A8A),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    '+${summary.streakCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Start', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                'Current',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text('Goal', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTips(BachatGuruViewModel viewModel) {
    if (viewModel.savingsTips.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Savings Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                viewModel.savingsTips
                    .map(
                      (tip) => Expanded(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsOptions(BachatGuruViewModel viewModel) {
    if (viewModel.savingsOptions.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Savings Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                viewModel.savingsOptions
                    .map(
                      (option) => Expanded(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    option.icon,
                                    color: const Color(0xFF1E3A8A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Min: ${option.minAmount}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Returns: ${option.returns}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Period: ${option.period}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityChallenges(BachatGuruViewModel viewModel) {
    if (viewModel.communityChallenges.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children:
                viewModel.communityChallenges
                    .map(
                      (challenge) => Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  challenge.icon,
                                  color: const Color(0xFF1E3A8A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    challenge.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              challenge.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  challenge.formattedTarget,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${challenge.months} months',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: challenge.progressPercent,
                              backgroundColor: const Color(
                                0xFF1E3A8A,
                              ).withOpacity(0.2),
                              color: const Color(0xFF1E3A8A),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BachatGuruViewModel viewModel) {
    if (viewModel.achievements.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                viewModel.achievements
                    .map(
                      (ach) => Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                ach.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ach.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
