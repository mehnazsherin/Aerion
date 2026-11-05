/// Aerion BLE GATT UUID and Protocol Configuration
/// Shared with ESP32 Firmware
class BleUuidConfig {
  BleUuidConfig._();

  /// Aerion Custom Service UUID (128-bit)
  /// Standard 128-bit UUID format: 4d61716d-0001-4b10-8000-00805f9b34fb
  static const String defaultServiceUuid = "4d61716d-0001-4b10-8000-00805f9b34fb";

  /// Temperature Characteristic UUID (Read, Notify)
  /// UTF-8 decimal string representing Celsius (e.g. "24.50" or "25.1")
  static const String defaultTemperatureCharUuid = "4d61716d-0002-4b10-8000-00805f9b34fb";

  /// Humidity Characteristic UUID (Read, Notify)
  /// UTF-8 decimal string representing Relative Humidity % (e.g. "55.20" or "60.0")
  static const String defaultHumidityCharUuid = "4d61716d-0003-4b10-8000-00805f9b34fb";

  /// Sampling Interval Characteristic UUID (Read, Write)
  /// UTF-8 integer string representing interval in seconds (e.g. "2", "5", "10")
  static const String defaultSamplingIntervalCharUuid = "4d61716d-0004-4b10-8000-00805f9b34fb";

  /// Default device name prefix for filtering Aerion devices during BLE scan
  static const String defaultDevicePrefix = "AQM-";

  /// Target device name default
  static const String defaultTargetDeviceName = "AQM-Meha";
}

