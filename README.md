# AERION – ESP32 Smart Air Monitoring System

<p align="center">
  <strong>Intelligent Air Monitoring | IoT | Embedded Systems | BLE | Flutter</strong>
</p>

<p align="center">
  A cross-platform IoT air-monitoring solution integrating ESP32 firmware, environmental sensor monitoring, Bluetooth Low Energy communication, simulation, physical hardware validation and a Flutter mobile application.
</p>

---

## 1. Project Overview

**Aerion** is an ESP32-based smart air-monitoring system designed to collect environmental sensor readings, process the data using embedded firmware and make the readings accessible through Bluetooth Low Energy (BLE).

The project combines embedded systems programming, sensor integration, wireless communication and cross-platform mobile application development.

The system is developed around three major components:

1. **ESP32 Firmware:** Collects sensor readings through I2C, processes the measurements and manages BLE communication.
2. **Wokwi Simulation and Physical Hardware:** Provides a simulated development environment and additional validation using connected ESP32 hardware and sensors.
3. **Flutter Mobile Application:** Provides a mobile interface for connecting to the ESP32, monitoring sensor values and interacting with the monitoring system.

The objective is to build a reliable, modular and extensible air-monitoring platform that can be used across iOS and Android devices.

## 2. Project Objectives

- Develop ESP32 firmware using C/C++ and the Arduino framework.
- Establish I2C communication between the ESP32 and an environmental sensor.
- Read temperature measurements from the connected sensor.
- Generate simulated humidity readings where physical humidity sensing is unavailable.
- Implement a moving average filter to reduce fluctuations in sensor readings.
- Implement Bluetooth Low Energy communication using a custom GATT service.
- Support configurable sensor sampling intervals.
- Develop and validate the firmware through Wokwi simulation.
- Connect and test the system using physical ESP32 hardware.
- Develop a cross-platform Flutter mobile application for iOS and Android.
- Establish communication between the mobile application and ESP32 through BLE.

## 3. System Architecture

The Aerion system follows a layered architecture.

```text
             ENVIRONMENT
                  |
                  v
          I2C SENSOR MODULE
                  |
                  v
              ESP32 MCU
                  |
          SENSOR DATA READING
                  |
                  v
          DATA PROCESSING
          - Temperature
          - Humidity
          - Moving Average
                  |
                  v
            BLE GATT SERVICE
                  |
          Bluetooth Low Energy
                  |
          +-------+-------+
          |               |
          v               v
      iOS APP         ANDROID APP
          |               |
          +-------+-------+
                  |
                  v
          AERION DASHBOARD
          - Live Readings
          - Device Status
          - Monitoring Controls
          - Sensor Analytics
```

The ESP32 acts as the sensor-processing and BLE communication device. The Flutter application acts as the user-facing monitoring interface.

## 4. Hardware Components

The hardware implementation uses an ESP32 microcontroller and an I2C-connected sensor.

| Component | Purpose |
|---|---|
| ESP32 development board | Main microcontroller |
| I2C sensor | Temperature measurement |
| USB cable / power supply | Power and programming |
| Jumper wires | Hardware connections |
| Mobile device | BLE monitoring and testing |

### I2C Communication

The ESP32 communicates with the sensor using the I2C protocol.

For the MPU6050-based Wokwi configuration, the connections are:

| MPU6050 Pin | ESP32 Pin |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SDA | GPIO 21 |
| SCL | GPIO 22 |

The I2C communication is implemented using the Arduino `Wire` library.

**Note:** The MPU6050 is the sensor specified in the simulation assignment. Record the actual sensor model used in your physical hardware setup separately if it differs.

### Physical Hardware Validation

In addition to simulation, the firmware was tested with physically connected ESP32 hardware and sensor components.

The physical testing process included:

- Connecting the ESP32 to the sensor.
- Establishing the required I2C connections.
- Uploading and executing the firmware.
- Checking sensor communication.
- Observing temperature readings.
- Verifying the system's response during operation.

This additional hardware validation complements the software simulation and helps identify issues that may not be visible in a simulated environment.

## 5. Wokwi Simulation

Wokwi was used as the virtual hardware development and testing environment for the software implementation.

**Simulation platform:** https://wokwi.com/

### Simulation Configuration

- ESP32 Arduino development board.
- MPU6050 sensor.
- I2C communication using SDA and SCL.
- Arduino C/C++ firmware.
- Serial Monitor for command-based testing.

### Simulation Workflow

