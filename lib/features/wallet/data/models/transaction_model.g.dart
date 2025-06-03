// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      typeString: json['type'] as String,
      fromWalletId: json['from_wallet_id'] as String,
      toWalletId: json['to_wallet_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionListResponseToJson(
        TransactionListResponse instance) =>
    <String, dynamic>{
      'transactions': instance.transactions,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
