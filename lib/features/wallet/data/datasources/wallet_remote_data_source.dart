import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/utils/network/http_client.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

abstract class IWalletRemoteDataSource {
  Future<WalletModel> createWallet({
    String? currency,
    double? initialBalance,
  });
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> getWalletById(String id);
  Future<WalletModel> updateWallet(WalletModel wallet);
  Future<void> deleteWallet(String id);

  Future<TransactionModel> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });
  Future<TransactionModel> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  });
  Future<TransactionModel> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  });
  Future<TransactionListResponse> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  });
  Future<TransactionModel> getTransactionById(String walletId, String id);
  Future<void> deleteTransaction(String walletId, String id);
}

@Injectable(as: IWalletRemoteDataSource)
class WalletRemoteDataSource implements IWalletRemoteDataSource {
  final HttpClient _client;
  final String baseUrl;

  WalletRemoteDataSource(this._client, IAuthLocalDataSource authLocalDataSource)
      : baseUrl = const String.fromEnvironment('BASE_URL');

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
      };

  @override
  Future<WalletModel> createWallet({
    String? currency,
    double? initialBalance,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/wallets',
      headers: _defaultHeaders,
      body: {
        if (currency != null) 'currency': currency,
        if (initialBalance != null) 'initialBalance': initialBalance,
      },
    );

    return WalletModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets',
      headers: _defaultHeaders,
    );

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => WalletModel.fromJson(json)).toList();
  }

  @override
  Future<WalletModel> getWalletById(String id) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets/$id',
      headers: _defaultHeaders,
    );

    return WalletModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<WalletModel> updateWallet(WalletModel wallet) {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWallet(String id) {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<TransactionModel> createDeposit({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/wallets/$walletId/transactions/deposit',
      headers: _defaultHeaders,
      body: {
        'amount': amount,
        if (description != null) 'description': description,
        if (referenceId != null) 'referenceId': referenceId,
      },
    );

    return TransactionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<TransactionModel> createWithdrawal({
    required String walletId,
    required double amount,
    String? description,
    String? referenceId,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/wallets/$walletId/transactions/withdrawal',
      headers: _defaultHeaders,
      body: {
        'amount': amount,
        if (description != null) 'description': description,
        if (referenceId != null) 'referenceId': referenceId,
      },
    );

    return TransactionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<TransactionModel> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<TransactionListResponse> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _client.apiRequest(
        url: baseUrl,
        method: RequestMethod.get,
        apiPath: '/wallets/$walletId/transactions',
        headers: _defaultHeaders,
        queryParameters: {
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      final responseBody = response.body;
      if (responseBody.isEmpty) {
        // Return empty response if API returns empty body
        return const TransactionListResponse(
          transactions: [],
          total: 0,
          page: 1,
          limit: 20,
        );
      }

      final jsonData = jsonDecode(responseBody);

      // Handle case where API returns array directly instead of object
      if (jsonData is List) {
        // Parse each transaction safely
        final transactions = <TransactionModel>[];
        for (final item in jsonData) {
          try {
            if (item is Map<String, dynamic>) {
              transactions.add(TransactionModel.fromJson(item));
            }
          } catch (e) {
            print('Error parsing individual transaction: $e');
            // Skip invalid transactions instead of crashing
          }
        }

        return TransactionListResponse(
          transactions: transactions,
          total: transactions.length,
          page: page ?? 1,
          limit: limit ?? 20,
        );
      }

      // Handle normal object response
      if (jsonData is Map<String, dynamic>) {
        return TransactionListResponse.fromJson(jsonData);
      }

      // Fallback for unexpected response format
      return TransactionListResponse(
        transactions: const [],
        total: 0,
        page: page ?? 1,
        limit: limit ?? 20,
      );
    } catch (e) {
      // If parsing fails, return empty response instead of crashing
      print('Error parsing transactions: $e');
      return TransactionListResponse(
        transactions: const [],
        total: 0,
        page: page ?? 1,
        limit: limit ?? 20,
      );
    }
  }

  @override
  Future<TransactionModel> getTransactionById(
    String walletId,
    String id,
  ) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets/$walletId/transactions/$id',
      headers: _defaultHeaders,
    );

    return TransactionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> deleteTransaction(String walletId, String id) {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
