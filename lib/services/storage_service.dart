import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_reading.dart';

class StorageService {
  static const String _readingsKey = 'aerion_readings_history';
  static const String _themeModeKey = 'aerion_theme_mode';
  static const String _tempUnitKey = 'aerion_temp_unit';
  static const String _defaultIntervalKey = 'aerion_sampling_interval';
  static const String _targetDeviceNameKey = 'aerion_target_device';
  static const String _autoReconnectKey = 'aerion_auto_reconnect';
  static const String _highTempAlertKey = 'aerion_high_temp_threshold';
  static const String _lowTempAlertKey = 'aerion_low_temp_threshold';
  static const String _highHumidityAlertKey = 'aerion_high_humidity_threshold';
  static const String _alertsEnabledKey = 'aerion_alerts_enabled';
  static const String _lastConnectedIdKey = 'aerion_last_connected_device_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Real Sensor Readings History ---
  List<SensorReading> getSavedReadings() {
    final raw = _prefs.getStringList(_readingsKey) ?? [];
    return raw.map((item) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return SensorReading.fromJson(decoded);
      } catch (_) {
        return null;
      }
    }).whereType<SensorReading>().toList();
  }

  Future<void> saveReading(SensorReading reading) async {
    if (reading.isDemo) return; // Strict policy: Never mix demo readings into persistent store!
    final readings = getSavedReadings();
    readings.add(reading);
    
    // Retain up to 2000 points to keep storage fast
    if (readings.length > 2000) {
      readings.removeRange(0, readings.length - 2000);
    }

    final raw = readings.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_readingsKey, raw);
  }

  Future<void> clearReadings() async {
    await _prefs.remove(_readingsKey);
  }

  // --- Settings ---
  bool get isDarkMode => _prefs.getBool(_themeModeKey) ?? true;
  Future<void> setDarkMode(bool value) async => await _prefs.setBool(_themeModeKey, value);

  bool get isFahrenheit => _prefs.getBool(_tempUnitKey) ?? false;
  Future<void> setFahrenheit(bool value) async => await _prefs.setBool(_tempUnitKey, value);

  int get defaultInterval => _prefs.getInt(_defaultIntervalKey) ?? 5;
  Future<void> setDefaultInterval(int value) async => await _prefs.setInt(_defaultIntervalKey, value);

  String get targetDeviceName => _prefs.getString(_targetDeviceNameKey) ?? "AQM-Meha";
  Future<void> setTargetDeviceName(String value) async => await _prefs.setString(_targetDeviceNameKey, value);

  bool get autoReconnect => _prefs.getBool(_autoReconnectKey) ?? true;
  Future<void> setAutoReconnect(bool value) async => await _prefs.setBool(_autoReconnectKey, value);

  String? get lastConnectedDeviceId => _prefs.getString(_lastConnectedIdKey);
  Future<void> setLastConnectedDeviceId(String? value) async {
    if (value == null) {
      await _prefs.remove(_lastConnectedIdKey);
    } else {
      await _prefs.setString(_lastConnectedIdKey, value);
    }
  }

  // --- Alert Thresholds ---
  bool get alertsEnabled => _prefs.getBool(_alertsEnabledKey) ?? true;
  Future<void> setAlertsEnabled(bool value) async => await _prefs.setBool(_alertsEnabledKey, value);

  double get highTempThreshold => _prefs.getDouble(_highTempAlertKey) ?? 35.0;
  Future<void> setHighTempThreshold(double value) async => await _prefs.setDouble(_highTempAlertKey, value);

  double get lowTempThreshold => _prefs.getDouble(_lowTempAlertKey) ?? 15.0;
  Future<void> setLowTempThreshold(double value) async => await _prefs.setDouble(_lowTempAlertKey, value);

  double get highHumidityThreshold => _prefs.getDouble(_highHumidityAlertKey) ?? 75.0;
  Future<void> setHighHumidityThreshold(double value) async => await _prefs.setDouble(_highHumidityAlertKey, value);
}

