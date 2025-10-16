import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onBuy;
  const ProductCard({super.key, required this.product, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: const Color(0xFFFFF8E1), // nuansa coklat muda
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
                image: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (product.imageUrl == null || product.imageUrl!.isEmpty)
                  ? const Icon(Icons.agriculture, color: Color(0xFF2E7D32))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Harga: Rp ${product.price.toStringAsFixed(0)}'),
                  Text('Stok: ${product.stock}'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // hijau
                foregroundColor: Colors.white,
              ),
              onPressed: onBuy,
              child: const Text('Beli Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