1. Create an ESP32 Arduino project in Wokwi.
2. Add the MPU6050 sensor.
3. Connect the sensor to the ESP32 I2C pins.
4. Implement sensor communication using `Wire.h`.
5. Read temperature from the MPU6050 temperature registers.
6. Generate humidity values through a clearly identified simulated humidity function.
7. Apply the moving average filter.
8. Implement the Serial Monitor command interface.
9. Test the configured sampling interval.
10. Observe automatic sensor readings.

### BLE Simulation Configuration

The BLE implementation is included in the firmware behind a compile-time switch:

```cpp
#define ENABLE_BLE 0
```

This allows the simulation to execute the sensor and Serial Monitor functionality without requiring BLE functionality from the simulator.

For physical ESP32 BLE testing, the firmware must be compiled with BLE enabled:

```cpp
#define ENABLE_BLE 1
```

The BLE implementation must be tested on compatible physical hardware.

**Wokwi Project Link:** [Add your public Wokwi project URL here]

## 6. ESP32 Firmware Implementation

The firmware is developed using C/C++ with the Arduino framework.

### 6.1 Sensor Communication

The ESP32 communicates with the I2C sensor using:

```cpp
#include <Wire.h>
```

The firmware initializes the I2C interface and reads the sensor's temperature register.

For the MPU6050, the temperature output registers are:

| Register | Address |
|---|---|
| TEMP_OUT_H | 0x41 |
| TEMP_OUT_L | 0x42 |

The raw temperature value is converted into a temperature measurement using the MPU6050 temperature conversion formula:

```text
Temperature (°C) = Raw Temperature / 340 + 36.53
```

### 6.2 Humidity Simulation

Where a physical humidity sensor is unavailable, humidity is generated using a dedicated function:

```cpp
readSimulatedHumidity()
```

This keeps humidity processing separate from physical sensor communication.

Simulated humidity values must be clearly distinguished from actual hardware measurements.

### 6.3 Sampling Interval

The initial sampling interval is two seconds.

The firmware periodically collects temperature and humidity readings.

The sampling interval can be modified dynamically through the configured BLE characteristic or Serial Monitor command interface.

### 6.4 Moving Average Filter

A moving average filter is implemented using the last five sensor samples.

The purpose is to reduce sudden fluctuations and produce smoother measurements.

Formula:

```text
Moving Average = (X1 + X2 + X3 + X4 + X5) / 5
```

Where X1 to X5 represent the latest five sensor readings.

The filter is applied independently to temperature and humidity.

### 6.5 Serial Monitor Interface

For simulation and firmware testing, the following commands are implemented:

| Command | Expected Behaviour |
|---|---|
| `GET TEMP` | Displays filtered temperature |
| `GET HUM` | Displays filtered humidity |
| `SET INTERVAL <seconds>` | Changes the sampling interval |

Sensor readings are also printed automatically at each configured interval.

Example:

```text
AERION AIR MONITORING SYSTEM

Temperature: 28.45 °C
Humidity: 62.00 %

Sampling Interval: 2 seconds

GET TEMP
Filtered Temperature: 28.45 °C

GET HUM
Filtered Humidity: 62.00 %

SET INTERVAL 5
Sampling Interval Updated: 5 seconds
```

The values above are illustrative output, not recorded test measurements.

## 7. Bluetooth Low Energy (BLE) Communication

BLE enables wireless communication between the ESP32 and the Aerion mobile application.

The ESP32 advertises using the configured device naming convention:

```text
AQM-<YourFirstName>
```

Example:

```text
AQM-Meha
```

### GATT Service Architecture

The firmware exposes one custom 128-bit BLE service.

The service contains three characteristics.

| Characteristic | Properties | Purpose |
|---|---|---|
| Temperature | Read + Notify | Retrieve temperature and receive automatic updates |
| Humidity | Read + Notify | Retrieve humidity and receive automatic updates |
| Sampling Interval | Read + Write | Retrieve and modify the sensor sampling interval |

### BLE Communication Workflow

1. ESP32 initializes its BLE stack.
2. The custom GATT service is registered.
3. Temperature, humidity and sampling interval characteristics are created.
4. The ESP32 starts advertising.
5. The mobile application scans for nearby Aerion devices.
6. The application connects to the selected ESP32.
7. The application discovers the GATT service and characteristics.
8. The application reads sensor values and subscribes to notifications.
9. Updated sensor readings are delivered through BLE notifications.
10. The application writes a new sampling interval when requested.

### UUID Configuration

All BLE UUIDs must be consistent between the ESP32 firmware and Flutter application.

