import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // TODO: Replace with actual wallet count
        itemBuilder: (context, index) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Wallet Name'),
              subtitle: Text('Balance: \$0.00'),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
} 