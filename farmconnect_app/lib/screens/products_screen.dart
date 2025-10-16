import 'package:flutter/material.dart';
import 'transactions_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final api = ApiService();
  late Future<List<Product>> future;
  List<Product> _all = [];
  List<Product> _filtered = [];
  final _searchCtrl = TextEditingController();
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    future = api.getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      future = api.getProducts();
    });
    final data = await future;
    if (!mounted) return;
    setState(() {
      _all = data;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List<Product>.from(_all)
        : _all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _buy(Product p) async {
    int qty = 1;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        double total() => p.price * qty;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Harga: Rp ${p.price.toStringAsFixed(0)}'),
                  Text('Stok tersedia: ${p.stock}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (qty > 1) setModal(() => qty--);
                        },
                      ),
                      Text('$qty', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (qty < p.stock) setModal(() => qty++);
                        },
                      ),
                      const Spacer(),
                      Text('Total: Rp ${total().toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await _confirmPurchase(p, qty);
                      },
                      child: const Text('Konfirmasi Beli'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmPurchase(Product p, int qty) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memproses transaksi...')),
    );
    try {
      if (qty < 1) throw Exception('Jumlah tidak valid');
      if (qty > p.stock) throw Exception('Stok tidak mencukupi');
      await api.createTransaction(productId: p.id, quantity: qty);
      // mainkan sound sukses (fallback klik jika gagal)
      try {
        await _player.play(UrlSource('https://actions.google.com/sounds/v1/cartoon/clang_and_wobble.ogg'));
      } catch (_) {
        await SystemSound.play(SystemSoundType.click);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian berhasil!')),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal beli: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (_all.isEmpty) {
            _all = snap.data ?? [];
            _applyFilter();
          }
          final items = _filtered;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari produk...',
                        filled: true,
                      ),
                      onChanged: (_) => setState(_applyFilter),
                    ),
                  ),
                  const SizedBox(height: 120),
                  const Center(child: Text('Tidak ada produk')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Cari produk...',
                      filled: true,
                    ),
                    onChanged: (_) => setState(_applyFilter),
                  );
                }
                final idx = i - 1;
                return ProductCard(
                  product: items[idx],
                  onBuy: () => _buy(items[idx]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
