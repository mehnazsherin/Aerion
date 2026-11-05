import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/aerion_theme.dart';
import '../../models/sensor_reading.dart';
import '../../providers/sensor_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/glass_card.dart';

enum AnalyticsTimeframe { oneHour, sixHours, oneDay, sevenDays }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsTimeframe _timeframe = AnalyticsTimeframe.oneHour;

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isFahrenheit = settingsProvider.isFahrenheit;

    // Filter points by chosen timeframe
    final now = DateTime.now();
    Duration limit;
    switch (_timeframe) {
      case AnalyticsTimeframe.oneHour:
        limit = const Duration(hours: 1);
        break;
      case AnalyticsTimeframe.sixHours:
        limit = const Duration(hours: 6);
        break;
      case AnalyticsTimeframe.oneDay:
        limit = const Duration(days: 1);
        break;
      case AnalyticsTimeframe.sevenDays:
        limit = const Duration(days: 7);
        break;
    }

    final filtered = sensorProvider.history
        .where((r) => now.difference(r.timestamp) <= limit)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Analytics"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeframe Segmented Control
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTimeframeChip("1 Hour", AnalyticsTimeframe.oneHour),
                    const SizedBox(width: 8),
                    _buildTimeframeChip("6 Hours", AnalyticsTimeframe.sixHours),
                    const SizedBox(width: 8),
                    _buildTimeframeChip("24 Hours", AnalyticsTimeframe.oneDay),
                    const SizedBox(width: 8),
                    _buildTimeframeChip("7 Days", AnalyticsTimeframe.sevenDays),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.query_stats_rounded,
                          size: 50,
                          color: AerionColors.textMutedDark.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No History For This Period",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Keep the device connected to accumulate telemetry or switch to Demo Mode to view simulated trend charts.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AerionColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Statistics Summary Row
                _buildSummaryStats(filtered, isFahrenheit),
                const SizedBox(height: 20),

                // Temperature Chart
                _buildChartCard(
                  title: "Temperature (${isFahrenheit ? '°F' : '°C'})",
                  icon: Icons.thermostat_rounded,
                  color: const Color(0xFFFF7A00),
                  spots: _generateTempSpots(filtered, isFahrenheit),
                  minY: isFahrenheit ? 40 : 10,
                  maxY: isFahrenheit ? 110 : 45,
                ),
                const SizedBox(height: 20),

                // Humidity Chart
                _buildChartCard(
                  title: "Humidity (%)",
                  icon: Icons.water_drop_rounded,
                  color: AerionColors.cyanAccent,
                  spots: _generateHumiditySpots(filtered),
                  minY: 0,
                  maxY: 100,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeChip(String label, AnalyticsTimeframe timeframe) {
    final isSelected = _timeframe == timeframe;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _timeframe = timeframe),
      selectedColor: AerionColors.cyanAccent,
      backgroundColor: AerionColors.darkCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AerionColors.textSecondaryDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSummaryStats(List<SensorReading> readings, bool isFahrenheit) {
    final temps = readings.map((r) => isFahrenheit ? r.temperatureFahrenheit : r.temperature).toList();
    final hums = readings.map((r) => r.humidity).toList();

    final minT = temps.reduce((a, b) => a < b ? a : b);
    final maxT = temps.reduce((a, b) => a > b ? a : b);
    final avgT = temps.reduce((a, b) => a + b) / temps.length;

    final minH = hums.reduce((a, b) => a < b ? a : b);
    final maxH = hums.reduce((a, b) => a > b ? a : b);
    final avgH = hums.reduce((a, b) => a + b) / hums.length;

    final unit = isFahrenheit ? "°F" : "°C";

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("MIN TEMP", "${minT.toStringAsFixed(1)}$unit"),
              _statItem("AVG TEMP", "${avgT.toStringAsFixed(1)}$unit"),
              _statItem("MAX TEMP", "${maxT.toStringAsFixed(1)}$unit"),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AerionColors.darkCardBorder),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("MIN HUM", "${minH.toStringAsFixed(1)}%"),
              _statItem("AVG HUM", "${avgH.toStringAsFixed(1)}%"),
              _statItem("MAX HUM", "${maxH.toStringAsFixed(1)}%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AerionColors.textMutedDark, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<FlSpot> spots,
    required double minY,
    required double maxY,
  }) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: AerionColors.textMutedDark),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "#${value.toInt()}",
                          style: const TextStyle(fontSize: 10, color: AerionColors.textMutedDark),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateTempSpots(List<SensorReading> readings, bool isFahrenheit) {
    return List.generate(readings.length, (i) {
      final r = readings[i];
      final val = isFahrenheit ? r.temperatureFahrenheit : r.temperature;
      return FlSpot(i.toDouble(), val);
    });
  }

  List<FlSpot> _generateHumiditySpots(List<SensorReading> readings) {
    return List.generate(readings.length, (i) {
      return FlSpot(i.toDouble(), readings[i].humidity);
    });
  }
}
