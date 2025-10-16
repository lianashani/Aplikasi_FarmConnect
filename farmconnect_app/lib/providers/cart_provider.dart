import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, required this.qty});
  double get subtotal => product.price * qty;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  void add(Product p, {int qty = 1}) {
    final idx = _items.indexWhere((e) => e.product.id == p.id);
    if (idx >= 0) {
      _items[idx].qty += qty;
    } else {
      _items.add(CartItem(product: p, qty: qty));
    }
    notifyListeners();
  }

  void updateQty(Product p, int qty) {
    final idx = _items.indexWhere((e) => e.product.id == p.id);
    if (idx >= 0) {
      _items[idx].qty = qty.clamp(1, 9999);
      notifyListeners();
    }
  }

  void remove(Product p) {
    _items.removeWhere((e) => e.product.id == p.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get total => _items.fold(0.0, (a, b) => a + b.subtotal);
}
