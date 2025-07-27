import 'dart:convert';

import 'package:flutter/material.dart';

class TransactionDisplayBottomSheet extends StatelessWidget {
  final String jsonResponse;

  const TransactionDisplayBottomSheet({Key? key, required this.jsonResponse})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'MCP View - Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions content
          Expanded(child: _buildTransactionsContent()),
        ],
      ),
    );
  }

  Widget _buildTransactionsContent() {
    try {
      final Map<String, dynamic> response = json.decode(jsonResponse);
      final result = response['result'];
      final content = result['content'] as List;

      if (content.isNotEmpty) {
        final textContent = content[0]['text'] as String;
        final transactionData = json.decode(textContent);
        final bankTransactions = transactionData['bankTransactions'] as List;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bankTransactions.length,
          itemBuilder: (context, bankIndex) {
            final bank = bankTransactions[bankIndex];
            final bankName = bank['bank'] as String;
            final transactions = bank['txns'] as List;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bank header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bankName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${transactions.length} transactions',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transactions list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, transactionIndex) {
                      final transaction =
                          transactions[transactionIndex] as List;
                      final amount = transaction[0] as String;
                      final narration = transaction[1] as String;
                      final date = transaction[2] as String;
                      final type = transaction[3] as int;
                      final mode = transaction[4] as String;
                      final balance = transaction[5] as String;

                      final isCredit =
                          type == 1 || type == 4; // CREDIT or INTEREST
                      final isDebit =
                          type == 2 ||
                          type == 6 ||
                          type == 7; // DEBIT, INSTALLMENT, or CLOSING

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Transaction icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    isCredit
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isCredit ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Transaction details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    narration,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _formatDate(date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          mode,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Amount and balance
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isCredit ? '+' : '-'}₹${_formatAmount(amount)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCredit ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Balance: ₹${_formatAmount(balance)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error parsing transactions: $e');
    }

    // Fallback if parsing fails
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Please try again later', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatAmount(String amount) {
    try {
      final double amountValue = double.parse(amount);
      if (amountValue >= 100000) {
        return '${(amountValue / 100000).toStringAsFixed(1)}L';
      } else if (amountValue >= 1000) {
        return '${(amountValue / 1000).toStringAsFixed(1)}K';
      } else {
        return amountValue.toStringAsFixed(0);
      }
    } catch (e) {
      return amount;
    }
  }
}
