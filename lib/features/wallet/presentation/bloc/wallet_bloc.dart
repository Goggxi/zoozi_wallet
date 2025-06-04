import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/types/api_result.dart';
import '../../../../di/di.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

@singleton
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

    final result = await _walletRepository.createWallet(
      currency: event.currency,
      initialBalance: event.initialBalance,
    );

    result.fold(
      onSuccess: (wallet) => emit(WalletCreated(wallet)),
      onError: (error) => emit(WalletError(error.message)),
    );
  }

  Future<void> _onGetWallets(
    GetWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Check authentication before making API calls
    try {
      final authRepository = getIt<IAuthRepository>();
      if (!authRepository.isAuthenticated ||
          authRepository.getCurrentUser() == null) {
        emit(const WalletError('User not authenticated'));
        return;
      }
    } catch (e) {
      emit(const WalletError('Authentication check failed'));
      return;
    }

    // Only emit loading if we don't have wallets data or if explicitly requested
    if (state is! WalletsLoaded || event.forceRefresh) {
      emit(WalletLoading());
    }

    final result = await _walletRepository.getWallets();

    result.fold(
      onSuccess: (wallets) {
        emit(WalletsLoaded(wallets));
      },
      onError: (error) => emit(WalletError(error.message)),
    );
  }

  Future<void> _onGetWalletById(
    GetWalletByIdEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Don't emit loading if we're already showing wallets list
    // This prevents the loading state from affecting the wallet list page
    if (state is! WalletsLoaded) {
      emit(WalletLoading());
    }

    final result = await _walletRepository.getWalletById(event.id);

    result.fold(
      onSuccess: (wallet) {
        emit(WalletLoaded(wallet));
      },
      onError: (error) {
        emit(WalletError(error.message));
      },
    );
  }

  Future<void> _onCreateDeposit(
    CreateDepositEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await _walletRepository.createDeposit(
      walletId: event.walletId,
      amount: event.amount,
      description: event.description,
      referenceId: event.referenceId,
    );

    result.fold(
      onSuccess: (transaction) => emit(TransactionCreated(transaction)),
      onError: (error) => emit(WalletError(error.message)),
    );
  }

  Future<void> _onCreateWithdrawal(
    CreateWithdrawalEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await _walletRepository.createWithdrawal(
      walletId: event.walletId,
      amount: event.amount,
      description: event.description,
      referenceId: event.referenceId,
    );

    result.fold(
      onSuccess: (transaction) => emit(TransactionCreated(transaction)),
      onError: (error) => emit(WalletError(error.message)),
    );
  }

  Future<void> _onGetTransactions(
    GetTransactionsEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Don't emit loading for transaction requests to prevent affecting wallet list
    // The wallet detail page will handle its own loading state
    final result = await _walletRepository.getTransactions(
      walletId: event.walletId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      onSuccess: (transactions) {
        emit(TransactionsLoaded(transactions));
      },
      onError: (error) {
        emit(WalletError(error.message));
      },
    );
  }

  Future<void> _onGetTransactionById(
    GetTransactionByIdEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await _walletRepository.getTransactionById(
      event.walletId,
      event.id,
    );

    result.fold(
      onSuccess: (transaction) => emit(TransactionLoaded(transaction)),
      onError: (error) => emit(WalletError(error.message)),
    );
  }
}
