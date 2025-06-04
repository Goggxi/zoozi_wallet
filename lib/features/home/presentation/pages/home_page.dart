import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions/context_extension.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../di/di.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Safe way to add event using context.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WalletBloc>().add(const GetWalletsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WalletError) {
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16), // Added horizontal padding
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<WalletBloc>()
                              .add(const GetWalletsEvent());
                        },
                        child: Text(context.l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is WalletsLoaded) {
              return _buildHomeContent(context, state.wallets);
            }
            return Center(child: Text(context.l10n.welcome));
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, List<WalletModel> wallets) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<WalletBloc>()
            .add(const GetWalletsEvent(forceRefresh: true));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildTotalBalanceCard(context, wallets),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildWalletChart(context, wallets),
            const SizedBox(height: 20),
            _buildWalletsList(context, wallets),
            const SizedBox(height: 20),
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authRepository = getIt<IAuthRepository>();
    final currentUser = authRepository.getCurrentUser();
    final userName =
        currentUser?.name ?? currentUser?.email.split('@').first ?? 'User';
    final l = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,\n $userName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPurple1,
                  ),
            ),
            Text(
              l.walletOverview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                  ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.purple.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.account_balance_wallet,
            color: AppColors.purple,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(
      BuildContext context, List<WalletModel> wallets) {
    // Group wallets by currency and calculate totals
    final Map<String, double> currencyTotals = {};
    for (final wallet in wallets) {
      currencyTotals[wallet.currency] =
          (currencyTotals[wallet.currency] ?? 0) + wallet.balance;
    }
    final l = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple,
            AppColors.darkPurple3,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.totalBalance,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withAlpha(204),
                ),
          ),
          const SizedBox(height: 8),
          if (currencyTotals.isEmpty)
            Text(
              l.noWallets,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            )
          else
            ...currencyTotals.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _formatCurrency(entry.value, entry.key),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                )),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.white.withAlpha(204),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l.lastUpdated(
                    DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withAlpha(179),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.quickActions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkPurple1,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: l.deposit,
                  color: AppColors.purple,
                  onTap: () {
                    context.push('/deposit');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.remove_circle_outline,
                  label: l.withdraw,
                  color: AppColors.pink,
                  onTap: () {
                    context.push('/withdrawal');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: l.transfer,
                  color: AppColors.darkPurple2,
                  onTap: () {
                    // Navigate to transfer page when available
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.transferFeatureSoon)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletChart(BuildContext context, List<WalletModel> wallets) {
    final l = context.l10n;

    if (wallets.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.grey.withAlpha(51),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: AppColors.grey.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              l.noWalletsToDisplay,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.walletDistribution,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkPurple1,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _generatePieChartSections(wallets),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildChartLegend(wallets),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      List<WalletModel> wallets) {
    final totalBalance =
        wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
    final colors = [
      AppColors.purple,
      AppColors.pink,
      AppColors.darkPurple2,
      AppColors.darkPurple3,
    ];

    return wallets.asMap().entries.map((entry) {
      final index = entry.key;
      final wallet = entry.value;
      final percentage =
          totalBalance > 0 ? (wallet.balance / totalBalance) * 100 : 0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: wallet.balance,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildChartLegend(List<WalletModel> wallets) {
    final colors = [
      AppColors.purple,
      AppColors.pink,
      AppColors.darkPurple2,
      AppColors.darkPurple3,
    ];

    return wallets.asMap().entries.map((entry) {
      final index = entry.key;
      final wallet = entry.value;
      final walletDisplayName = '${wallet.currency} Wallet';

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                walletDisplayName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              _formatCurrency(wallet.balance, wallet.currency),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPurple1,
                  ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildWalletsList(BuildContext context, List<WalletModel> wallets) {
    final l = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.myWallets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPurple1,
                  ),
            ),
            TextButton(
              onPressed: () {
                context.go(AppRouter.wallet);
              },
              child: Text(l.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (wallets.isEmpty)
          _buildEmptyWalletsState(context)
        else
          ...wallets.take(3).map((wallet) => _buildWalletCard(context, wallet)),
      ],
    );
  }

  Widget _buildEmptyWalletsState(BuildContext context) {
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16), // Added horizontal padding
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.grey.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            l.noWalletsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.createFirstWallet,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey.withAlpha(179),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to create wallet
            },
            child: Text(l.createWallet),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletModel wallet) {
    // Generate wallet display name since API doesn't provide name field
    final walletDisplayName = '${wallet.currency} Wallet';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purple.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walletDisplayName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'ID: ${wallet.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(wallet.balance, wallet.currency),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPurple1,
                    ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(wallet.updatedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, String currency) {
    final numberFormat = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: currency == 'USD' || currency == 'EUR' ? 2 : 0,
    );
    return numberFormat.format(amount);
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16), // Added horizontal padding
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.recentTransactions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPurple1,
                    ),
              ),
              TextButton(
                onPressed: () {
                  context.go(AppRouter.transactions);
                },
                child: Text(l.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mock recent transactions - in real app, this would come from API
          _buildTransactionItem(
            context,
            title: 'Deposit to Main Wallet',
            amount: 500000,
            date: DateTime.now().subtract(const Duration(hours: 2)),
            isIncome: true,
          ),
          _buildTransactionItem(
            context,
            title: 'Transfer to Savings',
            amount: 200000,
            date: DateTime.now().subtract(const Duration(days: 1)),
            isIncome: false,
          ),
          _buildTransactionItem(
            context,
            title: 'Withdrawal',
            amount: 100000,
            date: DateTime.now().subtract(const Duration(days: 2)),
            isIncome: false,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l.connectApiForTransactions,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required double amount,
    required DateTime date,
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.grey.withAlpha(26),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
          ),
        ],
      ),
    );
  }
}