| BLE Element | UUID |
|---|---|
| Custom Service | [Insert actual 128-bit service UUID] |
| Temperature | [Insert actual characteristic UUID] |
| Humidity | [Insert actual characteristic UUID] |
| Sampling Interval | [Insert actual characteristic UUID] |

The UUID values must be copied from the actual firmware implementation before final submission.

### Data Format

The mobile application and ESP32 firmware must use the same documented data encoding.

For example, UTF-8 decimal strings can be used for initial implementation:

```text
Temperature: 28.45
Humidity: 62.00
Sampling Interval: 5
```

The actual encoding should match the implemented firmware.

## 8. Aerion Flutter Mobile Application

The Aerion mobile application provides a user-friendly interface for interacting with the ESP32 air-monitoring system.

The application is developed using Flutter and Dart, allowing a shared codebase for iOS and Android.

### Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Application programming language |
| Bluetooth Low Energy | ESP32 communication |
| ESP32 | Sensor data processing |
| I2C | Sensor communication |
| Arduino Framework | Embedded firmware |
| Wokwi | Hardware simulation |
| Xcode | iOS development and deployment |
| Android SDK | Android development |

### Mobile Application Features

The mobile application is designed around the following modules:

**1. Dashboard**

Provides an overview of the monitoring system, including temperature, humidity, connection status and recent readings where supported by the implementation.

**2. Bluetooth Device Management**

Allows the user to discover nearby BLE devices, identify Aerion devices, connect and disconnect, and monitor connection status.

**3. Live Sensor Monitoring**

Displays temperature and humidity values received from the ESP32.

**4. Sampling Interval Controls**

Allows the user to configure the sensor sampling interval through the BLE write characteristic.

**5. Analytics**

Provides a visual representation of available sensor readings and historical trends, subject to the application's implemented data storage functionality.

**6. Settings**

Provides application preferences and device-related configuration options where implemented.

### iOS Support

The application is configured for iOS development using Xcode.

Development and deployment were performed using:

- MacBook Air with Apple Silicon M4.
- Flutter 3.47.9.
- Xcode 27.2.
- CocoaPods 1.17.0.
- iPhone 17 running iOS 26.5.

The application was successfully built and installed on the connected iPhone using Flutter and Xcode signing.

For local development, a Personal Team Apple account can be used for device signing.

### Android Support

The Flutter project includes Android platform configuration.

The application is intended to support Android devices with compatible BLE hardware and operating system permissions.

Android build and physical-device testing should be completed using a compatible JDK and Android SDK configuration.

## 9. Project Directory Structure

```text
Aerion/
│
├── android/
│   └── Android-specific configuration
│
├── ios/
│   └── iOS-specific configuration
│
├── lib/
│   └── Flutter application source code
│
├── test/
│   └── Application tests
│
├── esp32_firmware/
│   └── ESP32 embedded firmware
│
├── pubspec.yaml
│   └── Flutter dependencies and configuration
│
├── pubspec.lock
│   └── Resolved dependency versions
│
├── analysis_options.yaml
│   └── Dart analysis configuration
│
└── README.md
    └── Project documentation
```

## 10. Installation and Setup

### Prerequisites

- Flutter SDK.
- Dart SDK.
- Arduino IDE or compatible firmware development environment.
- ESP32 development board.
- Compatible I2C sensor.
- Xcode for iOS development.
- Android Studio and Android SDK for Android development.
- Git and GitHub.

### Clone the Repository

```bash
git clone https://github.com/mehnazsherin/Aerion.git
```

Navigate to the project:

```bash
cd Aerion
```

### Install Flutter Dependencies

```bash
flutter pub get
```

### Check Flutter Environment

```bash
flutter doctor -v
```

### Run on a Connected Device

```bash
flutter devices
```

For iOS:

```bash
flutter run -d <iphone-device-id>
```

For Android:

```bash
flutter run -d <android-device-id>
```

### Build Android APK

```bash
flutter build apk --release
```

### Build iOS Application

```bash
flutter build ios --release
```

iOS deployment requires appropriate Xcode signing configuration.

## 11. Testing and Validation

Testing is divided into three areas.

### A. Simulation Testing

Wokwi is used to validate:

- ESP32 initialization.
- I2C sensor communication.
- Temperature register reading.
- Simulated humidity generation.
- Moving average calculations.
- Configurable sampling intervals.
- Serial Monitor commands.
- Automatic periodic output.

### B. Physical Hardware Testing

Physical ESP32 hardware was connected and checked as part of the hardware validation process.

The testing workflow covers:

- Hardware connections.
- Sensor communication.
- Firmware execution.
- Sensor readings.
- Sampling behaviour.
- BLE functionality when enabled.
- Communication with compatible mobile devices.

