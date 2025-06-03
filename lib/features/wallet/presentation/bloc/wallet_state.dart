import 'package:equatable/equatable.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletCreated extends WalletState {
  final WalletModel wallet;

  const WalletCreated(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class WalletsLoaded extends WalletState {
  final List<WalletModel> wallets;

  const WalletsLoaded(this.wallets);

  @override
  List<Object?> get props => [wallets];
}

class WalletLoaded extends WalletState {
  final WalletModel wallet;

  const WalletLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class TransactionCreated extends WalletState {
  final TransactionModel transaction;

  const TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionsLoaded extends WalletState {
  final List<TransactionModel> transactions;

  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionLoaded extends WalletState {
  final TransactionModel transaction;

  const TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
