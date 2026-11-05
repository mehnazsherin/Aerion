import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'ble_provider.dart';
import 'settings_provider.dart';

class SensorProvider extends ChangeNotifier {
  final BleProvider _bleProvider;
  final StorageService _storageService;
  final SettingsProvider _settingsProvider;
  final NotificationService _notificationService = NotificationService();

  SensorReading? _latestReading;
  List<SensorReading> _history = [];
  bool _isDemoMode = false;
  Timer? _demoTimer;
  StreamSubscription<SensorReading>? _bleReadingSub;

  SensorReading? get latestReading => _latestReading;
  List<SensorReading> get history => _history;
  bool get isDemoMode => _isDemoMode;

  double get minTemperature {
    if (_history.isEmpty) return _latestReading?.temperature ?? 0.0;
    return _history.map((r) => r.temperature).reduce(min);
  }

  double get maxTemperature {
    if (_history.isEmpty) return _latestReading?.temperature ?? 0.0;
    return _history.map((r) => r.temperature).reduce(max);
  }

  double get minHumidity {
    if (_history.isEmpty) return _latestReading?.humidity ?? 0.0;
    return _history.map((r) => r.humidity).reduce(min);
  }

  double get maxHumidity {
    if (_history.isEmpty) return _latestReading?.humidity ?? 0.0;
    return _history.map((r) => r.humidity).reduce(max);
  }

  double get avgTemperature {
    if (_history.isEmpty) return _latestReading?.temperature ?? 0.0;
    final total = _history.fold<double>(0.0, (sum, r) => sum + r.temperature);
    return total / _history.length;
  }

  double get avgHumidity {
    if (_history.isEmpty) return _latestReading?.humidity ?? 0.0;
    final total = _history.fold<double>(0.0, (sum, r) => sum + r.humidity);
    return total / _history.length;
  }

  SensorProvider(this._bleProvider, this._storageService, this._settingsProvider) {
    // Load historical real readings from persistent storage
    _history = _storageService.getSavedReadings();
    if (_history.isNotEmpty) {
      _latestReading = _history.last;
    }

    // Subscribe to incoming BLE characteristic telemetry
    _bleReadingSub = _bleProvider.readingsStream.listen((reading) {
      if (!_isDemoMode) {
        _onNewReading(reading);
      }
    });
  }

  void _onNewReading(SensorReading reading) {
    _latestReading = reading;
    _history.add(reading);
    if (_history.length > 1000) {
      _history.removeAt(0);
    }

    if (!reading.isDemo) {
      _storageService.saveReading(reading);
      _checkThresholdAlerts(reading);
    }

    notifyListeners();
  }

  void _checkThresholdAlerts(SensorReading reading) {
    if (!_settingsProvider.alertsEnabled) return;

    if (reading.temperature >= _settingsProvider.highTempThreshold) {
      _notificationService.showEnvironmentalAlert(
        title: "High Temperature Warning",
        body: "Recorded ${reading.temperature.toStringAsFixed(1)}°C, exceeding threshold (${_settingsProvider.highTempThreshold}°C).",
      );
    } else if (reading.temperature <= _settingsProvider.lowTempThreshold) {
      _notificationService.showEnvironmentalAlert(
        title: "Low Temperature Warning",
        body: "Recorded ${reading.temperature.toStringAsFixed(1)}°C, below threshold (${_settingsProvider.lowTempThreshold}°C).",
      );
    }

    if (reading.humidity >= _settingsProvider.highHumidityThreshold) {
      _notificationService.showEnvironmentalAlert(
        title: "High Humidity Warning",
        body: "Humidity reached ${reading.humidity.toStringAsFixed(1)}%, exceeding limit (${_settingsProvider.highHumidityThreshold}%).",
      );
    }
  }

  // --- Demo Mode Simulation ---
  void enableDemoMode() {
    if (_isDemoMode) return;
    _isDemoMode = true;

    // Disconnect real BLE if active to avoid conflation
    if (_bleProvider.isConnected) {
      _bleProvider.disconnect();
    }

    // Seed realistic demo history for the last 1 hour without saving to SQLite/Prefs
    final now = DateTime.now();
    _history = List.generate(30, (i) {
      final t = now.subtract(Duration(minutes: (30 - i) * 2));
      final temp = 22.5 + sin(i / 3) * 2.5 + (Random().nextDouble() * 0.5);
      final hum = 52.0 + cos(i / 4) * 6.0 + (Random().nextDouble() * 1.0);
      return SensorReading(
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        timestamp: t,
        isDemo: true,
      );
    });

    _latestReading = _history.last;
    notifyListeners();

    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final currentT = _latestReading?.temperature ?? 24.0;
      final currentH = _latestReading?.humidity ?? 50.0;

      final deltaT = (Random().nextDouble() - 0.5) * 0.4;
      final deltaH = (Random().nextDouble() - 0.5) * 0.8;

      final newReading = SensorReading(
        temperature: double.parse((currentT + deltaT).clamp(16.0, 38.0).toStringAsFixed(1)),
        humidity: double.parse((currentH + deltaH).clamp(25.0, 85.0).toStringAsFixed(1)),
        timestamp: DateTime.now(),
        isDemo: true,
      );

      _onNewReading(newReading);
    });
  }

  void disableDemoMode() {
    if (!_isDemoMode) return;
    _demoTimer?.cancel();
    _isDemoMode = false;

    // Reload genuine stored readings
    _history = _storageService.getSavedReadings();
    _latestReading = _history.isNotEmpty ? _history.last : null;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearReadings();
    _history = [];
    _latestReading = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _bleReadingSub?.cancel();
    super.dispose();
  }
}

