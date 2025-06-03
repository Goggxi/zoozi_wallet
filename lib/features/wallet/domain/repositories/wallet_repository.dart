import 'package:injectable/injectable.dart';

import '../../../../core/utils/exceptions/api_exception.dart';
import '../../../../core/utils/types/api_result.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart' as model;
import '../../data/models/wallet_model.dart';
import '../entities/transaction.dart' as entity;

abstract class IWalletRepository {
  // Wallet operations
  Future<ApiResult<WalletModel>> createWallet({
    String? currency,
    double? initialBalance,
  });
  Future<ApiResult<List<WalletModel>>> getWallets();
  Future<ApiResult<WalletModel>> getWalletById(String id);
  Future<ApiResult<WalletModel>> updateWallet(WalletModel wallet);
  Future<ApiResult<void>> deleteWallet(String id);

  // Transaction operations
  Future<ApiResult<model.TransactionModel>> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });

  Future<ApiResult<model.TransactionModel>> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });

  Future<ApiResult<model.TransactionModel>> createTransaction({
    required String walletId,
    required double amount,
    required entity.TransactionType type,
    String? description,
    String? toWalletId,
  });
  Future<ApiResult<List<model.TransactionModel>>> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  });
  Future<ApiResult<model.TransactionModel>> getTransactionById(
    String walletId,
    String id,
  );
  Future<ApiResult<void>> deleteTransaction(
    String walletId,
    String id,
  );

  // Balance operations
  Future<ApiResult<double>> getWalletBalance(String walletId);
  Future<ApiResult<model.TransactionModel>> transferBetweenWallets({
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
  Future<ApiResult<WalletModel>> createWallet({
    String? currency,
    double? initialBalance,
  }) async {
    try {
      final wallet = await _remoteDataSource.createWallet(
        currency: currency,
        initialBalance: initialBalance,
      );
      return Success(wallet);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<List<WalletModel>>> getWallets() async {
    try {
      final wallets = await _remoteDataSource.getWallets();
      return Success(wallets);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<WalletModel>> getWalletById(String id) async {
    try {
      final wallet = await _remoteDataSource.getWalletById(id);
      return Success(wallet);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<WalletModel>> updateWallet(WalletModel wallet) async {
    try {
      final updatedWallet = await _remoteDataSource.updateWallet(wallet);
      return Success(updatedWallet);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<void>> deleteWallet(String id) async {
    try {
      await _remoteDataSource.deleteWallet(id);
      return Success(null);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<model.TransactionModel>> createDeposit({
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
      return Success(transaction);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<model.TransactionModel>> createWithdrawal({
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
      return Success(transaction);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<model.TransactionModel>> createTransaction({
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
          return Success(transaction);
        case entity.TransactionType.expense:
          final transaction = await _remoteDataSource.createWithdrawal(
            walletId: walletId,
            amount: amount,
            description: description,
          );
          return Success(transaction);
        case entity.TransactionType.transfer:
          if (toWalletId == null) {
            return Error(const ApiException(
              message: 'Target wallet is required for transfer',
              statusCode: 400,
              errorType: 'validation_error',
            ));
          }
          return transferBetweenWallets(
            fromWalletId: walletId,
            toWalletId: toWalletId,
            amount: amount,
            description: description,
          );
      }
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<List<model.TransactionModel>>> getTransactions({
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
      return Success(response.transactions);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<model.TransactionModel>> getTransactionById(
    String walletId,
    String id,
  ) async {
    try {
      final transaction = await _remoteDataSource.getTransactionById(
        walletId,
        id,
      );
      return Success(transaction);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<void>> deleteTransaction(
    String walletId,
    String id,
  ) async {
    try {
      await _remoteDataSource.deleteTransaction(walletId, id);
      return Success(null);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<double>> getWalletBalance(String walletId) async {
    try {
      final wallet = await _remoteDataSource.getWalletById(walletId);
      return Success(wallet.balance);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  Future<ApiResult<model.TransactionModel>> transferBetweenWallets({
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
      return Success(transaction);
    } on ApiException catch (e) {
      return Error(e);
    }
  }
}
