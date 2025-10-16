import 'package:flutter/material.dart';

class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Petani')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Ringkasan Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Total produk diunggah: 3 (mock)'),
            Text('• Total penjualan: Rp 120.000 (mock)'),
            Text('• Sensor terkini: Suhu 29°C, Kelembapan Tanah 45% (mock)'),
          ],
        ),
      ),
    );
  }
}
