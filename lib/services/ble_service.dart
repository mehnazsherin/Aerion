import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/ble_constants.dart';
import '../models/ble_device_model.dart';
import '../models/sensor_reading.dart';

class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _tempCharacteristic;
  BluetoothCharacteristic? _humidityCharacteristic;
  BluetoothCharacteristic? _intervalCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _tempNotifySub;
  StreamSubscription<List<int>>? _humidityNotifySub;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;

  final _discoveredDevicesController = StreamController<List<BleDeviceModel>>.broadcast();
  Stream<List<BleDeviceModel>> get discoveredDevicesStream => _discoveredDevicesController.stream;

  final _connectionStateController = StreamController<AerionConnectionState>.broadcast();
  Stream<AerionConnectionState> get connectionStateStream => _connectionStateController.stream;

  final _readingsController = StreamController<SensorReading>.broadcast();
  Stream<SensorReading> get readingsStream => _readingsController.stream;

  AerionConnectionState _currentState = AerionConnectionState.disconnected;
  AerionConnectionState get currentState => _currentState;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  final Map<String, BleDeviceModel> _discoveredMap = {};
  double? _latestTemp;
  double? _latestHumidity;
  int? _configuredInterval;

  int? get configuredInterval => _configuredInterval;

  BleService() {
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on) {
        if (_currentState == AerionConnectionState.connected ||
            _currentState == AerionConnectionState.connecting) {
          disconnect();
        }
      }
    });
  }

  void _updateState(AerionConnectionState newState) {
    _currentState = newState;
    _connectionStateController.add(newState);
  }

  /// Request permissions dynamically according to OS and API levels
  Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Android 12+ (API 31+) requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      bool granted = statuses[Permission.bluetoothScan]?.isGranted == true &&
          statuses[Permission.bluetoothConnect]?.isGranted == true;

      // If Android 11 or lower, location permission is required for BLE scanning
      if (!granted) {
        var locStatus = await Permission.locationWhenInUse.request();
        granted = locStatus.isGranted;
      }
      return granted;
    } else if (Platform.isIOS) {
      var status = await Permission.bluetooth.request();
      return status.isGranted || status.isLimited;
    }
    return true;
  }

  /// Start scanning for devices with AQM- prefix or any BLE devices
  Future<void> startScan({String prefix = BleUuidConfig.defaultDevicePrefix}) async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      _updateState(AerionConnectionState.failed);
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _updateState(AerionConnectionState.disconnected);
      return;
    }

    _discoveredMap.clear();
    _discoveredDevicesController.add([]);
    _updateState(AerionConnectionState.scanning);

    try {
      await FlutterBluePlus.stopScan();

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final devName = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;

          if (devName.isNotEmpty) {
            final model = BleDeviceModel(
              device: r.device,
              name: devName,
              rssi: r.rssi,
              lastSeen: DateTime.now(),
            );
            _discoveredMap[r.device.remoteId.str] = model;
          }
        }
        _discoveredDevicesController.add(_discoveredMap.values.toList());
      });

      // Scan timeout 15 seconds
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      await FlutterBluePlus.isScanning.where((val) => val == false).first;

      if (_currentState == AerionConnectionState.scanning) {
        _updateState(AerionConnectionState.disconnected);
      }
    } catch (e) {
      if (kDebugMode) print("Error scanning BLE: $e");
      if (_currentState == AerionConnectionState.scanning) {
        _updateState(AerionConnectionState.failed);
      }
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      if (_currentState == AerionConnectionState.scanning) {
        _updateState(AerionConnectionState.disconnected);
      }
    } catch (_) {}
  }

  /// Connect to a target BLE device
  Future<bool> connect(BluetoothDevice device, {bool autoReconnect = true}) async {
    await stopScan();
    _connectedDevice = device;
    _updateState(AerionConnectionState.connecting);

    try {
      // Listen to connection state changes
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _updateState(AerionConnectionState.connected);
        } else if (state == BluetoothConnectionState.disconnected) {
          _cleanupCharacteristics();
          if (autoReconnect && _currentState == AerionConnectionState.connected) {
            _updateState(AerionConnectionState.reconnecting);
            _attemptReconnect(device);
          } else {
            _updateState(AerionConnectionState.disconnected);
          }
        }
      });

      // Connect with 10s timeout
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      // Discover GATT Services
      List<BluetoothService> services = await device.discoverServices();
      bool foundTargetService = false;

      final normalizedServiceUuid = BleUuidConfig.defaultServiceUuid.toLowerCase().replaceAll('-', '');
      final normalizedTempUuid = BleUuidConfig.defaultTemperatureCharUuid.toLowerCase().replaceAll('-', '');
      final normalizedHumidityUuid = BleUuidConfig.defaultHumidityCharUuid.toLowerCase().replaceAll('-', '');
      final normalizedIntervalUuid = BleUuidConfig.defaultSamplingIntervalCharUuid.toLowerCase().replaceAll('-', '');

      for (BluetoothService service in services) {
        final sUuid = service.uuid.str128.toLowerCase().replaceAll('-', '');
        if (sUuid == normalizedServiceUuid) {
          foundTargetService = true;
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            final cUuid = characteristic.uuid.str128.toLowerCase().replaceAll('-', '');
            if (cUuid == normalizedTempUuid) {
              _tempCharacteristic = characteristic;
            } else if (cUuid == normalizedHumidityUuid) {
              _humidityCharacteristic = characteristic;
            } else if (cUuid == normalizedIntervalUuid) {
              _intervalCharacteristic = characteristic;
            }
          }
        }
      }

      // If specific custom service UUID wasn't found, look across all services for characteristics
      if (!foundTargetService) {
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic c in service.characteristics) {
            final cUuid = c.uuid.str128.toLowerCase().replaceAll('-', '');
            if (cUuid == normalizedTempUuid) _tempCharacteristic = c;
            if (cUuid == normalizedHumidityUuid) _humidityCharacteristic = c;
            if (cUuid == normalizedIntervalUuid) _intervalCharacteristic = c;
          }
        }
      }

      await _subscribeToCharacteristics();
      await readSamplingInterval();

      _updateState(AerionConnectionState.connected);
      return true;
    } catch (e) {
      if (kDebugMode) print("Connection failure: $e");
      _updateState(AerionConnectionState.failed);
      await disconnect();
      return false;
    }
  }

  void _attemptReconnect(BluetoothDevice device) async {
    int attempts = 0;
    while (attempts < 3 && _currentState == AerionConnectionState.reconnecting) {
      attempts++;
      await Future.delayed(const Duration(seconds: 3));
      try {
        await device.connect(
          license: License.nonprofit,
          timeout: const Duration(seconds: 8),
        );
        await device.discoverServices();
        await _subscribeToCharacteristics();
        _updateState(AerionConnectionState.connected);
        return;
      } catch (_) {}
    }
    _updateState(AerionConnectionState.disconnected);
  }

  Future<void> _subscribeToCharacteristics() async {
    // Temperature notifications
    if (_tempCharacteristic != null && _tempCharacteristic!.properties.notify) {
      await _tempCharacteristic!.setNotifyValue(true);
      _tempNotifySub?.cancel();
      _tempNotifySub = _tempCharacteristic!.lastValueStream.listen((data) {
        _handleIncomingTemperature(data);
      });
      // Initial read
      try {
        final initialVal = await _tempCharacteristic!.read();
        _handleIncomingTemperature(initialVal);
      } catch (_) {}
    }

    // Humidity notifications
    if (_humidityCharacteristic != null && _humidityCharacteristic!.properties.notify) {
      await _humidityCharacteristic!.setNotifyValue(true);
      _humidityNotifySub?.cancel();
      _humidityNotifySub = _humidityCharacteristic!.lastValueStream.listen((data) {
        _handleIncomingHumidity(data);
      });
      // Initial read
      try {
        final initialVal = await _humidityCharacteristic!.read();
        _handleIncomingHumidity(initialVal);
      } catch (_) {}
    }
  }

  void _handleIncomingTemperature(List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      final str = utf8.decode(bytes).trim();
      final val = double.tryParse(str);
      if (val != null && val >= -50.0 && val <= 100.0) {
        _latestTemp = val;
        _emitReadingIfReady();
      }
    } catch (_) {}
  }

  void _handleIncomingHumidity(List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      final str = utf8.decode(bytes).trim();
      final val = double.tryParse(str);
      if (val != null && val >= 0.0 && val <= 100.0) {
        _latestHumidity = val;
        _emitReadingIfReady();
      }
    } catch (_) {}
  }

  void _emitReadingIfReady() {
    if (_latestTemp != null && _latestHumidity != null) {
      final reading = SensorReading(
        temperature: _latestTemp!,
        humidity: _latestHumidity!,
        timestamp: DateTime.now(),
        isDemo: false,
      );
      _readingsController.add(reading);
    }
  }

  Future<int?> readSamplingInterval() async {
    if (_intervalCharacteristic == null) return null;
    try {
      final bytes = await _intervalCharacteristic!.read();
      if (bytes.isNotEmpty) {
        final str = utf8.decode(bytes).trim();
        final interval = int.tryParse(str);
        if (interval != null) {
          _configuredInterval = interval;
          return interval;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> writeSamplingInterval(int seconds) async {
    if (_intervalCharacteristic == null || seconds <= 0) return false;
    try {
      final encoded = utf8.encode(seconds.toString());
      await _intervalCharacteristic!.write(encoded, withoutResponse: false);
      // Read back to confirm
      final readBack = await readSamplingInterval();
      return readBack == seconds;
    } catch (e) {
      if (kDebugMode) print("Error writing interval: $e");
      return false;
    }
  }

  Future<void> disconnect() async {
    _cleanupCharacteristics();
    _connectionStateSubscription?.cancel();
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }
    _updateState(AerionConnectionState.disconnected);
  }

  void _cleanupCharacteristics() {
    _tempNotifySub?.cancel();
    _humidityNotifySub?.cancel();
    _tempCharacteristic = null;
    _humidityCharacteristic = null;
    _intervalCharacteristic = null;
  }

  void dispose() {
    stopScan();
    disconnect();
    _adapterStateSub?.cancel();
    _discoveredDevicesController.close();
    _connectionStateController.close();
    _readingsController.close();
  }
}
