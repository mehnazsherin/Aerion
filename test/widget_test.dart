import 'package:flutter_test/flutter_test.dart';
import 'package:aerion/models/sensor_reading.dart';
import 'package:aerion/core/constants/ble_constants.dart';

void main() {
  group('Aerion Model and Config Unit Tests', () {
    test('SensorReading correctly handles Celsius to Fahrenheit conversion', () {
      final reading = SensorReading(
        temperature: 25.0,
        humidity: 60.0,
        timestamp: DateTime(2026, 11, 5, 12, 0),
      );

      expect(reading.temperature, 25.0);
      expect(reading.humidity, 60.0);
      expect(reading.temperatureFahrenheit, 77.0);
      expect(reading.isDemo, false);
    });

    test('SensorReading JSON serialization and deserialization', () {
      final original = SensorReading(
        temperature: 28.4,
        humidity: 72.1,
        timestamp: DateTime.now(),
        isDemo: true,
      );

      final json = original.toJson();
      final restored = SensorReading.fromJson(json);

      expect(restored.temperature, original.temperature);
      expect(restored.humidity, original.humidity);
      expect(restored.isDemo, original.isDemo);
    });

    test('BLE UUID Configuration integrity', () {
      expect(BleUuidConfig.defaultServiceUuid, isNotEmpty);
      expect(BleUuidConfig.defaultTemperatureCharUuid, isNotEmpty);
      expect(BleUuidConfig.defaultHumidityCharUuid, isNotEmpty);
      expect(BleUuidConfig.defaultSamplingIntervalCharUuid, isNotEmpty);
      expect(BleUuidConfig.defaultDevicePrefix, 'AQM-');
    });
  });
}
