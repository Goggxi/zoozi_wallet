import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _getTransactionTitle() {
    switch (transaction.type) {
      case entity.TransactionType.income:
        return 'Deposit';
      case entity.TransactionType.expense:
        return 'Withdrawal';
      case entity.TransactionType.transfer:
        return 'Transfer';
    }
  }

  String _getTransactionSubtitle() {
    final parts = <String>[];

    // Add transaction ID
    if (transaction.id.isNotEmpty) {
      parts.add('ID: #${transaction.id}');
    }

    // Add wallet ID
    if (transaction.fromWalletId.isNotEmpty) {
      parts.add('Wallet: ${transaction.fromWalletId}');
    }

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to transaction detail
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Transaction Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getAmountColor().withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTransactionIcon(),
                    color: _getAmountColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Title
                      Text(
                        _getTransactionTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Transaction ID and Wallet ID
                      Text(
                        _getTransactionSubtitle(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Description if available
                      if (transaction.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(transaction.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_getAmountPrefix()}${Currency.getSymbol(walletCurrency)}${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getAmountColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getAmountColor().withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.typeString.toUpperCase(),
                        style: TextStyle(
                          color: _getAmountColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm').format(date);
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}
