import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/core/theme/app_colors.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/di/di.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletBloc _walletBloc;

  @override
  void initState() {
    super.initState();
    _walletBloc = getIt<WalletBloc>();
    _walletBloc.add(GetWalletsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.myWallets),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('${AppRouter.wallet}/${AppRouter.addWallet}');
            },
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        bloc: _walletBloc,
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(child: Text(state.message));
          }

          if (state is WalletsLoaded) {
            final sortedWallets = List.of(state.wallets)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (sortedWallets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppColors.grey,
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
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .push('${AppRouter.wallet}/${AppRouter.addWallet}');
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

            return RefreshIndicator(
              onRefresh: () async {
                _walletBloc.add(GetWalletsEvent());
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        context.push('${AppRouter.wallet}/${wallet.id}');
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.all(24),
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
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(
                                    Icons.credit_card,
                                    color: AppColors.white,
                                    size: 32,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      wallet.currency,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '\$${wallet.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wallet.name,
                                        style: TextStyle(
                                          color: AppColors.white.withAlpha(70),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        wallet.currency,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  @override
  void dispose() {
    _walletBloc.close();
    super.dispose();
  }
}
