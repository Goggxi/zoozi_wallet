import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

enum Currency { USD, EUR, GBP }

@JsonSerializable()
class WalletModel extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final String currency;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        currency,
        createdAt,
        updatedAt,
      ];
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
