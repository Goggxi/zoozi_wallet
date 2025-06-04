import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/wallet.dart';

part 'wallet_model.g.dart';

enum Currency { USD, EUR, GBP }

String? _idFromJson(dynamic id) => id?.toString();
String _nameFromJson(dynamic name) => name?.toString() ?? 'Unnamed Wallet';
double _balanceFromJson(dynamic balance) =>
    (balance as num?)?.toDouble() ?? 0.0;
String _currencyFromJson(dynamic currency) => currency?.toString() ?? 'USD';
DateTime _dateFromJson(dynamic date) =>
    date != null ? DateTime.parse(date.toString()) : DateTime.now();

@JsonSerializable()
class WalletModel {
  @JsonKey(fromJson: _idFromJson)
  final String? id;
  @JsonKey(fromJson: _nameFromJson)
  final String name;
  @JsonKey(fromJson: _balanceFromJson)
  final double balance;
  @JsonKey(fromJson: _currencyFromJson)
  final String currency;
  @JsonKey(name: 'created_at', fromJson: _dateFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateFromJson)
  final DateTime updatedAt;

  const WalletModel({
    this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  Wallet toEntity() {
    return Wallet(
      id: id ?? '',
      name: name,
      balance: balance,
      currency: currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      id: wallet.id,
      name: wallet.name,
      balance: wallet.balance,
      currency: wallet.currency,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
  }
}

@JsonSerializable()
class CreateWalletRequest extends Equatable {
  final String? currency;
  final double? initialBalance;

  const CreateWalletRequest({
    this.currency,
    this.initialBalance,
  });

  factory CreateWalletRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWalletRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWalletRequestToJson(this);

  @override
  List<Object?> get props => [currency, initialBalance];
}
