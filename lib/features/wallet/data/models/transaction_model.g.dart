// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: _stringFromJson(json['id']),
      walletId: _stringFromJson(json['walletId']),
      typeString: _stringFromJson(json['type']),
      amount: _doubleFromJson(json['amount']),
      description: _stringFromJson(json['description']),
      referenceId: json['referenceId'] as String?,
      timestamp: _dateFromJson(json['timestamp']),
      relatedTransactionId: json['relatedTransactionId'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'type': instance.typeString,
      'amount': instance.amount,
      'description': instance.description,
      'referenceId': instance.referenceId,
      'timestamp': instance.timestamp.toIso8601String(),
      'relatedTransactionId': instance.relatedTransactionId,
    };

TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) =>
    TransactionRequest(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$TransactionRequestToJson(TransactionRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'description': instance.description,
      'referenceId': instance.referenceId,
    };

TransactionListResponse _$TransactionListResponseFromJson(
        Map<String, dynamic> json) =>
    TransactionListResponse(
      transactions: _transactionsFromJson(json['transactions']),
      total: _intFromJson(json['total']),
      page: _intFromJson(json['page']),
      limit: _intFromJson(json['limit']),
    );

Map<String, dynamic> _$TransactionListResponseToJson(
        TransactionListResponse instance) =>
    <String, dynamic>{
      'transactions': instance.transactions,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
