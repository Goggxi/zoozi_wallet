import 'package:injectable/injectable.dart';

import '../../../../core/utils/exceptions/api_exception.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';

abstract class IWalletRepository {
  Future<(ApiException?, WalletModel?)> createWallet({
    String? currency,
    double? initialBalance,
  });
  Future<(ApiException?, List<WalletModel>?)> getWallets();
  Future<(ApiException?, WalletModel?)> getWalletById(String id);
  Future<(ApiException?, TransactionModel?)> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });
  Future<(ApiException?, TransactionModel?)> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });
  Future<(ApiException?, List<TransactionModel>?)> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  });
  Future<(ApiException?, TransactionModel?)> getTransactionById(
    String walletId,
    String id,
  );
}

@Injectable(as: IWalletRepository)
class WalletRepository implements IWalletRepository {
  final IWalletRemoteDataSource _remoteDataSource;

  WalletRepository(this._remoteDataSource);

  @override
  Future<(ApiException?, WalletModel?)> createWallet({
    String? currency,
    double? initialBalance,
  }) async {
    try {
      final wallet = await _remoteDataSource.createWallet(
        currency: currency,
        initialBalance: initialBalance,
      );
      return (null, wallet);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, List<WalletModel>?)> getWallets() async {
    try {
      final wallets = await _remoteDataSource.getWallets();
      return (null, wallets);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, WalletModel?)> getWalletById(String id) async {
    try {
      final wallet = await _remoteDataSource.getWalletById(id);
      return (null, wallet);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, TransactionModel?)> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  }) async {
    try {
      final transaction = await _remoteDataSource.createDeposit(
        walletId: walletId,
        amount: amount,
        description: description,
        referenceId: referenceId,
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, TransactionModel?)> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  }) async {
    try {
      final transaction = await _remoteDataSource.createWithdrawal(
        walletId: walletId,
        amount: amount,
        description: description,
        referenceId: referenceId,
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, List<TransactionModel>?)> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.getTransactions(
        walletId: walletId,
        page: page,
        limit: limit,
      );
      return (null, response.transactions);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, TransactionModel?)> getTransactionById(
    String walletId,
    String id,
  ) async {
    try {
      final transaction = await _remoteDataSource.getTransactionById(
        walletId,
        id,
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }
}
