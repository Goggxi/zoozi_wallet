import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/di/di.dart';
import 'package:zoozi_wallet/features/wallet/data/models/wallet_model.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with AutomaticKeepAliveClientMixin {
  late final WalletBloc _walletBloc;
  bool _hasInitiallyLoaded = false;
  List<WalletModel> _cachedWallets = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _walletBloc = getIt<WalletBloc>();

    // Always load wallets when initializing
    _loadWallets();
  }

  void _loadWallets() {
    if (!_hasInitiallyLoaded || _walletBloc.state is! WalletsLoaded) {
      _walletBloc.add(const GetWalletsEvent());
      _hasInitiallyLoaded = true;
    }
  }

  void _refreshWallets() {
    _walletBloc.add(const GetWalletsEvent(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.myWallets),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWallets,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push("${AppRouter.wallet}/${AppRouter.addWallet}");
              // Refresh after adding new wallet
              _refreshWallets();
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        bloc: _walletBloc,
        buildWhen: (previous, current) {
          // Only rebuild for states that are relevant to wallet list
          return current is WalletLoading ||
              current is WalletError ||
              current is WalletsLoaded;
        },
        builder: (context, state) {
          if (state is WalletLoading && _cachedWallets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError && _cachedWallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.failedToLoadWallets,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshWallets,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (state is WalletsLoaded) {
            _cachedWallets = state.wallets;
            final sortedWallets = List.of(state.wallets)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedWallets.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                _walletBloc.add(const GetWalletsEvent(forceRefresh: true));
                // Wait for the state to change from loading
                await for (final state in _walletBloc.stream) {
                  if (state is! WalletLoading) break;
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedWallets.length,
                itemBuilder: (context, index) {
                  final wallet = sortedWallets[index];
                  return _WalletCard(
                    wallet: wallet,
                    onTap: () {
                      // Navigate without awaiting to prevent refresh
                      context.push('${AppRouter.wallet}/${wallet.id}');
                    },
                  );
                },
              ),
            );
          }

          // Show cached data while loading if available
          if (_cachedWallets.isNotEmpty) {
            final sortedWallets = List.of(_cachedWallets)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return RefreshIndicator(
              onRefresh: () async {
                _walletBloc.add(const GetWalletsEvent(forceRefresh: true));
                await for (final state in _walletBloc.stream) {
                  if (state is! WalletLoading) break;
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedWallets.length,
                itemBuilder: (context, index) {
                  final wallet = sortedWallets[index];
                  return _WalletCard(
                    wallet: wallet,
                    onTap: () {
                      context.push('${AppRouter.wallet}/${wallet.id}');
                    },
                  );
                },
              ),
            );
          }

          return Center(child: Text(l.somethingWentWrong));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l.noWalletsFound,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.addWalletToStart,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('${AppRouter.wallet}/${AppRouter.addWallet}');
            },
            icon: const Icon(Icons.add),
            label: Text(l.addWallet),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Don't close the singleton bloc as it's shared across the app
    super.dispose();
  }
}

class _WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;

  const _WalletCard({
    required this.wallet,
    required this.onTap,
  });

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l = context.l10n;

    if (difference.inDays > 0) {
      return l.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l.minutesAgo(difference.inMinutes);
    } else {
      return l.justNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 180,
              maxHeight: 220,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.white,
                      size: 32,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white.withAlpha((0.3 * 255).round()),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        wallet.currency,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'My ${wallet.currency} Wallet',
                  style: TextStyle(
                    color: AppColors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$${wallet.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.walletId(wallet.id ?? 'N/A'),
                            style: TextStyle(
                              color: AppColors.white
                                  .withAlpha((0.7 * 255).round()),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.updated(_formatDate(wallet.updatedAt, context)),
                            style: TextStyle(
                              color: AppColors.white
                                  .withAlpha((0.7 * 255).round()),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
