import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add wallet page
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
            if (state.wallets.isEmpty) {
              return const Center(
                child: Text('No wallets found. Add one to get started!'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.wallets.length,
              itemBuilder: (context, index) {
                final wallet = state.wallets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                            Color(0xFF4A148C), // Deep Purple
                            Color(0xFF7B1FA2), // Purple
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 32,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'VISA',
                                  style: TextStyle(
                                    color: Colors.white,
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
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallet.id ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    wallet.currency,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: Navigate to wallet details
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong'));
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
