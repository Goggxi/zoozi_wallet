import 'package:flutter/material.dart';
import '../../../../core/utils/constants/currency.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction.dart' as entity;

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final String walletCurrency;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.walletCurrency,
  });

  Color _getAmountColor() {
    switch (transaction.type) {
      case entity.TransactionType.income:
        return Colors.green;
      case entity.TransactionType.expense:
        return Colors.red;
      case entity.TransactionType.transfer:
        return Colors.blue;
    }
  }

  String _getAmountPrefix() {
    switch (transaction.type) {
      case entity.TransactionType.income:
        return '+';
      case entity.TransactionType.expense:
        return '-';
      case entity.TransactionType.transfer:
        return '';
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case entity.TransactionType.income:
        return Icons.add_circle_outline;
      case entity.TransactionType.expense:
        return Icons.remove_circle_outline;
      case entity.TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: _getAmountColor().withValues(alpha: 0.1),
          child: Icon(
            _getTransactionIcon(),
            color: _getAmountColor(),
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                transaction.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(transaction.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        trailing: Text(
          '${_getAmountPrefix()}${Currency.getSymbol(walletCurrency)}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: _getAmountColor(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
