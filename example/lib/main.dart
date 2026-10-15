import 'package:current_location_helper/current_location_helper.dart';
import 'package:current_location_helper_example/widgets/fetching_overlay.dart';
import 'package:current_location_helper_example/widgets/gps_off_view.dart';
import 'package:current_location_helper_example/widgets/permission_required_view.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CurrentLocationApp());
}

class CurrentLocationApp extends StatelessWidget {
  const CurrentLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetUserLocation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008577)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver
    implements FetchLocationCallback {
  final GetLocationController _location = GetLocationController();
  String? _toast;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _location.addListener(_onLocationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _location.getLocation(this);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _location.removeListener(_onLocationChanged);
    _location.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _location.resumeAfterAppSettings();
    }
  }

  void _onLocationChanged() {
    setState(() {});
    if (_location.errorMessage != null) {
      _showMessage(_location.errorMessage!);
    }
  }

  void _showMessage(String message) {
    setState(() => _toast = message);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void getCurrentLocation(CurrentLocationData location) {
    _showMessage('Location Found');
  }

  @override
  void gpsNotEnable() {
    _showMessage('GPS not enabled');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF008577),
            foregroundColor: Colors.white,
            title: const Text('GetUserLocation'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LocationCard(
                  location: _location.lastLocation,
                  tracking: _location.tracking,
                  lastMessage: _toast,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _location.getLocation(this),
                  child: const Text('One-time location'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => _location.getLocationWithOptions(
                    callback: this,
                    continuous: true,
                    timeIntervalMs: 5000,
                  ),
                  child: const Text('Continuous (every 5s)'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => _location.getLocationWithOptions(
                    callback: this,
                    continuous: true,
                    distanceInterval: 10,
                  ),
                  child: const Text('Continuous (every 10 meters)'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonal(
                  onPressed: () => _location.getLocationWithOptions(
                    callback: this,
                    continuous: true,
                    distanceInterval: 10,
                    timeIntervalMs: 5000,
                  ),
                  child: const Text('Continuous (time + distance)'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _location.tracking
                      ? _location.stopLocationTracking
                      : null,
                  child: const Text('Stop tracking'),
                ),
              ],
            ),
          ),
        ),
        if (_location.overlay == LocationUiOverlay.permission)
          PermissionRequiredView(
            permanentlyDenied: _location.permanentlyDenied,
            onAllow: _location.onAllowPermissionPressed,
            onOpenSettings: _location.openAppPermissionSettings,
            onNotNow: _location.dismissPermissionOverlay,
          ),
        if (_location.overlay == LocationUiOverlay.gps)
          GpsOffView(
            onTurnOnGps: _location.onTurnOnGpsPressed,
            onNotNow: _location.onGpsNotNowPressed,
          ),
        if (_location.overlay == LocationUiOverlay.fetching)
          const FetchingOverlay(),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.tracking,
    required this.lastMessage,
  });

  final CurrentLocationData? location;
  final bool tracking;
  final String? lastMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location, color: Color(0xFF008577)),
                const SizedBox(width: 8),
                Text(
                  tracking ? 'Live tracking' : 'Current location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location == null)
              const Text('No location yet.')
            else ...[
              Text('Latitude:  ${location!.latitude}'),
              Text('Longitude: ${location!.longitude}'),
              Text('Accuracy:  ${location!.accuracy.toStringAsFixed(1)} m'),
            ],
            if (lastMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                lastMessage!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
