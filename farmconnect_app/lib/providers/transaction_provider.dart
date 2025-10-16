import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final _api = ApiService();
  List<AppTransaction> history = [];
  bool loading = false;

  Future<void> fetchHistory() async {
    loading = true;
    notifyListeners();
    try {
      history = await _api.getTransactions();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> checkout(CartProvider cart) async {
    if (cart.items.isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      for (final item in cart.items) {
        await _api.createTransaction(productId: item.product.id, quantity: item.qty);
      }
      cart.clear();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
