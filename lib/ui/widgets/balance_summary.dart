import 'package:flutter/material.dart';

class BalanceSummary extends StatelessWidget {
  final String balance;
  final String statusText;
  final Color statusColor;

  const BalanceSummary({
    super.key,
    required this.balance,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            balance.toString(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(color: statusColor),
          ),
        ],
      ),
    );
  }
}
