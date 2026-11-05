import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/ble_constants.dart';
import '../../core/theme/aerion_theme.dart';
import '../../models/ble_device_model.dart';
import '../../providers/ble_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/glass_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _filterAerionOnly = true;

  @override
  void initState() {
    super.initState();
    // Auto scan when opening screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ble = context.read<BleProvider>();
      if (!ble.isScanning && !ble.isConnected) {
        ble.startScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = context.watch<BleProvider>();
    final sensorProvider = context.watch<SensorProvider>();

    final allDevices = bleProvider.discoveredDevices;
    final filteredDevices = _filterAerionOnly
        ? allDevices.where((d) => d.name.toUpperCase().startsWith(BleUuidConfig.defaultDevicePrefix)).toList()
        : allDevices;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Discovery"),
        actions: [
          IconButton(
            icon: Icon(
              bleProvider.isScanning ? Icons.stop_rounded : Icons.refresh_rounded,
              color: AerionColors.cyanAccent,
            ),
            onPressed: () {
              if (bleProvider.isScanning) {
                bleProvider.stopScan();
              } else {
                bleProvider.startScan();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Filter Switch
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (bleProvider.isScanning)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AerionColors.cyanAccent,
                            ),
                          )
                        else
                          Icon(
                            bleProvider.isConnected
                                ? Icons.bluetooth_connected_rounded
                                : Icons.bluetooth_rounded,
                            size: 18,
                            color: bleProvider.isConnected
                                ? AerionColors.emeraldGreen
                                : AerionColors.textMutedDark,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          bleProvider.isScanning
                              ? "Scanning for BLE..."
                              : (bleProvider.isConnected ? "Connected" : "Scan stopped"),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "AQM only",
                          style: TextStyle(fontSize: 12, color: AerionColors.textSecondaryDark),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _filterAerionOnly,
                            activeColor: AerionColors.cyanAccent,
                            onChanged: (val) {
                              setState(() => _filterAerionOnly = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (bleProvider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AerionColors.crimsonAlert.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AerionColors.crimsonAlert, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AerionColors.crimsonAlert, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bleProvider.errorMessage!,
                          style: const TextStyle(color: AerionColors.crimsonAlert, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Discovered Devices Header
              Text(
                "DISCOVERED SENSORS (${filteredDevices.length})",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AerionColors.textMutedDark,
                ),
              ),
              const SizedBox(height: 10),

              // Device List or Empty View
              Expanded(
                child: filteredDevices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              bleProvider.isScanning
                                  ? Icons.radar_rounded
                                  : Icons.bluetooth_searching_rounded,
                              size: 50,
                              color: AerionColors.textMutedDark.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              bleProvider.isScanning
                                  ? "Searching for Aerion ESP32..."
                                  : "No Aerion devices in range",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Ensure your ESP32 monitor is powered on and advertising with 'AQM-' prefix.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AerionColors.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => bleProvider.startScan(),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text("Scan Again"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AerionColors.cyanAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredDevices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final device = filteredDevices[index];
                          final isCurrentlyConnected =
                              bleProvider.connectedDevice?.remoteId.str == device.id;

                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AerionColors.cyanAccent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.developer_board_rounded,
                                    color: AerionColors.cyanAccent,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${device.id} • ${device.rssi} dBm",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AerionColors.textMutedDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentlyConnected)
                                  ElevatedButton(
                                    onPressed: () => bleProvider.disconnect(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AerionColors.crimsonAlert,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Disconnect", style: TextStyle(fontSize: 12)),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: bleProvider.connectionState == AerionConnectionState.connecting
                                        ? null
                                        : () async {
                                            if (sensorProvider.isDemoMode) {
                                              sensorProvider.disableDemoMode();
                                            }
                                            final success = await bleProvider.connect(device.device);
                                            if (success && context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AerionColors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Connect", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
