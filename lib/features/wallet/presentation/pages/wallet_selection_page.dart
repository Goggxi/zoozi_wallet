import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/features/wallet/data/models/wallet_model.dart'
    hide Currency;

import '../../../../core/utils/constants/currency.dart';
import '../../../../di/di.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

enum WalletAction { deposit, withdrawal, transfer }

class WalletSelectionPage extends StatefulWidget {
  final WalletAction action;

  const WalletSelectionPage({
    super.key,
    required this.action,
  });

  @override
  State<WalletSelectionPage> createState() => _WalletSelectionPageState();
}

class _WalletSelectionPageState extends State<WalletSelectionPage>
    with TickerProviderStateMixin {
  late final WalletBloc _walletBloc;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _walletBloc = WalletBloc(getIt());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _walletBloc.add(const GetWalletsEvent());
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        title: Text(_getPageTitle(l)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          // Handle any necessary state changes
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return _buildErrorState(state.message, l, theme);
          }

          if (state is WalletsLoaded) {
            if (state.wallets.isEmpty) {
              return _buildEmptyState(l, theme);
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(l, theme),
                  Expanded(
                    child: _buildWalletList(state.wallets, l, theme),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getPageTitle(dynamic l) {
    switch (widget.action) {
      case WalletAction.deposit:
        return l.depositMoney;
      case WalletAction.withdrawal:
        return l.withdrawMoney;
      case WalletAction.transfer:
        return l.transfer;
    }
  }

  Widget _buildHeader(dynamic l, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Wallet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitle(l),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(dynamic l) {
    switch (widget.action) {
      case WalletAction.deposit:
        return 'Choose a wallet to add money to';
      case WalletAction.withdrawal:
        return 'Choose a wallet to withdraw money from';
      case WalletAction.transfer:
        return 'Choose a wallet to transfer from';
    }
  }

  Widget _buildWalletList(
      List<WalletModel> wallets, dynamic l, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return _buildWalletCard(wallet, l, theme);
      },
    );
  }

  Widget _buildWalletCard(WalletModel wallet, dynamic l, ThemeData theme) {
    final canWithdraw =
        widget.action != WalletAction.withdrawal || wallet.balance > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: canWithdraw ? () => _onWalletSelected(wallet) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: canWithdraw
                  ? _getWalletGradient(widget.action)
                  : LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My ${wallet.currency} Wallet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        wallet.currency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${Currency.getSymbol(wallet.currency)}${wallet.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.action == WalletAction.withdrawal &&
                    wallet.balance <= 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.insufficientBalance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getWalletGradient(WalletAction action) {
    switch (action) {
      case WalletAction.deposit:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green, Colors.teal],
        );
      case WalletAction.withdrawal:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red, Colors.redAccent],
        );
      case WalletAction.transfer:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.darkPurple2],
        );
    }
  }

  void _onWalletSelected(WalletModel wallet) {
    switch (widget.action) {
      case WalletAction.deposit:
        context.push('/deposit?walletId=${wallet.id}');
        break;
      case WalletAction.withdrawal:
        context.push('/withdrawal?walletId=${wallet.id}');
        break;
      case WalletAction.transfer:
        // TODO: Implement transfer page
        break;
    }
  }

  Widget _buildEmptyState(dynamic l, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              l.noWalletsFound,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.addWalletToStart,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/wallet/add'),
              icon: const Icon(Icons.add),
              label: Text(l.addWallet),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
      ),
    );
  }

  Widget _buildErrorState(String message, dynamic l, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              l.oopsSomethingWentWrong,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _walletBloc.add(const GetWalletsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
