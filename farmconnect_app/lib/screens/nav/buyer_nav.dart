import 'package:flutter/material.dart';
import '../buyer/home_page.dart';
import '../buyer/cart_page.dart';
import '../buyer/history_page.dart';
import '../shared/profile_page.dart';

class BuyerNav extends StatefulWidget {
  const BuyerNav({super.key});

  @override
  State<BuyerNav> createState() => _BuyerNavState();
}

class _BuyerNavState extends State<BuyerNav> {
  int _index = 0;
  final pages = [
    BuyerHomePage(),
    BuyerCartPage(),
    BuyerHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