Record the actual sensor model, board version and test evidence alongside your submission.

### C. Mobile Application Testing

The Flutter application is configured and built for iOS.

The iPhone 17 was detected by Flutter and the iOS application was successfully compiled and installed using Xcode development signing.

The following areas form the mobile testing checklist:

- BLE permissions.
- BLE scanning.
- Device discovery.
- ESP32 connection.
- GATT service discovery.
- Temperature and humidity notifications.
- Sampling interval updates.
- Connection and disconnection handling.
- Android compatibility.

Only mark individual test cases as passed after verifying them on the corresponding device.

## 12. Expected System Behaviour

When the system is running:

1. The ESP32 initializes its I2C interface.
2. The sensor provides temperature measurements.
3. Humidity is obtained from a physical sensor or the simulated humidity function, depending on the configuration.
4. The firmware collects samples at the configured interval.
5. The moving average filter processes the latest five readings.
6. The processed values are made available through the configured BLE characteristics.
7. The mobile application connects to the ESP32.
8. The mobile application receives and displays available sensor readings.
9. The user can modify the sampling interval through the mobile interface.

## 13. Limitations

- Humidity values are simulated when a physical humidity sensor is not available.
- BLE communication in the Wokwi simulation is disabled through the compile-time switch.
- Physical BLE testing requires a compatible ESP32 board.
- Sensor accuracy depends on the connected sensor and its operating conditions.
- The mobile application's available functionality depends on the corresponding firmware characteristics.
- Historical analytics require local data storage and sufficient recorded readings.
- Android and iOS platform permissions must be configured correctly.
- Device battery information requires a corresponding hardware measurement or BLE characteristic.

## 14. Future Enhancements

Potential improvements include:

- Integration of dedicated temperature and humidity sensors such as BME280, SHT31 or AHT20.
- Additional environmental parameters.
- Real-time threshold-based alerts.
- Persistent historical sensor data.
- Exporting readings to CSV.
- Cloud-based monitoring and remote access.
- Multiple ESP32 device management.
- Improved BLE reconnection mechanisms.
- Advanced analytics and visualization.
- Background monitoring where supported by the platform.
- Device battery monitoring where supported by the hardware.

## 15. AI Tools and Development Assistance

AI-assisted development tools were used to support selected development activities.

The use of AI tools may include:

- Understanding technical requirements.
- Exploring ESP32 firmware implementation.
- Troubleshooting Flutter and Xcode configuration.
- Reviewing BLE communication concepts.
- Improving documentation.
- Debugging and resolving development issues.

All generated or suggested code must be reviewed, tested and understood before being included in the final project.

The final AI usage note should identify the actual tools, prompts and modifications used during development.

## 16. Assignment Requirement Mapping

| Assignment Requirement | Aerion Implementation |
|---|---|
| C/C++ Arduino framework | ESP32 firmware |
| I2C sensor communication | MPU6050-based simulation configuration |
| Temperature reading | I2C temperature register |
| Humidity reading | Simulated humidity function where applicable |
| Two-second sampling | Configurable sampling system |
| Five-sample moving average | Sensor data filtering |
| Custom BLE GATT service | ESP32 BLE implementation |
| Temperature Read + Notify | Temperature characteristic |
| Humidity Read + Notify | Humidity characteristic |
| Sampling interval Read + Write | Configurable BLE characteristic |
| Wokwi simulation | Virtual ESP32 development |
| Serial command interface | GET TEMP, GET HUM, SET INTERVAL |
| Physical hardware validation | ESP32 and sensor testing |
| Flutter mobile application | iOS and Android client |

## 17. Project Deliverables

- ESP32 firmware source code.
- Wokwi simulation project.
- Physical hardware implementation and testing.
- Flutter mobile application source code.
- iOS platform configuration.
- Android platform configuration.
- BLE GATT implementation.
- Technical documentation.
- Testing and validation evidence.

## 18. Developer Information

**Project Name:** Aerion – ESP32 Smart Air Monitoring System

**Developer:** Mehnaz Sherin Z

**Domain:** Internet of Things (IoT), Embedded Systems and Mobile Application Development

**Primary Technologies:** ESP32, C/C++, Arduino, Flutter, Dart, Bluetooth Low Energy, I2C and Wokwi.

**GitHub Repository:** https://github.com/mehnazsherin/Aerion

---

<p align="center">
  <strong>AERION</strong><br>
  Intelligent Air Monitoring
</p>

<p align="center">
  Bringing embedded intelligence and connected mobile experiences together.
</p>