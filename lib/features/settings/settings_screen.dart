import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/aerion_theme.dart';
import '../../providers/sensor_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final sensorProvider = context.watch<SensorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Preferences"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Mode Banner
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sensorProvider.isDemoMode
                          ? AerionColors.amberWarning.withOpacity(0.15)
                          : AerionColors.cyanAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      sensorProvider.isDemoMode
                          ? Icons.science_outlined
                          : Icons.bluetooth_connected_rounded,
                      color: sensorProvider.isDemoMode
                          ? AerionColors.amberWarning
                          : AerionColors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensorProvider.isDemoMode ? "Demo Mode Active" : "Production Mode",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sensorProvider.isDemoMode
                              ? "Simulating telemetry for evaluation"
                              : "Operating against genuine BLE hardware",
                          style: const TextStyle(fontSize: 12, color: AerionColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (sensorProvider.isDemoMode) {
                        sensorProvider.disableDemoMode();
                      } else {
                        sensorProvider.enableDemoMode();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sensorProvider.isDemoMode
                          ? AerionColors.darkBackground
                          : AerionColors.amberWarning,
                      foregroundColor: sensorProvider.isDemoMode ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      sensorProvider.isDemoMode ? "Exit Demo" : "Try Demo",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Display Preferences
            _sectionHeader("DISPLAY & UNITS"),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Dark Theme"),
                    subtitle: const Text("Optimized OLED dark aesthetic"),
                    value: settingsProvider.isDarkMode,
                    activeColor: AerionColors.cyanAccent,
                    onChanged: (val) => settingsProvider.toggleTheme(val),
                  ),
                  const Divider(height: 1, color: AerionColors.darkCardBorder),
                  SwitchListTile(
                    title: const Text("Fahrenheit Unit (°F)"),
                    subtitle: const Text("Show telemetry in °F instead of °C"),
                    value: settingsProvider.isFahrenheit,
                    activeColor: AerionColors.cyanAccent,
                    onChanged: (val) => settingsProvider.toggleTempUnit(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BLE Connection Preferences
            _sectionHeader("BLE CONNECTIVITY"),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Auto-Reconnect"),
                    subtitle: const Text("Attempt automatic re-link upon signal drop"),
                    value: settingsProvider.autoReconnect,
                    activeColor: AerionColors.cyanAccent,
                    onChanged: (val) => settingsProvider.setAutoReconnect(val),
                  ),
                  const Divider(height: 1, color: AerionColors.darkCardBorder),
                  ListTile(
                    title: const Text("Default Target Device"),
                    subtitle: Text(settingsProvider.targetDeviceName),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => _showEditDeviceDialog(context, settingsProvider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Threshold Alerts
            _sectionHeader("ENVIRONMENTAL ALERTS"),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Enable Threshold Alerts"),
                    subtitle: const Text("Send local alerts when metrics exceed safety caps"),
                    value: settingsProvider.alertsEnabled,
                    activeColor: AerionColors.cyanAccent,
                    onChanged: (val) => settingsProvider.setAlertsEnabled(val),
                  ),
                  const Divider(height: 1, color: AerionColors.darkCardBorder),
                  ListTile(
                    title: const Text("High Temperature Threshold"),
                    subtitle: Text("${settingsProvider.highTempThreshold}°C"),
                    trailing: const Icon(Icons.tune_rounded, size: 18),
                    onTap: () => _showSliderDialog(
                      context,
                      title: "High Temperature Threshold (°C)",
                      currentVal: settingsProvider.highTempThreshold,
                      min: 25.0,
                      max: 45.0,
                      onChanged: (v) => settingsProvider.setHighTempThreshold(v),
                    ),
                  ),
                  const Divider(height: 1, color: AerionColors.darkCardBorder),
                  ListTile(
                    title: const Text("High Humidity Threshold"),
                    subtitle: Text("${settingsProvider.highHumidityThreshold}%"),
                    trailing: const Icon(Icons.tune_rounded, size: 18),
                    onTap: () => _showSliderDialog(
                      context,
                      title: "High Humidity Threshold (%)",
                      currentVal: settingsProvider.highHumidityThreshold,
                      min: 50.0,
                      max: 95.0,
                      onChanged: (v) => settingsProvider.setHighHumidityThreshold(v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Retention
            _sectionHeader("DATA MANAGEMENT"),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AerionColors.crimsonAlert),
                title: const Text(
                  "Clear Stored History",
                  style: TextStyle(color: AerionColors.crimsonAlert, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Deletes all locally saved telemetry records"),
                onTap: () async {
                  await sensorProvider.clearHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Telemetry history cleared.")),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            // About AERION
            Center(
              child: Column(
                children: [
                  const Text(
                    "AERION IoT v1.0.0",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AerionColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Intelligent Air Monitoring Platform",
                    style: TextStyle(fontSize: 11, color: AerionColors.textMutedDark),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AerionColors.textMutedDark,
        ),
      ),
    );
  }

  void _showEditDeviceDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.targetDeviceName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Target Device Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. AQM-Meha"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.setTargetDeviceName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSliderDialog(
    BuildContext context, {
    required String title,
    required double currentVal,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    double tempVal = currentVal;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tempVal.toStringAsFixed(1), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Slider(
                value: tempVal,
                min: min,
                max: max,
                divisions: (max - min).toInt() * 2,
                activeColor: AerionColors.cyanAccent,
                onChanged: (v) {
                  setDialogState(() => tempVal = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(double.parse(tempVal.toStringAsFixed(1)));
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
