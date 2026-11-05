import 'package:flutter/material.dart';
import '../../core/theme/aerion_theme.dart';
import '../../models/ble_device_model.dart';
import 'glass_card.dart';

class ConnectionCard extends StatelessWidget {
  final AerionConnectionState state;
  final String? deviceName;
  final int? rssi;
  final DateTime? lastUpdate;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;
  final bool isDemo;

  const ConnectionCard({
    super.key,
    required this.state,
    this.deviceName,
    this.rssi,
    this.lastUpdate,
    required this.onConnectTap,
    required this.onDisconnectTap,
    this.isDemo = false,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == AerionConnectionState.connected;
    final isConnecting = state == AerionConnectionState.connecting ||
        state == AerionConnectionState.reconnecting;
    final isScanning = state == AerionConnectionState.scanning;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isDemo) {
      statusColor = AerionColors.amberWarning;
      statusText = "DEMO SIMULATION ACTIVE";
      statusIcon = Icons.science_outlined;
    } else {
      switch (state) {
        case AerionConnectionState.connected:
          statusColor = AerionColors.emeraldGreen;
          statusText = "CONNECTED (LIVE BLE)";
          statusIcon = Icons.bluetooth_connected_rounded;
          break;
        case AerionConnectionState.connecting:
          statusColor = AerionColors.cyanAccent;
          statusText = "CONNECTING...";
          statusIcon = Icons.bluetooth_searching_rounded;
          break;
        case AerionConnectionState.reconnecting:
          statusColor = AerionColors.amberWarning;
          statusText = "RECONNECTING...";
          statusIcon = Icons.sync_rounded;
          break;
        case AerionConnectionState.scanning:
          statusColor = AerionColors.electricBlue;
          statusText = "SCANNING FOR ESP32...";
          statusIcon = Icons.radar_rounded;
          break;
        case AerionConnectionState.failed:
          statusColor = AerionColors.crimsonAlert;
          statusText = "CONNECTION FAILED";
          statusIcon = Icons.error_outline_rounded;
          break;
        case AerionConnectionState.disconnected:
          statusColor = AerionColors.textMutedDark;
          statusText = "DISCONNECTED";
          statusIcon = Icons.bluetooth_disabled_rounded;
          break;
      }
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isDemo
                          ? "Virtual ESP32 Simulator"
                          : (isConnected ? (deviceName ?? "ESP32 Monitor") : "No Device Paired"),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isConnected || isDemo)
                OutlinedButton(
                  onPressed: onDisconnectTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AerionColors.crimsonAlert),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    "Disconnect",
                    style: TextStyle(color: AerionColors.crimsonAlert, fontSize: 12),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: isConnecting || isScanning ? null : onConnectTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AerionColors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    isConnecting ? "Connecting" : "Pair",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          if (isConnected || isDemo) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AerionColors.darkCardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.signal_cellular_alt_rounded, size: 14, color: AerionColors.textMutedDark),
                    const SizedBox(width: 4),
                    Text(
                      rssi != null ? "$rssi dBm" : (isDemo ? "-58 dBm" : "N/A"),
                      style: const TextStyle(fontSize: 12, color: AerionColors.textSecondaryDark),
                    ),
                  ],
                ),
                Text(
                  lastUpdate != null
                      ? "Updated: ${lastUpdate!.hour.toString().padLeft(2, '0')}:${lastUpdate!.minute.toString().padLeft(2, '0')}:${lastUpdate!.second.toString().padLeft(2, '0')}"
                      : (isDemo ? "Live Stream" : "Awaiting data"),
                  style: const TextStyle(fontSize: 11, color: AerionColors.textMutedDark),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
