import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/aerion_theme.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/controls/controls_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/devices/devices_screen.dart';
import 'features/settings/settings_screen.dart';
import 'providers/ble_provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/settings_provider.dart';
import 'services/ble_service.dart';
import 'services/storage_service.dart';

class AerionApp extends StatelessWidget {
  final StorageService storageService;
  final BleService bleService;

  const AerionApp({
    super.key,
    required this.storageService,
    required this.bleService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, BleProvider>(
          create: (_) => BleProvider(bleService, storageService),
          update: (_, settings, ble) => ble ?? BleProvider(bleService, storageService),
        ),
        ChangeNotifierProxyProvider2<BleProvider, SettingsProvider, SensorProvider>(
          create: (ctx) => SensorProvider(
            ctx.read<BleProvider>(),
            storageService,
            ctx.read<SettingsProvider>(),
          ),
          update: (_, ble, settings, sensor) =>
              sensor ?? SensorProvider(ble, storageService, settings),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'AERION',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AerionTheme.lightTheme,
            darkTheme: AerionTheme.darkTheme,
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DevicesScreen(),
    AnalyticsScreen(),
    ControlsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AerionColors.darkCardBorder : AerionColors.lightCardBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: isDark ? AerionColors.darkSurface : AerionColors.lightSurface,
          indicatorColor: AerionColors.cyanAccent.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AerionColors.cyanAccent),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bluetooth_searching_outlined),
              selectedIcon: Icon(Icons.bluetooth_searching_rounded, color: AerionColors.cyanAccent),
              label: 'Devices',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded, color: AerionColors.cyanAccent),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded, color: AerionColors.cyanAccent),
              label: 'Controls',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: AerionColors.cyanAccent),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
