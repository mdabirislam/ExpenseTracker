import 'package:flutter/material.dart';
import '../../models/transaction_type.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onSelected;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<TransactionType> typesOrder = [
      TransactionType.income,
      TransactionType.debtBorrow,
      TransactionType.creditBuy,
      TransactionType.savingsAdd,
      TransactionType.lendGive,
      TransactionType.expense,
      TransactionType.debtRepay,
      TransactionType.creditPay,
      TransactionType.savingsWithdraw,
      TransactionType.lendReceive,
    ];

    final Map<TransactionType, String> shortLabels = {
      TransactionType.income: 'Income Money',
      TransactionType.expense: 'Expense Money',
      TransactionType.debtBorrow: 'Debt To Pay',
      TransactionType.debtRepay: 'Repaid Debt',
      TransactionType.creditBuy: 'Credit Buy',
      TransactionType.creditPay: 'Credit Paid',
      TransactionType.savingsAdd: 'Savings',
      TransactionType.savingsWithdraw: 'Withdraw Savings',
      TransactionType.lendGive: 'Lend Money',
      TransactionType.lendReceive: 'Repaid Lend',
    };

    final screenWidth = MediaQuery.of(context).size.width;
    final chipWidth = (screenWidth - 32 - 4 * 8) / 5;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: typesOrder.map((type) {
        final isSelected = selectedType == type;
        return SizedBox(
          width: chipWidth,
          child: ChoiceChip(
            label: Text(
              shortLabels[type]!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(type),
          ),
        );
      }).toList(),
    );
  }
}