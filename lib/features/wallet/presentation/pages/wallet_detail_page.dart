import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/features/wallet/data/models/wallet_model.dart'
    show WalletModel;
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

class _WalletDetailPageState extends State<WalletDetailPage>
    with TickerProviderStateMixin {
  late final WalletBloc _walletBloc;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int _currentPage = 1;
  static const int _itemsPerPage = 20;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  bool _isLoadingTransactions = false;
  bool _isRefreshing = false;
  List<TransactionModel> _transactions = [];
  WalletModel? _currentWallet;

  @override
  void initState() {
    super.initState();
    _walletBloc = WalletBloc(getIt());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _walletBloc.add(GetWalletByIdEvent(widget.walletId));
    _loadTransactions();
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  void _loadTransactions() {
    if (_hasReachedMax) return;

    setState(() {
      if (_currentPage == 1) {
        _isLoadingTransactions = true;
      } else {
        _isLoadingMore = true;
      }
    });

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
        !_isLoadingMore &&
        !_hasReachedMax) {
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
        title: Text(l.walletDetails),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (_isRefreshing)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _refreshData();
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showWalletOptions(context, l);
            },
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is WalletLoaded) {
            setState(() {
              _currentWallet = state.wallet;
            });
          } else if (state is TransactionsLoaded) {
            setState(() {
              // Always reset loading states first
              _isLoadingTransactions = false;
              _isLoadingMore = false;
              _isRefreshing = false;

              if (_currentPage == 1) {
                _transactions = state.transactions;
              } else {
                _transactions.addAll(state.transactions);
              }

              // Set hasReachedMax based on returned data length
              if (state.transactions.length < _itemsPerPage) {
                _hasReachedMax = true;
              }
            });
          } else if (state is WalletError) {
            setState(() {
              _isLoadingTransactions = false;
              _isLoadingMore = false;
              _isRefreshing = false;
            });
          }
        },
        builder: (context, state) {
          if (state is WalletLoading && _currentWallet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError && _currentWallet == null) {
            return _buildErrorState(state.message, l);
          }

          final wallet = _currentWallet;
          if (wallet == null) {
            return Center(child: Text(l.somethingWentWrong));
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _isRefreshing = true;
                  });
                  _refreshData();

                  // Wait for refresh to complete
                  while (_isRefreshing) {
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildWalletHeader(wallet, l),
                    ),
                    SliverToBoxAdapter(
                      child: _buildQuickStats(wallet, l),
                    ),
                    SliverToBoxAdapter(
                      child: _buildActionButtons(l),
                    ),
                    SliverToBoxAdapter(
                      child: _buildTransactionHeader(context, l),
                    ),
                    _buildTransactionsList(l),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _refreshData() {
    setState(() {
      _currentPage = 1;
      _hasReachedMax = false;
      _transactions.clear();
      _isLoadingTransactions = false;
      _isLoadingMore = false;
    });
    _walletBloc.add(GetWalletByIdEvent(widget.walletId));
    _loadTransactions();
  }

  Widget _buildWalletHeader(WalletModel wallet, dynamic l) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkPurple2,
            AppColors.purple,
            AppColors.darkPurple3,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withAlpha((0.3 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My ${wallet.currency} Wallet',
                      style: TextStyle(
                        color: AppColors.white.withAlpha((0.8 * 255).round()),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.currentBalance,
                      style: TextStyle(
                        color: AppColors.white.withAlpha((0.9 * 255).round()),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withAlpha((0.3 * 255).round()),
                    width: 1,
                  ),
                ),
                child: Text(
                  wallet.currency,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${Currency.getSymbol(wallet.currency)}${wallet.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.white.withAlpha((0.7 * 255).round()),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                l.walletId(wallet.id ?? 'N/A'),
                style: TextStyle(
                  color: AppColors.white.withAlpha((0.7 * 255).round()),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                color: AppColors.white.withAlpha((0.7 * 255).round()),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l.updated(_formatLastUpdate(wallet.updatedAt)),
                style: TextStyle(
                  color: AppColors.white.withAlpha((0.7 * 255).round()),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
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

  Widget _buildQuickStats(WalletModel wallet, dynamic l) {
    // Calculate stats from transactions
    double totalIncome = 0;
    double totalExpense = 0;
    int transactionCount = _transactions.length;

    for (var transaction in _transactions) {
      if (transaction.typeString.toLowerCase() == 'deposit' ||
          transaction.typeString.toLowerCase() == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.typeString.toLowerCase() == 'withdrawal' ||
          transaction.typeString.toLowerCase() == 'expense') {
        totalExpense += transaction.amount;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              l.totalIncome,
              '+${Currency.getSymbol(wallet.currency)}${totalIncome.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l.totalExpense,
              '-${Currency.getSymbol(wallet.currency)}${totalExpense.toStringAsFixed(2)}',
              Icons.trending_down,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l.transactions,
              transactionCount.toString(),
              Icons.receipt_long,
              AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.3 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic l) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _EnhancedActionButton(
              icon: Icons.add_circle_outline,
              label: l.deposit,
              color: Colors.green,
              onPressed: () {
                context.go('/deposit?walletId=${widget.walletId}');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EnhancedActionButton(
              icon: Icons.remove_circle_outline,
              label: l.withdraw,
              color: Colors.red,
              onPressed: () {
                context.go('/withdrawal?walletId=${widget.walletId}');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _EnhancedActionButton(
              icon: Icons.swap_horiz,
              label: l.transfer,
              color: AppColors.purple,
              onPressed: () {
                // TODO: Navigate to transfer page
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader(BuildContext context, dynamic l) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l.recentTransactions,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (_transactions.isNotEmpty)
            TextButton(
              onPressed: () {
                // TODO: Navigate to all transactions page
              },
              child: Text(
                l.viewAll,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic l) {
    // Debug print to track states
    print('=== Transaction List Debug ===');
    print('_isLoadingTransactions: $_isLoadingTransactions');
    print('_transactions.isEmpty: ${_transactions.isEmpty}');
    print('_transactions.length: ${_transactions.length}');
    print('_hasReachedMax: $_hasReachedMax');
    print('===============================');

    // Show skeleton loading for initial load
    if (_isLoadingTransactions && _transactions.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildTransactionSkeleton(),
          childCount: 3, // Show 3 skeleton items
        ),
      );
    }

    // Show empty state when no transactions and not loading
    if (_transactions.isEmpty && !_isLoadingTransactions) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha((0.3 * 255).round())
                    : Colors.grey.withAlpha((0.1 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l.noTransactionsYet,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.transactionsWillAppearHere,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _transactions.length) {
            if (_hasReachedMax) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.allTransactionsLoaded,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      l.transactionInTotal(_transactions.length,
                          _transactions.length == 1 ? '' : 's'),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            } else if (_isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      l.loadingMoreTransactions,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }
          }

          if (index < _transactions.length) {
            final transaction = _transactions[index];
            return Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: TransactionListItem(
                transaction: transaction,
                walletCurrency: _currentWallet!.currency,
              ),
            );
          }

          return const SizedBox.shrink();
        },
        childCount:
            _transactions.length + (_hasReachedMax || _isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildTransactionSkeleton() {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Avatar skeleton
              _buildShimmerContainer(40, 40, isCircular: true),
              const SizedBox(width: 16),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    _buildShimmerContainer(16, double.infinity),
                    const SizedBox(height: 8),
                    // Subtitle skeleton
                    _buildShimmerContainer(12, 150),
                    const SizedBox(height: 4),
                    // Date skeleton
                    _buildShimmerContainer(10, 100),
                  ],
                ),
              ),
              // Amount skeleton
              _buildShimmerContainer(16, 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double height, double width,
      {bool isCircular = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey[300]
                ?.withAlpha(((0.3 + (0.7 * value)) * 255).round()),
            borderRadius: isCircular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(height / 2),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, dynamic l) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l.oopsSomethingWentWrong,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _currentPage = 1;
              _transactions.clear();
              _walletBloc.add(GetWalletByIdEvent(widget.walletId));
              _loadTransactions();
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
    );
  }

  void _showWalletOptions(BuildContext context, dynamic l) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: theme.colorScheme.primary),
              title: Text(l.editWallet),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit wallet
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: theme.colorScheme.primary),
              title: Text(l.transactionHistory),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to transaction history
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: Text(l.walletSettings),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to wallet settings
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _EnhancedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.3 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
