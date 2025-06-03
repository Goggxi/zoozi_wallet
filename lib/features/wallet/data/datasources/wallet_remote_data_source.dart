import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/utils/network/http_client.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

abstract class IWalletRemoteDataSource {
  Future<WalletModel> createWallet({String? currency, double? initialBalance});
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> getWalletById(String id);
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
  Future<TransactionListResponse> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  });
  Future<TransactionModel> getTransactionById(String walletId, String id);
}

@Injectable(as: IWalletRemoteDataSource)
class WalletRemoteDataSource implements IWalletRemoteDataSource {
  final HttpClient _client;
  final String baseUrl;

  WalletRemoteDataSource(this._client)
      : baseUrl = const String.fromEnvironment('BASE_URL');

  @override
  Future<WalletModel> createWallet({
    String? currency,
    double? initialBalance,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/wallets',
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
    );

    return WalletModel.fromJson(jsonDecode(response.body));
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
      body: {
        'amount': amount,
        if (description != null) 'description': description,
        if (referenceId != null) 'referenceId': referenceId,
      },
    );

    return TransactionModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<TransactionListResponse> getTransactions({
    required String walletId,
    int? page,
    int? limit,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets/$walletId/transactions',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return TransactionListResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Future<TransactionModel> getTransactionById(
      String walletId, String id) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets/$walletId/transactions/$id',
    );

    return TransactionModel.fromJson(jsonDecode(response.body));
  }
}
