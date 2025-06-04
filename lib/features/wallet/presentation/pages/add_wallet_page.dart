import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/core/widgets/custom_button.dart';
import 'package:zoozi_wallet/core/widgets/custom_text_field.dart';
import '../../../../di/di.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/currency_dropdown.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  late final WalletBloc _walletBloc;
  final _formKey = GlobalKey<FormState>();
  final _initialBalanceController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _walletBloc = getIt<WalletBloc>();
  }

  @override
  void dispose() {
    _initialBalanceController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _walletBloc.add(
        CreateWalletEvent(
          currency: _selectedCurrency,
          initialBalance: double.parse(_initialBalanceController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.addNewWallet),
        elevation: 0,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) async {
          if (state is WalletCreated) {
            _walletBloc.add(GetWalletsEvent());

            // Wait for wallets to load
            await for (final state in _walletBloc.stream) {
              if (state is WalletsLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.walletCreatedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
                break;
              }
              // Break if error occurs
              if (state is WalletError) break;
            }
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.walletInformation,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CurrencyDropdown(
                            value: _selectedCurrency,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCurrency = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            hintText: l.initialBalance,
                            prefixIcon: Icons.attach_money,
                            controller: _initialBalanceController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l.pleaseEnterInitialBalance;
                              }
                              if (double.tryParse(value) == null) {
                                return l.pleaseEnterValidNumber;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: l.createWallet,
                    onPressed: _submitForm,
                    isLoading: state is WalletLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
