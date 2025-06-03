import 'package:injectable/injectable.dart';

import '../../../../core/utils/exceptions/api_exception.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart' as model;
import '../../data/models/wallet_model.dart';
import '../entities/transaction.dart' as entity;

abstract class IWalletRepository {
  // Wallet operations
  Future<(ApiException?, WalletModel?)> createWallet({
    String? currency,
    double? initialBalance,
  });
  Future<(ApiException?, List<WalletModel>?)> getWallets();
  Future<(ApiException?, WalletModel?)> getWalletById(String id);
  Future<(ApiException?, WalletModel?)> updateWallet(WalletModel wallet);
  Future<(ApiException?, void)> deleteWallet(String id);

  // Transaction operations
  Future<(ApiException?, model.TransactionModel?)> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });

  Future<(ApiException?, model.TransactionModel?)> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });

  Future<(ApiException?, model.TransactionModel?)> createTransaction({
    required String walletId,
    required double amount,
    required entity.TransactionType type,
    String? description,
    String? toWalletId,
  });
  Future<(ApiException?, List<model.TransactionModel>?)> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  });
  Future<(ApiException?, model.TransactionModel?)> getTransactionById(
    String walletId,
    String id,
  );
  Future<(ApiException?, void)> deleteTransaction(
    String walletId,
    String id,
  );

  // Balance operations
  Future<(ApiException?, double?)> getWalletBalance(String walletId);
  Future<(ApiException?, model.TransactionModel?)> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  });
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
  Future<(ApiException?, WalletModel?)> updateWallet(WalletModel wallet) async {
    try {
      final updatedWallet = await _remoteDataSource.updateWallet(wallet);
      return (null, updatedWallet);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, void)> deleteWallet(String id) async {
    try {
      await _remoteDataSource.deleteWallet(id);
      return (null, null);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, model.TransactionModel?)> createDeposit({
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
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, model.TransactionModel?)> createWithdrawal({
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
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, model.TransactionModel?)> createTransaction({
    required String walletId,
    required double amount,
    required entity.TransactionType type,
    String? description,
    String? toWalletId,
  }) async {
    try {
      switch (type) {
        case entity.TransactionType.income:
          final transaction = await _remoteDataSource.createDeposit(
            walletId: walletId,
            amount: amount,
            description: description,
          );
          return (null, transaction);
        case entity.TransactionType.expense:
          final transaction = await _remoteDataSource.createWithdrawal(
            walletId: walletId,
            amount: amount,
            description: description,
          );
          return (null, transaction);
        case entity.TransactionType.transfer:
          if (toWalletId == null) {
            throw const ApiException(
              message: 'Target wallet is required for transfer',
              statusCode: 400,
              errorType: 'validation_error',
            );
          }
          return await transferBetweenWallets(
            fromWalletId: walletId,
            toWalletId: toWalletId,
            amount: amount,
            description: description,
          );
      }
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, List<model.TransactionModel>?)> getTransactions({
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
  Future<(ApiException?, model.TransactionModel?)> getTransactionById(
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

  @override
  Future<(ApiException?, void)> deleteTransaction(
    String walletId,
    String id,
  ) async {
    try {
      await _remoteDataSource.deleteTransaction(walletId, id);
      return (null, null);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, double?)> getWalletBalance(String walletId) async {
    try {
      final wallet = await _remoteDataSource.getWalletById(walletId);
      return (null, wallet.balance);
    } on ApiException catch (e) {
      return (e, null);
    }
  }

  @override
  Future<(ApiException?, model.TransactionModel?)> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    try {
      final transaction = await _remoteDataSource.createTransfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        description: description,
      );
      return (null, transaction);
    } on ApiException catch (e) {
      return (e, null);
    }
  }
}
