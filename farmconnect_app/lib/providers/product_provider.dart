import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Product> items = [];
  String query = '';

  Future<void> refresh() async {
    final data = await _api.getProducts();
    items = data;
    notifyListeners();
  }

  List<Product> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((p) => p.name.toLowerCase().contains(q)).toList();
  }
}
