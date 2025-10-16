import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class BuyerHistoryPage extends StatefulWidget {
  const BuyerHistoryPage({super.key});

  @override
  State<BuyerHistoryPage> createState() => _BuyerHistoryPageState();
}

class _BuyerHistoryPageState extends State<BuyerHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TransactionProvider>().fetchHistory());
  }

  Future<void> _refresh() async {
    await context.read<TransactionProvider>().fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: prov.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final t = prov.history[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(t.productName ?? 'Produk #${t.productId}'),
                      subtitle: Text('Qty: ${t.quantity}  •  Total: Rp ${t.totalPrice.toStringAsFixed(0)}\nStatus: ${t.status}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
