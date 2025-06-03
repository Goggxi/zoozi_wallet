import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/wallet.dart';

part 'wallet_model.g.dart';

enum Currency { USD, EUR, GBP }

@JsonSerializable()
class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String currency;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
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
      id: id,
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
