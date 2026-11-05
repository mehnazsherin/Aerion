import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum AerionConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  reconnecting,
  failed,
}

class BleDeviceModel {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final DateTime lastSeen;

  const BleDeviceModel({
    required this.device,
    required this.name,
    required this.rssi,
    required this.lastSeen,
  });

  String get id => device.remoteId.str;

  BleDeviceModel copyWith({
    BluetoothDevice? device,
    String? name,
    int? rssi,
    DateTime? lastSeen,
  }) {
    return BleDeviceModel(
      device: device ?? this.device,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

