import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('流水详情')),
      body: Center(
        child: Text(
          'transactionId: $transactionId',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
