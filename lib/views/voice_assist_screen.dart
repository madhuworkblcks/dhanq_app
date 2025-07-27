import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/voice_assist_model.dart';
import '../viewmodels/voice_assist_viewmodel.dart';

class VoiceAssistScreen extends StatefulWidget {
  const VoiceAssistScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistScreen> createState() => _VoiceAssistScreenState();
}

class _VoiceAssistScreenState extends State<VoiceAssistScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VoiceAssistViewModel(),
      child: Consumer<VoiceAssistViewModel>(
        builder: (context, viewModel, child) {
          // Initialize data after the widget is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.state == VoiceAssistViewState.initial) {
              viewModel.initializeData();
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(viewModel),
                  Expanded(child: _buildContent(viewModel)),
                  _buildVoiceInput(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(VoiceAssistViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
              'ExpenseVoice',
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
              _buildLanguageButton('हि', LanguageType.hindi, viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    String text,
    LanguageType language,
    VoiceAssistViewModel viewModel,
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

  Widget _buildContent(VoiceAssistViewModel viewModel) {
    if (viewModel.state == VoiceAssistViewState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      );
    }

    if (viewModel.state == VoiceAssistViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => viewModel.refreshData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshData(),
      color: const Color(0xFF1E3A8A),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBudgetSummary(viewModel),
            const SizedBox(height: 20),
            _buildChatMessages(viewModel),
            const SizedBox(height: 20),
            _buildWeeklySpending(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummary(VoiceAssistViewModel viewModel) {
    if (viewModel.budgetSummary == null) return const SizedBox.shrink();
    final summary = viewModel.budgetSummary!;

    return Container(
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
          Text(
            summary.month,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary.formattedBudget,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ${summary.formattedSpent}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          summary.spentPercentage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: summary.progressPercent,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF1E3A8A),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved: ${summary.formattedSaved}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          summary.savedPercentage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: summary.saved / summary.budget,
                      backgroundColor: Colors.grey[200],
                      color: Colors.orange[400],
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(VoiceAssistViewModel viewModel) {
    return Column(
      children:
          viewModel.chatMessages
              .map((message) => _buildChatBubble(message))
              .toList(),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        message.isUser ? const Color(0xFF1E3A8A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        message.isUser
                            ? null
                            : [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: message.isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (message.category != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (message.categoryIcon != null)
                              Icon(
                                message.categoryIcon,
                                size: 16,
                                color:
                                    message.isUser
                                        ? Colors.white70
                                        : const Color(0xFF1E3A8A),
                              ),
                            if (message.categoryIcon != null)
                              const SizedBox(width: 4),
                            Text(
                              message.category!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    message.isUser
                                        ? Colors.white70
                                        : const Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklySpending(VoiceAssistViewModel viewModel) {
    if (viewModel.weeklySpending == null) return const SizedBox.shrink();
    final weekly = viewModel.weeklySpending!;

    return Container(
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
          Text(
            'Last week you spent ${weekly.formattedTotalSpent}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  weekly.dailySpending
                      .map((day) => _buildSpendingBar(day))
                      .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (String day in [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Highest day: ${weekly.highestDay} (${weekly.formattedHighestAmount})',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Main category: ${weekly.mainCategory}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingBar(DailySpending day) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 24,
            decoration: BoxDecoration(
              color: day.isHighest ? const Color(0xFF1E3A8A) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInput(VoiceAssistViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText:
                      viewModel.isListening
                          ? 'Listening...'
                          : 'Tap to speak...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    viewModel.sendTextMessage(text);
                    _textController.clear();
                    _scrollToBottom();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (viewModel.isListening) {
                viewModel.stopListening();
              } else {
                viewModel.startListening(context);
                // Simulate voice input for demo
                // Future.delayed(const Duration(seconds: 2), () {
                //   viewModel.stopListening();
                //   viewModel.processVoiceInput('Khaad khareeda ₹300 ka');
                //   _scrollToBottom();
                // });
              }
            },
            child: Container(
              width: 56,
              height: 56,
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

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
