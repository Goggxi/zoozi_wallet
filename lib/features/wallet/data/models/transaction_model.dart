import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('DEPOSIT')
  deposit,
  @JsonValue('WITHDRAWAL')
  withdrawal,
}

@JsonSerializable()
class TransactionModel extends Equatable {
  final int id;
  final int walletId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String? referenceId;
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  final int? relatedTransactionId;

  const TransactionModel({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.description,
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
        type,
        amount,
        description,
        referenceId,
        timestamp,
        relatedTransactionId,
      ];
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
