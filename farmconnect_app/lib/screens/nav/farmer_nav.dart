import 'package:flutter/material.dart';
import '../farmer/dashboard_page.dart';
import '../farmer/products_page.dart';
import '../farmer/iot_page.dart';
import '../shared/profile_page.dart';

class FarmerNav extends StatefulWidget {
  const FarmerNav({super.key});

  @override
  State<FarmerNav> createState() => _FarmerNavState();
}

class _FarmerNavState extends State<FarmerNav> {
  int _index = 0;
  final pages = [
    FarmerDashboardPage(),
    FarmerProductsPage(),
    FarmerIotPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'IoT'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
