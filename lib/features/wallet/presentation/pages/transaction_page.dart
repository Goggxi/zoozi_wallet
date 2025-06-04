import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';

import '../../../../di/di.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_list_item.dart';

enum TransactionFilter { all, income, expense, transfer }

enum DateFilter { all, last7Days, last30Days, thisMonth, customRange }

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
  late final WalletBloc _walletBloc;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final ScrollController _scrollController;

  final List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  TransactionFilter _selectedTypeFilter = TransactionFilter.all;
  DateFilter _selectedDateFilter = DateFilter.all;
  DateTimeRange? _customDateRange;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _walletsToLoad = 0;
  int _walletsLoaded = 0;

  @override
  void initState() {
    super.initState();
    _walletBloc = WalletBloc(getIt());
    _scrollController = ScrollController();
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

    _loadAllTransactions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  void _loadAllTransactions() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _allTransactions.clear();
      _walletsToLoad = 0;
      _walletsLoaded = 0;
    });

    // First get all wallets, then get transactions for each wallet
    _walletBloc.add(const GetWalletsEvent());
  }

  void _loadTransactionsForAllWallets(List<dynamic> wallets) {
    setState(() {
      _walletsToLoad = wallets.where((w) => w.id != null).length;
      _walletsLoaded = 0;
    });

    if (_walletsToLoad == 0) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      _applyFilters();
      return;
    }

    // Add timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = _allTransactions.isEmpty;
          _errorMessage = 'Loading timeout. Please try again.';
        });
        _applyFilters();
      }
    });

    // Load transactions for each wallet
    for (var wallet in wallets) {
      if (wallet.id != null) {
        _walletBloc.add(
          GetTransactionsEvent(
            walletId: wallet.id!,
            page: 1,
            limit: 50, // Reduce limit to speed up loading
          ),
        );
      } else {
        // Count wallets without ID as processed
        setState(() {
          _walletsLoaded++;
        });
      }
    }
  }

  void _applyFilters() {
    List<TransactionModel> filtered = List.from(_allTransactions);

    // Apply type filter
    if (_selectedTypeFilter != TransactionFilter.all) {
      filtered = filtered.where((transaction) {
        switch (_selectedTypeFilter) {
          case TransactionFilter.income:
            return transaction.type == entity.TransactionType.income;
          case TransactionFilter.expense:
            return transaction.type == entity.TransactionType.expense;
          case TransactionFilter.transfer:
            return transaction.type == entity.TransactionType.transfer;
          case TransactionFilter.all:
            return true;
        }
      }).toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (_selectedDateFilter) {
      case DateFilter.last7Days:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        filtered = filtered
            .where((transaction) => transaction.createdAt.isAfter(sevenDaysAgo))
            .toList();
        break;
      case DateFilter.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        filtered = filtered
            .where(
                (transaction) => transaction.createdAt.isAfter(thirtyDaysAgo))
            .toList();
        break;
      case DateFilter.thisMonth:
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        filtered = filtered
            .where(
                (transaction) => transaction.createdAt.isAfter(firstDayOfMonth))
            .toList();
        break;
      case DateFilter.customRange:
        if (_customDateRange != null) {
          filtered = filtered
              .where((transaction) =>
                  transaction.createdAt.isAfter(_customDateRange!.start) &&
                  transaction.createdAt.isBefore(
                      _customDateRange!.end.add(const Duration(days: 1))))
              .toList();
        }
        break;
      case DateFilter.all:
        break;
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        title: Text(l.allTransactions),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, l, theme),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              switch (value) {
                case 'deposit':
                  // Navigate to wallet selection for deposit
                  context.push('/deposit');
                  break;
                case 'withdrawal':
                  // Navigate to wallet selection for withdrawal
                  context.push('/withdrawal');
                  break;
                case 'transfer':
                  // TODO: Implement transfer
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deposit',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(l.deposit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'withdrawal',
                child: Row(
                  children: [
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(l.withdraw),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'transfer',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, color: AppColors.purple),
                    const SizedBox(width: 12),
                    Text(l.transfer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          print('Transaction page state: ${state.runtimeType}');

          if (state is WalletsLoaded) {
            print('Wallets loaded: ${state.wallets.length}');
            // Load transactions for all wallets
            _loadTransactionsForAllWallets(state.wallets);
          } else if (state is TransactionsLoaded) {
            print(
                'Transactions loaded: ${state.transactions.length} for wallet');
            setState(() {
              _allTransactions.addAll(state.transactions);
              _walletsLoaded++;

              // Check if all wallets have been loaded
              if (_walletsLoaded >= _walletsToLoad) {
                _isLoading = false;
                _hasError = false;
                print(
                    'All wallets processed. Total transactions: ${_allTransactions.length}');
              }
            });
            _applyFilters();
          } else if (state is WalletError) {
            print('Wallet error: ${state.message}');
            setState(() {
              _walletsLoaded++;

              // Check if all wallets have been processed (including errors)
              if (_walletsLoaded >= _walletsToLoad) {
                _isLoading = false;
                _hasError = _allTransactions.isEmpty;
                _errorMessage = state.message;
                print(
                    'All wallets processed with errors. Has transactions: ${_allTransactions.isNotEmpty}');
              }
            });
            if (_walletsLoaded >= _walletsToLoad) {
              _applyFilters();
            }
          }
        },
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildFilterChips(l, theme),
                Expanded(
                  child: _buildTransactionsList(l, theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(dynamic l, ThemeData theme) {
    if (_selectedTypeFilter == TransactionFilter.all &&
        _selectedDateFilter == DateFilter.all) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedTypeFilter != TransactionFilter.all)
            FilterChip(
              label: Text(_getTypeFilterLabel(_selectedTypeFilter, l)),
              onSelected: (selected) {
                setState(() {
                  _selectedTypeFilter = TransactionFilter.all;
                });
                _applyFilters();
              },
              onDeleted: () {
                setState(() {
                  _selectedTypeFilter = TransactionFilter.all;
                });
                _applyFilters();
              },
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle:
                  TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          if (_selectedDateFilter != DateFilter.all)
            FilterChip(
              label: Text(_getDateFilterLabel(_selectedDateFilter, l)),
              onSelected: (selected) {
                setState(() {
                  _selectedDateFilter = DateFilter.all;
                });
                _applyFilters();
              },
              onDeleted: () {
                setState(() {
                  _selectedDateFilter = DateFilter.all;
                  _customDateRange = null;
                });
                _applyFilters();
              },
              backgroundColor: theme.colorScheme.secondaryContainer,
              labelStyle:
                  TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic l, ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError && _allTransactions.isEmpty) {
      return _buildErrorState(l, theme);
    }

    if (_filteredTransactions.isEmpty) {
      return _buildEmptyState(l, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadAllTransactions();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TransactionListItem(
              transaction: transaction,
              walletCurrency: 'USD', // TODO: Get from wallet
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildTransactionSkeleton(),
    );
  }

  Widget _buildTransactionSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildShimmerContainer(40, 40, isCircular: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(16, double.infinity),
                    const SizedBox(height: 8),
                    _buildShimmerContainer(12, 150),
                    const SizedBox(height: 4),
                    _buildShimmerContainer(10, 100),
                  ],
                ),
              ),
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

  Widget _buildEmptyState(dynamic l, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              _allTransactions.isEmpty
                  ? l.noTransactionsYet
                  : 'No transactions match your filters',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _allTransactions.isEmpty
                  ? l.transactionsWillAppearHere
                  : 'Try adjusting your filters or add a new transaction',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/deposit'),
              icon: const Icon(Icons.add),
              label: Text(l.newTransaction),
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

  Widget _buildErrorState(dynamic l, ThemeData theme) {
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
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAllTransactions,
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

  void _showFilterDialog(BuildContext context, dynamic l, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.filterTransactions,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l.filterByType,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: TransactionFilter.values.map((filter) {
                final isSelected = _selectedTypeFilter == filter;
                return FilterChip(
                  label: Text(_getTypeFilterLabel(filter, l)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTypeFilter = filter;
                    });
                    _applyFilters();
                  },
                  backgroundColor: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              l.filterByDate,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DateFilter.values.map((filter) {
                final isSelected = _selectedDateFilter == filter;
                return FilterChip(
                  label: Text(_getDateFilterLabel(filter, l)),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (filter == DateFilter.customRange) {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _customDateRange,
                      );
                      if (dateRange != null) {
                        setState(() {
                          _selectedDateFilter = filter;
                          _customDateRange = dateRange;
                        });
                        _applyFilters();
                      }
                    } else {
                      setState(() {
                        _selectedDateFilter = filter;
                        _customDateRange = null;
                      });
                      _applyFilters();
                    }
                  },
                  backgroundColor: isSelected
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTypeFilter = TransactionFilter.all;
                        _selectedDateFilter = DateFilter.all;
                        _customDateRange = null;
                      });
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.clearFilter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.applyFilter),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeFilterLabel(TransactionFilter filter, dynamic l) {
    switch (filter) {
      case TransactionFilter.all:
        return l.allTypes;
      case TransactionFilter.income:
        return l.income;
      case TransactionFilter.expense:
        return l.expense;
      case TransactionFilter.transfer:
        return l.transfer;
    }
  }

  String _getDateFilterLabel(DateFilter filter, dynamic l) {
    switch (filter) {
      case DateFilter.all:
        return l.allTypes;
      case DateFilter.last7Days:
        return l.last7Days;
      case DateFilter.last30Days:
        return l.last30Days;
      case DateFilter.thisMonth:
        return l.thisMonth;
      case DateFilter.customRange:
        return _customDateRange != null
            ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
            : l.customRange;
    }
  }
}
