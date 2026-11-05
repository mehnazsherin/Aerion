import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device_model.dart';
import '../models/sensor_reading.dart';
import '../services/ble_service.dart';
import '../services/storage_service.dart';

class BleProvider extends ChangeNotifier {
  final BleService _bleService;
  final StorageService _storageService;

  List<BleDeviceModel> _discoveredDevices = [];
  AerionConnectionState _connectionState = AerionConnectionState.disconnected;
  String? _errorMessage;

  StreamSubscription<List<BleDeviceModel>>? _devicesSub;
  StreamSubscription<AerionConnectionState>? _stateSub;

  List<BleDeviceModel> get discoveredDevices => _discoveredDevices;
  AerionConnectionState get connectionState => _connectionState;
  String? get errorMessage => _errorMessage;
  BluetoothDevice? get connectedDevice => _bleService.connectedDevice;
  int? get configuredInterval => _bleService.configuredInterval;

  bool get isConnected => _connectionState == AerionConnectionState.connected;
  bool get isScanning => _connectionState == AerionConnectionState.scanning;

  BleProvider(this._bleService, this._storageService) {
    _devicesSub = _bleService.discoveredDevicesStream.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });

    _stateSub = _bleService.connectionStateStream.listen((state) {
      _connectionState = state;
      if (state == AerionConnectionState.connected && _bleService.connectedDevice != null) {
        _storageService.setLastConnectedDeviceId(_bleService.connectedDevice!.remoteId.str);
      }
      notifyListeners();
    });
  }

  Stream<SensorReading> get readingsStream => _bleService.readingsStream;

  Future<void> startScan() async {
    _errorMessage = null;
    await _bleService.startScan(prefix: _storageService.targetDeviceName);
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
  }

  Future<bool> connect(BluetoothDevice device) async {
    _errorMessage = null;
    final success = await _bleService.connect(
      device,
      autoReconnect: _storageService.autoReconnect,
    );
    if (!success) {
      _errorMessage = "Connection to ${device.platformName.isNotEmpty ? device.platformName : 'device'} failed.";
      notifyListeners();
    }
    return success;
  }

  Future<void> disconnect() async {
    await _bleService.disconnect();
  }

  Future<bool> updateSamplingInterval(int seconds) async {
    final success = await _bleService.writeSamplingInterval(seconds);
    if (success) {
      await _storageService.setDefaultInterval(seconds);
      notifyListeners();
    }
    return success;
  }

  Future<int?> refreshSamplingInterval() async {
    final val = await _bleService.readSamplingInterval();
    if (val != null) {
      notifyListeners();
    }
    return val;
  }

  @override
  void dispose() {
    _devicesSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }
}

