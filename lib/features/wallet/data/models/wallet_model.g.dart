// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
      id: _idFromJson(json['id']),
      name: _nameFromJson(json['name']),
      balance: _balanceFromJson(json['balance']),
      currency: _currencyFromJson(json['currency']),
      createdAt: _dateFromJson(json['created_at']),
      updatedAt: _dateFromJson(json['updated_at']),
    );

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'currency': instance.currency,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

CreateWalletRequest _$CreateWalletRequestFromJson(Map<String, dynamic> json) =>
    CreateWalletRequest(
      currency: json['currency'] as String?,
      initialBalance: (json['initialBalance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateWalletRequestToJson(
        CreateWalletRequest instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'initialBalance': instance.initialBalance,
    };
