import 'dart:convert';

import 'package:flutter/material.dart';

class EPFDisplayBottomSheet extends StatelessWidget {
  final String jsonResponse;

  const EPFDisplayBottomSheet({Key? key, required this.jsonResponse})
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
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'MCP View - EPF',
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
          // EPF content
          Expanded(child: _buildEPFContent()),
        ],
      ),
    );
  }

  Widget _buildEPFContent() {
    try {
      final Map<String, dynamic> response = json.decode(jsonResponse);
      final result = response['result'];
      final content = result['content'] as List;

      if (content.isNotEmpty) {
        final textContent = content[0]['text'] as String;
        final epfData = json.decode(textContent);
        final uanAccounts = epfData['uanAccounts'] as List;

        if (uanAccounts.isNotEmpty) {
          final account = uanAccounts[0];
          final rawDetails = account['rawDetails'];
          final estDetails = rawDetails['est_details'] as List;
          final overallBalance = rawDetails['overall_pf_balance'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Balance Card
                _buildOverallBalanceCard(overallBalance),
                const SizedBox(height: 20),

                // Employment History
                const Text(
                  'Employment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),

                // Employment Details
                ...estDetails.map((est) => _buildEmploymentCard(est)).toList(),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error parsing EPF data: $e');
    }

    // Fallback if parsing fails
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load EPF data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Please try again later', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOverallBalanceCard(Map<String, dynamic> overallBalance) {
    final currentPFBalance = overallBalance['current_pf_balance'] ?? '0';
    final pensionBalance = overallBalance['pension_balance'] ?? '0';
    final employeeShareTotal = overallBalance['employee_share_total'] ?? {};
    final employerShareTotal = overallBalance['employer_share_total'] ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Total EPF Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current PF Balance:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '₹${_formatAmount(currentPFBalance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pension Balance:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '₹${_formatAmount(pensionBalance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Share breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Employee Share:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '₹${_formatAmount(employeeShareTotal['balance'] ?? '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Employer Share:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '₹${_formatAmount(employerShareTotal['balance'] ?? '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentCard(Map<String, dynamic> est) {
    final estName = est['est_name'] ?? 'Unknown Company';
    final memberId = est['member_id'] ?? 'N/A';
    final office = est['office'] ?? 'N/A';
    final dojEpf = est['doj_epf'] ?? 'N/A';
    final doeEpf = est['doe_epf'] ?? 'N/A';
    final pfBalance = est['pf_balance'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company name and member ID
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Member ID: $memberId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Office and dates
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Office', office, Icons.location_on),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Joined',
                    _formatDate(dojEpf),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Left',
                    _formatDate(doeEpf),
                    Icons.calendar_month,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Net Balance',
                    '₹${_formatAmount(pfBalance['net_balance'] ?? '0')}',
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Balance breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Employee Share:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${_formatAmount(pfBalance['employee_share']?['balance'] ?? '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Employer Share:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${_formatAmount(pfBalance['employer_share']?['balance'] ?? '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString == 'NOT AVAILABLE' || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[0]}/${parts[1]}/${parts[2]}';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatAmount(String amount) {
    try {
      final double amountValue = double.parse(amount);
      if (amountValue >= 10000000) {
        return '${(amountValue / 10000000).toStringAsFixed(1)}Cr';
      } else if (amountValue >= 100000) {
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
