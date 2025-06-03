import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';

// Events
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

// States
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

// Bloc
@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final IWalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletInitial()) {
    on<CreateWalletEvent>(_onCreateWallet);
    on<GetWalletsEvent>(_onGetWallets);
    on<GetWalletByIdEvent>(_onGetWalletById);
    on<CreateDepositEvent>(_onCreateDeposit);
    on<CreateWithdrawalEvent>(_onCreateWithdrawal);
    on<GetTransactionsEvent>(_onGetTransactions);
    on<GetTransactionByIdEvent>(_onGetTransactionById);
  }

  Future<void> _onCreateWallet(
    CreateWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, wallet) = await _walletRepository.createWallet(
      currency: event.currency,
      initialBalance: event.initialBalance,
    );

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(WalletCreated(wallet!));
    }
  }

  Future<void> _onGetWallets(
    GetWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, wallets) = await _walletRepository.getWallets();

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(WalletsLoaded(wallets!));
    }
  }

  Future<void> _onGetWalletById(
    GetWalletByIdEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, wallet) = await _walletRepository.getWalletById(event.id);

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(WalletLoaded(wallet!));
    }
  }

  Future<void> _onCreateDeposit(
    CreateDepositEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, transaction) = await _walletRepository.createDeposit(
      walletId: event.walletId,
      amount: event.amount,
      description: event.description,
      referenceId: event.referenceId,
    );

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(TransactionCreated(transaction!));
    }
  }

  Future<void> _onCreateWithdrawal(
    CreateWithdrawalEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, transaction) = await _walletRepository.createWithdrawal(
      walletId: event.walletId,
      amount: event.amount,
      description: event.description,
      referenceId: event.referenceId,
    );

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(TransactionCreated(transaction!));
    }
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, transactions) = await _walletRepository.getTransactions(
      walletId: event.walletId,
      page: event.page,
      limit: event.limit,
    );

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(TransactionsLoaded(transactions!));
    }
  }

  Future<void> _onGetTransactionById(
    GetTransactionByIdEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final (error, transaction) = await _walletRepository.getTransactionById(
      event.walletId,
      event.id,
    );

    if (error != null) {
      emit(WalletError(error.message));
    } else {
      emit(TransactionLoaded(transaction!));
    }
  }
}
