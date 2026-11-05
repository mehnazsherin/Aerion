class SensorReading {
  final double temperature; // in °C
  final double humidity;    // in %
  final DateTime timestamp;
  final bool isDemo;

  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    this.isDemo = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
      'isDemo': isDemo,
    };
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }

  double get temperatureFahrenheit => (temperature * 9 / 5) + 32;

  @override
  String toString() =>
      'SensorReading(temp: ${temperature.toStringAsFixed(1)}°C, hum: ${humidity.toStringAsFixed(1)}%, time: $timestamp, demo: $isDemo)';
}

