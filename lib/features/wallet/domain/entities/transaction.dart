import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String fromWalletId;
  final String? toWalletId; // Null for income/expense
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.fromWalletId,
    this.toWalletId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        type,
        fromWalletId,
        toWalletId,
        createdAt,
      ];
}
