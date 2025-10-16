import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_reading.dart';
import '../services/api_service.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final api = ApiService();
  List<SensorReading> readings = [];
  bool loading = true;
  String? error;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await api.getSensorReadings();
      if (!mounted) return;
      setState(() {
        readings = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), // hijau
        primary: const Color(0xFF2E7D32),
        secondary: const Color(0xFFA1887F), // coklat muda
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      useMaterial3: true,
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Data Sensor')),
        body: Builder(
          builder: (context) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null) {
              return Center(child: Text('Error: $error'));
            }
            if (readings.isEmpty) {
              return const Center(child: Text('Belum ada data sensor'));
            }
            return RefreshIndicator(
              onRefresh: _fetch,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (_, i) {
                  final r = readings[i];
                  return Card(
                    color: const Color(0xFFFFF8E1), // nuansa coklat muda kekuningan
                    child: ListTile(
                      leading: const Icon(Icons.thermostat, color: Color(0xFF2E7D32)),
                      title: Text(
                        'Suhu: ${r.temperature.toStringAsFixed(1)} °C',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kelembapan Tanah: ${r.soilMoisture.toStringAsFixed(1)} %'),
                          Text('Waktu: ${r.recordedAt.toLocal()}'),
                        ],
                      ),
                      trailing: const Icon(Icons.water_drop, color: Color(0xFFA1887F)),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: readings.length,
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _fetch,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
