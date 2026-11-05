import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/ble_constants.dart';
import '../../core/theme/aerion_theme.dart';
import '../../providers/ble_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/glass_card.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  final TextEditingController _customIntervalController = TextEditingController();
  bool _isUpdating = false;

  final List<int> _presetIntervals = [2, 5, 10, 15, 30];

  @override
  void dispose() {
    _customIntervalController.dispose();
    super.dispose();
  }

  Future<void> _updateInterval(int seconds) async {
    final bleProvider = context.read<BleProvider>();
    final sensorProvider = context.read<SensorProvider>();

    if (sensorProvider.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Demo Mode active: virtual interval adjusted to $seconds seconds."),
          backgroundColor: AerionColors.amberWarning,
        ),
      );
      return;
    }

    if (!bleProvider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot change interval: No ESP32 connected via BLE."),
          backgroundColor: AerionColors.crimsonAlert,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final success = await bleProvider.updateSamplingInterval(seconds);

    setState(() => _isUpdating = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sampling interval successfully set to $seconds seconds."),
            backgroundColor: AerionColors.emeraldGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ESP32 rejected or failed to acknowledge the interval update."),
            backgroundColor: AerionColors.crimsonAlert,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();
    final sensorProvider = context.watch<SensorProvider>();

    final currentInterval = bleProvider.configuredInterval ?? 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Controls"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AerionColors.cyanAccent),
            onPressed: bleProvider.isConnected
                ? () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final res = await bleProvider.refreshSamplingInterval();
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Refreshed interval from device: ${res ?? 'N/A'}s"),
                        ),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interval Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, color: AerionColors.cyanAccent, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Telemetry Sampling Interval",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Current device reporting rate: $currentInterval seconds",
                      style: const TextStyle(fontSize: 13, color: AerionColors.textSecondaryDark),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "PRESET INTERVALS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AerionColors.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetIntervals.map((sec) {
                        final isSelected = currentInterval == sec;
                        return ElevatedButton(
                          onPressed: _isUpdating ? null : () => _updateInterval(sec),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AerionColors.cyanAccent
                                : AerionColors.darkBackground,
                            foregroundColor: isSelected ? Colors.black : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AerionColors.cyanAccent
                                  : AerionColors.darkCardBorder,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("${sec}s", style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "CUSTOM INTERVAL",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AerionColors.textMutedDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customIntervalController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter seconds (1 - 300)",
                              hintStyle: const TextStyle(fontSize: 13, color: AerionColors.textMutedDark),
                              filled: true,
                              fillColor: AerionColors.darkBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AerionColors.darkCardBorder),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isUpdating
                              ? null
                              : () {
                                  final val = int.tryParse(_customIntervalController.text.trim());
                                  if (val != null && val >= 1 && val <= 300) {
                                    _updateInterval(val);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Interval must be between 1 and 300 seconds."),
                                        backgroundColor: AerionColors.amberWarning,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AerionColors.cyanAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Device Details Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AerionColors.electricBlue, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Hardware Protocol Status",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _infoRow("Service UUID", BleUuidConfig.defaultServiceUuid),
                    const SizedBox(height: 8),
                    _infoRow("Temp Char UUID", BleUuidConfig.defaultTemperatureCharUuid),
                    const SizedBox(height: 8),
                    _infoRow("Humidity Char UUID", BleUuidConfig.defaultHumidityCharUuid),
                    const SizedBox(height: 8),
                    _infoRow("Interval Char UUID", BleUuidConfig.defaultSamplingIntervalCharUuid),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AerionColors.darkCardBorder),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Active Link State:",
                          style: TextStyle(fontSize: 13, color: AerionColors.textSecondaryDark),
                        ),
                        Text(
                          sensorProvider.isDemoMode
                              ? "VIRTUAL_DEMO"
                              : (bleProvider.isConnected ? "GATT_ACTIVE" : "DISCONNECTED"),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: bleProvider.isConnected
                                ? AerionColors.emeraldGreen
                                : (sensorProvider.isDemoMode ? AerionColors.amberWarning : AerionColors.textMutedDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AerionColors.textMutedDark, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: AerionColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}
