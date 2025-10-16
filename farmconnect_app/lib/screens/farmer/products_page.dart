import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';

class FarmerProductsPage extends StatefulWidget {
  const FarmerProductsPage({super.key});

  @override
  State<FarmerProductsPage> createState() => _FarmerProductsPageState();
}

class _FarmerProductsPageState extends State<FarmerProductsPage> {
  final _api = ApiService();
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().refresh());
  }

  void _openForm([Product? p]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: _ProductForm(product: p),
      ),
    );
    if (mounted) context.read<ProductProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.userId;
    final items = uid == null
        ? prov.items
        : prov.items.where((p) => p.userId == null || p.userId == uid).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: prov.refresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = items[i];
            return Card(
              child: ListTile(
                title: Text(p.name),
                subtitle: Text('Harga: Rp ${p.price.toStringAsFixed(0)}  •  Stok: ${p.stock}')
                    ,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(p)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                      try {
                        await _api.deleteProduct(p.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk dihapus')));
                        await context.read<ProductProvider>().refresh();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
                      }
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({required this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _desc = TextEditingController();
  final _api = ApiService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name;
      _price.text = p.price.toStringAsFixed(0);
      _stock.text = p.stock.toString();
      _desc.text = p.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama')), 
          const SizedBox(height: 8),
          TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)')),
          const SizedBox(height: 8),
          TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok')),
          const SizedBox(height: 8),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final name = _name.text.trim();
                      final price = double.tryParse(_price.text.trim());
                      final stock = int.tryParse(_stock.text.trim());
                      if (name.isEmpty || price == null || stock == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Isi nama, harga, dan stok dengan benar')),
                        );
                        return;
                      }
                      setState(() => _saving = true);
                      try {
                        if (widget.product == null) {
                          await _api.createProduct(
                            name: name,
                            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                            price: price,
                            stock: stock,
                          );
                        } else {
                          await _api.updateProduct(
                            id: widget.product!.id,
                            name: name,
                            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                            price: price,
                            stock: stock,
                          );
                        }
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk disimpan')));
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
