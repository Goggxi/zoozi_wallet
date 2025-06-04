import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DepositPage extends StatefulWidget {
  final String walletId;

  const DepositPage({
    super.key,
    required this.walletId,
  });

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage>
    with TickerProviderStateMixin {
  late final WalletBloc _walletBloc;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  WalletModel? _currentWallet;
  bool _isProcessing = false;

  static const double _minAmount = 1.0;
  static const double _maxAmount = 1000000.0;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _animationController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isProcessing) {
          // Show confirmation dialog if trying to leave while processing
          _showLeaveConfirmationDialog(l);
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? theme.scaffoldBackgroundColor : Colors.grey[50],
        appBar: AppBar(
          title: Text(l.depositMoney),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackNavigation(),
          ),
        ),
        body: BlocConsumer<WalletBloc, WalletState>(
          bloc: _walletBloc,
          listener: (context, state) {
            if (state is WalletLoaded) {
              setState(() {
                _currentWallet = state.wallet;
              });
            } else if (state is TransactionCreated) {
              setState(() {
                _isProcessing = false;
              });
              _showSuccessDialog(l);
            } else if (state is WalletError) {
              setState(() {
                _isProcessing = false;
              });
              _showErrorSnackBar(state.message, l);
            }
          },
          builder: (context, state) {
            if (state is WalletLoading && _currentWallet == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletError && _currentWallet == null) {
              return _buildErrorState(state.message, l, theme);
            }

            final wallet = _currentWallet;
            if (wallet == null) {
              return Center(child: Text(l.somethingWentWrong));
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWalletCard(wallet, l, theme, isDark),
                      const SizedBox(height: 24),
                      _buildDepositForm(wallet, l, theme, isDark),
                      const SizedBox(height: 24),
                      _buildQuickAmountButtons(wallet, theme),
                      const SizedBox(height: 32),
                      _buildProceedButton(wallet, l, theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (_isProcessing) {
      _showLeaveConfirmationDialog(context.l10n);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        // If can't pop, navigate to wallet page or home
        context.go('/wallet');
      }
    }
  }

  void _showLeaveConfirmationDialog(dynamic l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.warning ?? 'Warning'),
        content: const Text(
            'Transaction is being processed. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
      WalletModel wallet, dynamic l, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
                  theme.colorScheme.secondary.withAlpha((0.2 * 255).round()),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkPurple2,
                  AppColors.purple,
                  AppColors.darkPurple3,
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? theme.colorScheme.primary : AppColors.purple)
                .withAlpha((0.3 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'My ${wallet.currency} Wallet',
                  style: TextStyle(
                    color: AppColors.white.withAlpha((0.9 * 255).round()),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Text(
            l.availableBalance(
              '${Currency.getSymbol(wallet.currency)}${wallet.balance.toStringAsFixed(2)}',
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositForm(
      WalletModel wallet, dynamic l, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.depositMoney,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildAmountField(wallet, l, theme),
            const SizedBox(height: 20),
            _buildDescriptionField(l, theme),
            const SizedBox(height: 20),
            _buildReferenceField(l, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(WalletModel wallet, dynamic l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: l.enterAmount,
            prefixIcon: Icon(
              Icons.attach_money,
              color: theme.colorScheme.primary,
            ),
            prefixText: Currency.getSymbol(wallet.currency),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ??
                theme.colorScheme.surface.withAlpha((0.5 * 255).round()),
          ),
          style: theme.textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l.pleaseEnterAmount;
            }
            final amount = double.tryParse(value);
            if (amount == null) {
              return l.invalidAmount;
            }
            if (amount < _minAmount) {
              return l.minimumAmount(
                  '${Currency.getSymbol(wallet.currency)}${_minAmount.toStringAsFixed(2)}');
            }
            if (amount > _maxAmount) {
              return l.maximumAmount(
                  '${Currency.getSymbol(wallet.currency)}${_maxAmount.toStringAsFixed(2)}');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(dynamic l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.description,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l.enterDescription,
            prefixIcon: Icon(
              Icons.description,
              color: theme.colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ??
                theme.colorScheme.surface.withAlpha((0.5 * 255).round()),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildReferenceField(dynamic l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.referenceId,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _referenceController,
          decoration: InputDecoration(
            hintText: l.enterReferenceId,
            prefixIcon: Icon(
              Icons.receipt,
              color: theme.colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ??
                theme.colorScheme.surface.withAlpha((0.5 * 255).round()),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildQuickAmountButtons(WalletModel wallet, ThemeData theme) {
    final quickAmounts = [10.0, 50.0, 100.0, 500.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return InkWell(
              onTap: () {
                _amountController.text = amount.toStringAsFixed(0);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary
                        .withAlpha((0.3 * 255).round()),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color:
                      theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                ),
                child: Text(
                  '${Currency.getSymbol(wallet.currency)}${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProceedButton(WalletModel wallet, dynamic l, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _proceedDeposit(wallet, l),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.processing,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                l.proceed,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorState(String message, dynamic l, ThemeData theme) {
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
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _walletBloc.add(GetWalletByIdEvent(widget.walletId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
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

  void _proceedDeposit(WalletModel wallet, dynamic l) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.trim();
    final reference = _referenceController.text.trim();

    _showConfirmationDialog(wallet, amount, description, reference, l);
  }

  void _showConfirmationDialog(WalletModel wallet, double amount,
      String description, String reference, dynamic l) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l.confirmTransaction,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.confirmDepositMessage(
                '${Currency.getSymbol(wallet.currency)}${amount.toStringAsFixed(2)}',
              ),
              style: theme.textTheme.bodyLarge,
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${l.description}: $description',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (reference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l.referenceId}: $reference',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _executeDeposit(wallet, amount, description, reference);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l.confirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _executeDeposit(
      WalletModel wallet, double amount, String description, String reference) {
    setState(() {
      _isProcessing = true;
    });

    // Use real API call instead of simulation
    _walletBloc.add(CreateDepositEvent(
      walletId: wallet.id!,
      amount: amount,
      description: description.isNotEmpty ? description : null,
      referenceId: reference.isNotEmpty ? reference : null,
    ));
  }

  void _showSuccessDialog(dynamic l) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                l.transactionSuccessful,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your deposit has been processed successfully.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _navigateAfterSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateAfterSuccess() {
    // Clear form after successful transaction
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();

    // Navigate back to previous screen or appropriate fallback
    if (context.canPop()) {
      context.pop();
    } else {
      // Navigate to wallet detail page using correct route format
      context.go('/wallet/${widget.walletId}');
    }
  }

  void _showErrorSnackBar(String message, dynamic l) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l.transactionFailed}: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
