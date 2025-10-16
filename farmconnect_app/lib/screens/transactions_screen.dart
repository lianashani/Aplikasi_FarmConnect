import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final api = ApiService();
  late Future<List<AppTransaction>> future;

  @override
  void initState() {
    super.initState();
    future = api.getTransactions();
  }

  Future<void> _refresh() async {
    setState(() {
      future = api.getTransactions();
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: FutureBuilder<List<AppTransaction>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Belum ada transaksi')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final t = items[i];
                return Card(
                  color: const Color(0xFFFFF8E1),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: Color(0xFF2E7D32)),
                    title: Text(t.productName ?? 'Produk #${t.productId}'),
                    subtitle: Text('Qty: ${t.quantity}  •  Total: Rp ${t.totalPrice.toStringAsFixed(0)}\nStatus: ${t.status}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
