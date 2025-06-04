import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import '../../../../core/utils/constants/currency.dart';
import '../../../../di/di.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_list_item.dart';

class WalletDetailPage extends StatefulWidget {
  final String walletId;

  const WalletDetailPage({
    super.key,
    required this.walletId,
  });

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late final WalletBloc _walletBloc;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  static const int _itemsPerPage = 20;
  bool _isLoadingMore = false;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _walletBloc = getIt<WalletBloc>();
    _walletBloc.add(GetWalletByIdEvent(widget.walletId));
    _loadTransactions();

    _scrollController.addListener(_onScroll);
  }

  void _loadTransactions() {
    _walletBloc.add(
      GetTransactionsEvent(
        walletId: widget.walletId,
        page: _currentPage,
        limit: _itemsPerPage,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.walletDetails),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show wallet options menu
            },
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is TransactionsLoaded) {
            setState(() {
              if (_currentPage == 1) {
                _transactions = state.transactions;
              } else {
                _transactions.addAll(state.transactions);
              }
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          if (state is WalletLoading && _currentPage == 1) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(child: Text(state.message));
          }

          if (state is WalletLoaded) {
            final wallet = state.wallet;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.darkPurple2,
                        AppColors.purple,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            wallet.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              wallet.currency,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${Currency.getSymbol(wallet.currency)}${wallet.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add,
                          label: l.deposit,
                          onPressed: () {
                            // TODO: Navigate to deposit page
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.remove,
                          label: l.withdraw,
                          onPressed: () {
                            // TODO: Navigate to withdraw page
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.swap_horiz,
                          label: l.transfer,
                          onPressed: () {
                            // TODO: Navigate to transfer page
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        l.recentTransactions,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _transactions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final transaction = _transactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        walletCurrency: wallet.currency,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(child: Text(l.somethingWentWrong));
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
