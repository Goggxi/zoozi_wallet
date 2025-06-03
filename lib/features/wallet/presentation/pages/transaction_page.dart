import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // TODO: Replace with actual transaction count
        itemBuilder: (context, index) {
          return const Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.swap_horiz),
              ),
              title: Text('Transaction Title'),
              subtitle: Text('Date: 2024-03-14'),
              trailing: Text(
                '\$0.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add transaction page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
