class SensorReading {
  final int id;
  final double temperature;
  final double soilMoisture;
  final DateTime recordedAt;

  SensorReading({
    required this.id,
    required this.temperature,
    required this.soilMoisture,
    required this.recordedAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> j) => SensorReading(
        id: j['id'] as int,
        temperature: (j['temperature'] as num).toDouble(),
        soilMoisture: (j['soil_moisture'] as num).toDouble(),
        recordedAt: DateTime.parse(j['recorded_at'] as String),
      );
}
