import 'package:flutter/material.dart';
import '../products_screen.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse existing products listing with search and purchase modal
    return const ProductsScreen();
  }
}
