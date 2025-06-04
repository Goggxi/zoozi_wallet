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

// Safe JSON parsing helper functions
String _stringFromJson(dynamic value) => value?.toString() ?? '';
double _doubleFromJson(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
DateTime _dateFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (e) {
    return DateTime.now();
  }
}

@JsonSerializable()
class TransactionModel extends Equatable {
  @JsonKey(fromJson: _stringFromJson)
  final String id;
  @JsonKey(name: 'walletId', fromJson: _stringFromJson)
  final String walletId;
  @JsonKey(name: 'type', fromJson: _stringFromJson)
  final String typeString;
  @JsonKey(fromJson: _doubleFromJson)
  final double amount;
  @JsonKey(fromJson: _stringFromJson)
  final String description;
  @JsonKey(name: 'referenceId')
  final String? referenceId;
  @JsonKey(name: 'timestamp', fromJson: _dateFromJson)
  final DateTime timestamp;
  @JsonKey(name: 'relatedTransactionId')
  final String? relatedTransactionId;

  const TransactionModel({
    required this.id,
    required this.walletId,
    required this.typeString,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.timestamp,
    this.relatedTransactionId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        walletId,
        typeString,
        amount,
        description,
        referenceId,
        timestamp,
        relatedTransactionId,
      ];

  // Computed properties for UI
  String get title {
    switch (type) {
      case entity.TransactionType.income:
        return 'Deposit';
      case entity.TransactionType.expense:
        return 'Withdrawal';
      case entity.TransactionType.transfer:
        return 'Transfer';
    }
  }

  DateTime get createdAt => timestamp;
  String get fromWalletId => walletId;

  entity.TransactionType get type {
    switch (typeString.toUpperCase()) {
      case 'DEPOSIT':
        return entity.TransactionType.income;
      case 'WITHDRAWAL':
        return entity.TransactionType.expense;
      case 'TRANSFER':
        return entity.TransactionType.transfer;
      default:
        return entity.TransactionType.income; // Default fallback
    }
  }

  entity.Transaction toEntity() {
    return entity.Transaction(
      id: id,
      title: title,
      description: description,
      amount: amount,
      type: type,
      fromWalletId: walletId,
      toWalletId: relatedTransactionId,
      createdAt: timestamp,
    );
  }

  factory TransactionModel.fromEntity(entity.Transaction transaction) {
    String getTypeString(entity.TransactionType type) {
      switch (type) {
        case entity.TransactionType.income:
          return 'DEPOSIT';
        case entity.TransactionType.expense:
          return 'WITHDRAWAL';
        case entity.TransactionType.transfer:
          return 'TRANSFER';
      }
    }

    return TransactionModel(
      id: transaction.id,
      walletId: transaction.fromWalletId,
      typeString: getTypeString(transaction.type),
      amount: transaction.amount,
      description: transaction.description,
      referenceId: transaction.toWalletId,
      timestamp: transaction.createdAt,
      relatedTransactionId: transaction.toWalletId,
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

// Safe parsing helper functions for list response
List<TransactionModel> _transactionsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is! List) return [];

  return value
      .where((item) => item != null)
      .map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return TransactionModel.fromJson(item);
          }
          return null;
        } catch (e) {
          // Log error but don't crash
          print('Error parsing transaction: $e');
          return null;
        }
      })
      .where((item) => item != null)
      .cast<TransactionModel>()
      .toList();
}

int _intFromJson(dynamic value) => (value as num?)?.toInt() ?? 0;

@JsonSerializable()
class TransactionListResponse extends Equatable {
  @JsonKey(fromJson: _transactionsFromJson)
  final List<TransactionModel> transactions;
  @JsonKey(fromJson: _intFromJson)
  final int total;
  @JsonKey(fromJson: _intFromJson)
  final int page;
  @JsonKey(fromJson: _intFromJson)
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
