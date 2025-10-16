import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/transaction_provider.dart';

class BuyerCartPage extends StatelessWidget {
  const BuyerCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final trx = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = cart.items[i];
                return Card(
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Harga: Rp ${item.product.price.toStringAsFixed(0)}'),
                    trailing: SizedBox(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cart.updateQty(item.product, (item.qty - 1).clamp(1, 9999)),
                          ),
                          Text('${item.qty}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cart.updateQty(item.product, item.qty + 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFFFFF6E5), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
        child: Row(
          children: [
            Expanded(child: Text('Total: Rp ${cart.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: trx.loading || cart.items.isEmpty
                  ? null
                  : () async {
                      await context.read<TransactionProvider>().checkout(cart);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout berhasil')));
                      }
                    },
              child: trx.loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Checkout'),
            )
          ],
        ),
      ),
    );
  }
}
