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
  @JsonKey(fromJson: _stringFromJson)
  final String title;
  @JsonKey(fromJson: _stringFromJson)
  final String description;
  @JsonKey(fromJson: _doubleFromJson)
  final double amount;
  @JsonKey(name: 'type', fromJson: _stringFromJson)
  final String typeString;
  @JsonKey(name: 'from_wallet_id', fromJson: _stringFromJson)
  final String fromWalletId;
  @JsonKey(name: 'to_wallet_id')
  final String? toWalletId;
  @JsonKey(name: 'created_at', fromJson: _dateFromJson)
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
      case 'deposit':
        return entity.TransactionType.income;
      case 'expense':
      case 'withdrawal':
        return entity.TransactionType.expense;
      case 'transfer':
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
