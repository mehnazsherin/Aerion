import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/aerion_theme.dart';
import '../../providers/ble_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/connection_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/sensor_metric_card.dart';
import '../devices/devices_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();
    final sensorProvider = context.watch<SensorProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final reading = sensorProvider.latestReading;
    final isFahrenheit = settingsProvider.isFahrenheit;

    final tempVal = reading != null
        ? (isFahrenheit ? reading.temperatureFahrenheit : reading.temperature)
        : 0.0;
    final tempUnit = isFahrenheit ? "°F" : "°C";

    final humVal = reading?.humidity ?? 0.0;

    String tempStatus;
    Color tempStatusColor;
    if (reading == null) {
      tempStatus = "NO DATA";
      tempStatusColor = AerionColors.textMutedDark;
    } else if (reading.temperature < 18) {
      tempStatus = "COOL";
      tempStatusColor = AerionColors.cyanAccent;
    } else if (reading.temperature <= 26) {
      tempStatus = "OPTIMAL";
      tempStatusColor = AerionColors.emeraldGreen;
    } else {
      tempStatus = "HIGH";
      tempStatusColor = AerionColors.amberWarning;
    }

    String humStatus;
    Color humStatusColor;
    if (reading == null) {
      humStatus = "NO DATA";
      humStatusColor = AerionColors.textMutedDark;
    } else if (reading.humidity < 35) {
      humStatus = "DRY";
      humStatusColor = AerionColors.amberWarning;
    } else if (reading.humidity <= 60) {
      humStatus = "COMFORT";
      humStatusColor = AerionColors.emeraldGreen;
    } else {
      humStatus = "HUMID";
      humStatusColor = AerionColors.cyanAccent;
    }

    final dateFormat = DateFormat('EEEE, MMM d • HH:mm');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (bleProvider.isConnected) {
              await bleProvider.refreshSamplingInterval();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AerionColors.primaryGradient,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "AERION",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AerionColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (sensorProvider.isDemoMode)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AerionColors.amberWarning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AerionColors.amberWarning, width: 1),
                            ),
                            child: const Text(
                              "DEMO",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AerionColors.amberWarning,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Threshold alerts are active and running in background."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Connection Card
                ConnectionCard(
                  state: bleProvider.connectionState,
                  deviceName: bleProvider.connectedDevice?.platformName.isNotEmpty == true
                      ? bleProvider.connectedDevice!.platformName
                      : null,
                  lastUpdate: reading?.timestamp,
                  isDemo: sensorProvider.isDemoMode,
                  onConnectTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DevicesScreen()),
                    );
                  },
                  onDisconnectTap: () {
                    if (sensorProvider.isDemoMode) {
                      sensorProvider.disableDemoMode();
                    } else {
                      bleProvider.disconnect();
                    }
                  },
                ),
                const SizedBox(height: 22),

                // Live Sensor Metrics Section
                const Text(
                  "LIVE TELEMETRY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AerionColors.textMutedDark,
                  ),
                ),
                const SizedBox(height: 12),

                if (reading == null && !bleProvider.isConnected && !sensorProvider.isDemoMode) ...[
                  // Meaningful Empty State
                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sensors_off_rounded,
                            size: 48,
                            color: AerionColors.textMutedDark.withOpacity(0.6),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "No Sensor Connected",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Connect to your ESP32 monitor via BLE or launch Demo Mode to test the telemetry interface.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AerionColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.bluetooth_searching, size: 16),
                                label: const Text("Scan for Device"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const DevicesScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AerionColors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.play_circle_outline, size: 16),
                                label: const Text("Launch Demo"),
                                onPressed: () {
                                  sensorProvider.enableDemoMode();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AerionColors.cyanAccent),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Cards for Temperature and Humidity
                  Row(
                    children: [
                      Expanded(
                        child: SensorMetricCard(
                          title: "Temperature",
                          value: tempVal,
                          unit: tempUnit,
                          min: isFahrenheit ? 32 : 0,
                          max: isFahrenheit ? 122 : 50,
                          recordedMin: isFahrenheit
                              ? (sensorProvider.minTemperature * 9 / 5 + 32)
                              : sensorProvider.minTemperature,
                          recordedMax: isFahrenheit
                              ? (sensorProvider.maxTemperature * 9 / 5 + 32)
                              : sensorProvider.maxTemperature,
                          gradientColors: const [Color(0xFFFF7A00), Color(0xFFFF0055)],
                          icon: Icons.thermostat_rounded,
                          status: tempStatus,
                          statusColor: tempStatusColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SensorMetricCard(
                          title: "Humidity",
                          value: humVal,
                          unit: "%",
                          min: 0,
                          max: 100,
                          recordedMin: sensorProvider.minHumidity,
                          recordedMax: sensorProvider.maxHumidity,
                          gradientColors: const [Color(0xFF00E5FF), Color(0xFF0284C7)],
                          icon: Icons.water_drop_rounded,
                          status: humStatus,
                          statusColor: humStatusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity / Last 5 readings
                  const Text(
                    "RECENT SAMPLES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AerionColors.textMutedDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        ...sensorProvider.history.reversed.take(5).map((r) {
                          final t = isFahrenheit ? r.temperatureFahrenheit : r.temperature;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: AerionColors.cyanAccent),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('HH:mm:ss').format(r.timestamp),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AerionColors.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${t.toStringAsFixed(1)}$tempUnit",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      "${r.humidity.toStringAsFixed(1)}%",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AerionColors.cyanAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

