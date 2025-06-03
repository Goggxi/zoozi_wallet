import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalletEvent extends WalletEvent {
  final String? currency;
  final double? initialBalance;

  const CreateWalletEvent({this.currency, this.initialBalance});

  @override
  List<Object?> get props => [currency, initialBalance];
}

class GetWalletsEvent extends WalletEvent {}

class GetWalletByIdEvent extends WalletEvent {
  final String id;

  const GetWalletByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateDepositEvent extends WalletEvent {
  final String walletId;
  final double amount;
  final String? description;
  final String? referenceId;

  const CreateDepositEvent({
    required this.walletId,
    required this.amount,
    this.description,
    this.referenceId,
  });

  @override
  List<Object?> get props => [walletId, amount, description, referenceId];
}

class CreateWithdrawalEvent extends WalletEvent {
  final String walletId;
  final double amount;
  final String? description;
  final String? referenceId;

  const CreateWithdrawalEvent({
    required this.walletId,
    required this.amount,
    this.description,
    this.referenceId,
  });

  @override
  List<Object?> get props => [walletId, amount, description, referenceId];
}

class GetTransactionsEvent extends WalletEvent {
  final String walletId;
  final int? page;
  final int? limit;

  const GetTransactionsEvent({
    required this.walletId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [walletId, page, limit];
}

class GetTransactionByIdEvent extends WalletEvent {
  final String walletId;
  final String id;

  const GetTransactionByIdEvent({
    required this.walletId,
    required this.id,
  });

  @override
  List<Object?> get props => [walletId, id];
}
