class SensorReading {
  final int id;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime updatedAt;

  SensorReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.updatedAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> j) => SensorReading(
        id: (j['id'] as num).toInt(),
        temperature: (j['temperature'] ?? j['suhu'] as num).toDouble(),
        humidity: (j['humidity'] ?? j['kelembapan'] as num).toDouble(),
        soilMoisture: (j['soil_moisture'] as num).toDouble(),
        updatedAt: DateTime.parse((j['updated_at'] ?? j['recorded_at']) as String),
      );
}
