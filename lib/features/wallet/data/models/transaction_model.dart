import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction.dart' as entity;

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('DEPOSIT')
  deposit,
  @JsonValue('WITHDRAWAL')
  withdrawal,
}

@JsonSerializable()
class TransactionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  @JsonKey(name: 'type')
  final String typeString;
  @JsonKey(name: 'from_wallet_id')
  final String fromWalletId;
  @JsonKey(name: 'to_wallet_id')
  final String? toWalletId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.typeString,
    required this.fromWalletId,
    this.toWalletId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        typeString,
        fromWalletId,
        toWalletId,
        createdAt,
      ];

  entity.TransactionType get type {
    switch (typeString.toLowerCase()) {
      case 'income':
        return entity.TransactionType.income;
      case 'expense':
        return entity.TransactionType.expense;
      case 'transfer':
        return entity.TransactionType.transfer;
      default:
        throw ArgumentError('Invalid transaction type: $typeString');
    }
  }

  entity.Transaction toEntity() {
    return entity.Transaction(
      id: id,
      title: title,
      description: description,
      amount: amount,
      type: type,
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      createdAt: createdAt,
    );
  }

  factory TransactionModel.fromEntity(entity.Transaction transaction) {
    String getTypeString(entity.TransactionType type) {
      switch (type) {
        case entity.TransactionType.income:
          return 'income';
        case entity.TransactionType.expense:
          return 'expense';
        case entity.TransactionType.transfer:
          return 'transfer';
      }
    }

    return TransactionModel(
      id: transaction.id,
      title: transaction.title,
      description: transaction.description,
      amount: transaction.amount,
      typeString: getTypeString(transaction.type),
      fromWalletId: transaction.fromWalletId,
      toWalletId: transaction.toWalletId,
      createdAt: transaction.createdAt,
    );
  }
}

@JsonSerializable()
class TransactionRequest extends Equatable {
  final double amount;
  final String? description;
  final String? referenceId;

  const TransactionRequest({
    required this.amount,
    this.description,
    this.referenceId,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);

  @override
  List<Object?> get props => [amount, description, referenceId];
}

@JsonSerializable()
class TransactionListResponse extends Equatable {
  final List<TransactionModel> transactions;
  final int total;
  final int page;
  final int limit;

  const TransactionListResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionListResponseToJson(this);

  @override
  List<Object?> get props => [transactions, total, page, limit];
}
