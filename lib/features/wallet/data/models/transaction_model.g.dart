// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: _stringFromJson(json['id']),
      title: _stringFromJson(json['title']),
      description: _stringFromJson(json['description']),
      amount: _doubleFromJson(json['amount']),
      typeString: _stringFromJson(json['type']),
      fromWalletId: _stringFromJson(json['from_wallet_id']),
      toWalletId: json['to_wallet_id'] as String?,
      createdAt: _dateFromJson(json['created_at']),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'type': instance.typeString,
      'from_wallet_id': instance.fromWalletId,
      'to_wallet_id': instance.toWalletId,
      'created_at': instance.createdAt.toIso8601String(),
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
