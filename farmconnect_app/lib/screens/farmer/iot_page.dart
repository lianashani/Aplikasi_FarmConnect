import 'dart:async';
import 'package:flutter/material.dart';

class FarmerIotPage extends StatefulWidget {
  const FarmerIotPage({super.key});

  @override
  State<FarmerIotPage> createState() => _FarmerIotPageState();
}

class _FarmerIotPageState extends State<FarmerIotPage> {
  double temperature = 29.0;
  double soilMoisture = 45.0; // %
  double humidity = 70.0; // %
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _simulate());
  }

  void _simulate() {
    setState(() {
      temperature += ([-1, -0.5, 0, 0.5, 1]..shuffle()).first;
      soilMoisture += ([-2, -1, 0, 1, 2]..shuffle()).first.toDouble();
      humidity += ([-2, -1, 0, 1, 2]..shuffle()).first.toDouble();
      temperature = temperature.clamp(20, 40);
      soilMoisture = soilMoisture.clamp(10, 90);
      humidity = humidity.clamp(20, 100);
    });
  }

  Color _statusColor(double value, {required double low, required double high}) {
    if (value < low) return Colors.red;
    if (value > high) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Sensor')),
      body: RefreshIndicator(
        onRefresh: () async => _simulate(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile('Suhu Udara', '${temperature.toStringAsFixed(1)} °C', _statusColor(temperature, low: 22, high: 34)),
            const SizedBox(height: 10),
            _tile('Kelembapan Tanah', '${soilMoisture.toStringAsFixed(0)} %', _statusColor(soilMoisture, low: 30, high: 70)),
            const SizedBox(height: 10),
            _tile('Kelembapan Udara', '${humidity.toStringAsFixed(0)} %', _statusColor(humidity, low: 40, high: 85)),
            const SizedBox(height: 10),
            const Text('Auto-refresh setiap 10 detik (simulasi).'),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String value, Color color) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.circle, color: color),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
