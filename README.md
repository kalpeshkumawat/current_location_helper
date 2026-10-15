# current_location_helper

A Flutter package for retrieving a one-time location or listening to continuous location updates. It includes permission-state handling and helpers for opening app/location settings. The package does not force GPS on; the user must enable location services in device settings.

## Installation

```bash
flutter pub add current_location_helper
```

## Basic usage

```dart
import 'package:current_location_helper/current_location_helper.dart';

class MyLocationHandler implements FetchLocationCallback {
  @override
  void getCurrentLocation(CurrentLocationData location) {
    print('${location.latitude}, ${location.longitude}');
  }

  @override
  void gpsNotEnable() {
    print('Location services are not enabled.');
  }
}

final controller = GetLocationController();
final handler = MyLocationHandler();

// One-time location:
await controller.getLocation(handler);

// Continuous updates every ~5 seconds on supported platforms:
await controller.getLocationWithOptions(
  callback: handler,
  continuous: true,
  timeIntervalMs: 5000,
);

// Continuous updates after movement (distance in meters):
await controller.getLocationWithOptions(
  callback: handler,
  continuous: true,
  distanceInterval: 10,
);

// Stop updates and dispose when no longer needed:
await controller.stopLocationTracking();
controller.dispose();
```

## Permission and platform setup

### Android

Add these permissions above the `<application>` element in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### iOS

Add a user-facing purpose string to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Explain why your app needs the user's location.</string>
```

For iOS, enable location permission support in `permission_handler` according to its current installation guide. Background location is not implemented by this package.

## API

- `GetLocationController.getLocation(callback)` retrieves one location.
- `GetLocationController.getLocationWithOptions(...)` starts a one-time request or continuous updates.
- `GetLocationController.stopLocationTracking()` stops the stream.
- `GetLocationController.resumeAfterAppSettings()` rechecks permission/service state after returning from settings.
- `CurrentLocationData` contains latitude, longitude, accuracy, timestamp, altitude, speed and heading.
- `LocationUiOverlay` describes permission, GPS and fetching UI states. The package does not render those screens itself; consumers may build their own UI based on controller state.

## Important notes

- This package requests foreground/while-in-use location permission only.
- On iOS, the app cannot programmatically switch Location Services on. The user must do this in Settings.
- Continuous updates may be throttled by the operating system and are not guaranteed to arrive at exact intervals.
- Dispose the controller when the owning screen/service is finished.

## Development

From the package root:

```bash
flutter pub get
flutter analyze
flutter test
dart pub publish --dry-run
```

## License

Choose and add a license before publishing. Do not publish until you have replaced the example repository URLs with your own project URL.
