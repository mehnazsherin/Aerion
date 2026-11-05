# AERION – Cross-Platform IoT Air Monitoring Application

**Tagline:** Intelligent Air Monitoring  
**Target Platforms:** iOS (including iPhone 17 & Dynamic Island) and Android (API 21+ to modern Android 15/16).  
**Hardware Target:** ESP32 Microcontroller with BLE (AQM-Meha).

---

## 1. System Architecture & Features

AERION is built following clean mobile architecture, separating presentation, business logic, BLE communication, and local persistence.

- **Presentation:** Material 3 Dark/Light futuristic theme, Glassmorphic telemetry cards, animated circular gauges (`CustomPainter`), smooth tab switching.
- **State Management:** `Provider` with reactive change notifiers (`BleProvider`, `SensorProvider`, `SettingsProvider`).
- **BLE Service Layer:** Dedicated `BleService` encapsulating `flutter_blue_plus`, handling adapter states, continuous scanning, GATT service discovery, UTF-8 characteristic parsing, and controlled auto-reconnection.
- **Analytics:** Interactive trend charts and statistics (Min, Max, Average) powered by `fl_chart`.
- **Bidirectional Control:** User-configurable sampling intervals (2s, 5s, 10s, 15s, 30s, or custom) written to the ESP32 sampling interval characteristic and verified via read-back.
- **Local Alerts & Notifications:** Configurable safety thresholds with anti-spam cooldown timers via `flutter_local_notifications`.
- **Strict Demo Mode Separation:** Built-in virtual ESP32 simulator for testing UI, alerts, and graphs without mixing fake data into persistent storage.

---

## 2. BLE GATT Protocol Specification

| Characteristic / Service | UUID | Properties | Format / Encoding |
|---|---|---|---|
| **Aerion Service** | `4d61716d-0001-4b10-8000-00805f9b34fb` | Primary Service | 128-bit custom GATT service |
| **Temperature** | `4d61716d-0002-4b10-8000-00805f9b34fb` | READ, NOTIFY | UTF-8 decimal string in °C (e.g., `"24.5"`) |
| **Humidity** | `4d61716d-0003-4b10-8000-00805f9b34fb` | READ, NOTIFY | UTF-8 decimal string in % (e.g., `"55.2"`) |
| **Sampling Interval** | `4d61716d-0004-4b10-8000-00805f9b34fb` | READ, WRITE | UTF-8 integer string in seconds (e.g., `"5"`) |

*Default Device Advertising Name:* `AQM-Meha` (Prefix: `AQM-`)

---

## 3. Platform Configuration & Permissions

### Android
Configured in `android/app/src/main/AndroidManifest.xml` and `android/app/build.gradle.kts`:
- Android 12+ (API 31+): `BLUETOOTH_SCAN` (`neverForLocation`), `BLUETOOTH_CONNECT`.
- Android 11 & lower: `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`.
- Android 13+ (API 33+): `POST_NOTIFICATIONS`.
- `minSdkVersion = 21` (required for BLE).

### iOS
Configured in `ios/Runner/Info.plist`:
- `NSBluetoothAlwaysUsageDescription`: Explains BLE connection to air monitoring sensors.
- `NSBluetoothPeripheralUsageDescription`: Peripheral interaction permission.
- Native safe area handling for Dynamic Island and home indicators.

---

## 4. How to Flash the ESP32 Firmware

1. Install the Arduino IDE or PlatformIO.
2. Install the **esp32 by Espressif Systems** board package.
3. Open `esp32_firmware/aerion_esp32_ble.ino`.
4. Select your board (e.g., `ESP32 Dev Module`) and COM port.
5. Upload the sketch. Open the Serial Monitor at `115200` baud.
6. The ESP32 will output:
   ```
   Starting AERION ESP32 BLE Server...
   >> AERION ESP32 is advertising as AQM-Meha
   ```

---

## 5. How to Run & Test

### Running Unit Tests
```bash
flutter test
```

### Testing on an Android Phone
1. Enable **Developer Options** and **USB Debugging** on your Android device.
2. Connect your phone via USB:
   ```bash
   adb devices
   ```
3. Install Java JDK 17+ on macOS if running local Gradle builds:
   ```bash
   brew install openjdk@17
   ```
4. Run the app:
   ```bash
   flutter run -d <your-android-device-id>
   ```

### Testing on iPhone (including iPhone 17) via Xcode
1. Install Xcode from the Mac App Store and set command line tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   cd ios && pod install && cd ..
   ```
3. Connect your physical iPhone via USB/Wi-Fi.
4. Open `ios/Runner.xcworkspace` in Xcode.
5. In Xcode, navigate to `Runner` > `Signing & Capabilities` and select your personal Apple Developer Team.
6. Select your physical iPhone as the destination target and click **Run** (or `flutter run -d <iphone-device-id>`).

---

## 6. Known Limitations
- Background scanning is intentionally omitted to conserve user battery and respect Apple/Google app store guidelines.
- Requires JDK 17+ on the host Mac to assemble Android APK binaries.
# Aerion
