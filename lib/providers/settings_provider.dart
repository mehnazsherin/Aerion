import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  late bool _isDarkMode;
  late bool _isFahrenheit;
  late int _defaultInterval;
  late String _targetDeviceName;
  late bool _autoReconnect;
  late bool _alertsEnabled;
  late double _highTempThreshold;
  late double _lowTempThreshold;
  late double _highHumidityThreshold;

  SettingsProvider(this._storageService) {
    _isDarkMode = _storageService.isDarkMode;
    _isFahrenheit = _storageService.isFahrenheit;
    _defaultInterval = _storageService.defaultInterval;
    _targetDeviceName = _storageService.targetDeviceName;
    _autoReconnect = _storageService.autoReconnect;
    _alertsEnabled = _storageService.alertsEnabled;
    _highTempThreshold = _storageService.highTempThreshold;
    _lowTempThreshold = _storageService.lowTempThreshold;
    _highHumidityThreshold = _storageService.highHumidityThreshold;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isFahrenheit => _isFahrenheit;
  int get defaultInterval => _defaultInterval;
  String get targetDeviceName => _targetDeviceName;
  bool get autoReconnect => _autoReconnect;
  bool get alertsEnabled => _alertsEnabled;
  double get highTempThreshold => _highTempThreshold;
  double get lowTempThreshold => _lowTempThreshold;
  double get highHumidityThreshold => _highHumidityThreshold;

  Future<void> toggleTheme(bool dark) async {
    _isDarkMode = dark;
    await _storageService.setDarkMode(dark);
    notifyListeners();
  }

  Future<void> toggleTempUnit(bool fahrenheit) async {
    _isFahrenheit = fahrenheit;
    await _storageService.setFahrenheit(fahrenheit);
    notifyListeners();
  }

  Future<void> setDefaultInterval(int interval) async {
    _defaultInterval = interval;
    await _storageService.setDefaultInterval(interval);
    notifyListeners();
  }

  Future<void> setTargetDeviceName(String name) async {
    _targetDeviceName = name;
    await _storageService.setTargetDeviceName(name);
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool enable) async {
    _autoReconnect = enable;
    await _storageService.setAutoReconnect(enable);
    notifyListeners();
  }

  Future<void> setAlertsEnabled(bool enable) async {
    _alertsEnabled = enable;
    await _storageService.setAlertsEnabled(enable);
    notifyListeners();
  }

  Future<void> setHighTempThreshold(double val) async {
    _highTempThreshold = val;
    await _storageService.setHighTempThreshold(val);
    notifyListeners();
  }

  Future<void> setLowTempThreshold(double val) async {
    _lowTempThreshold = val;
    await _storageService.setLowTempThreshold(val);
    notifyListeners();
  }

  Future<void> setHighHumidityThreshold(double val) async {
    _highHumidityThreshold = val;
    await _storageService.setHighHumidityThreshold(val);
    notifyListeners();
  }
}

