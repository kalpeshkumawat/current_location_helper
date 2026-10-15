import 'dart:async';
import 'dart:io';

import 'package:current_location_helper/src/current_location_data.dart';
import 'package:current_location_helper/src/fetch_location_callback.dart';
import 'package:current_location_helper/src/gps_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationUiOverlay { none, permission, gps, fetching }

/// Flutter port of [GetLocationActivity] / [GetLocationFragment].
class GetLocationController extends ChangeNotifier {
  FetchLocationCallback? _callback;
  bool _continuous = false;
  double _distanceInterval = 0;
  int _timeIntervalMs = 0;
  StreamSubscription<Position>? _positionSub;
  bool _permanentlyDenied = false;

  LocationUiOverlay overlay = LocationUiOverlay.none;
  String? errorMessage;
  CurrentLocationData? lastLocation;
  bool tracking = false;

  bool get permanentlyDenied => _permanentlyDenied;

  /// One-time location (Android: `getLocation(IFetchLocation)`).
  Future<void> getLocation(FetchLocationCallback callback) {
    return getLocationWithOptions(callback: callback);
  }

  /// Continuous or one-shot with optional distance (meters) and time (ms).
  Future<void> getLocationWithOptions({
    required FetchLocationCallback callback,
    bool continuous = false,
    double distanceInterval = 0,
    int timeIntervalMs = 0,
  }) async {
    _callback = callback;
    _continuous = continuous;
    _distanceInterval = distanceInterval;
    _timeIntervalMs = timeIntervalMs;
    errorMessage = null;
    await _initFlow();
  }

  Future<void> _initFlow() async {
    final granted = await _hasFineLocationPermission();
    if (granted) {
      await _afterPermissionGranted();
      return;
    }
    _permanentlyDenied = await Permission.locationWhenInUse.isPermanentlyDenied;
    overlay = LocationUiOverlay.permission;
    notifyListeners();
  }

  Future<void> onAllowPermissionPressed() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isPermanentlyDenied) {
      _permanentlyDenied = true;
      notifyListeners();
      return;
    }

    status = await Permission.locationWhenInUse.request();
    if (status.isGranted || status.isLimited) {
      _permanentlyDenied = false;
      overlay = LocationUiOverlay.none;
      notifyListeners();
      await _afterPermissionGranted();
      return;
    }

    _permanentlyDenied = status.isPermanentlyDenied;
    notifyListeners();
  }

  Future<void> openAppPermissionSettings() async {
    await GpsSettings.openAppSettings();
  }

  Future<void> _afterPermissionGranted() async {
    if (await GpsSettings.isGpsEnabled()) {
      await _startLocationUpdates();
      return;
    }
    await enableGps();
  }

  Future<void> enableGps() async {
    if (Platform.isAndroid) {
      final enabled = await GpsSettings.requestEnableGps();
      if (enabled) {
        await _startLocationUpdates();
        return;
      }
      overlay = LocationUiOverlay.gps;
      notifyListeners();
      return;
    }

    if (await GpsSettings.isGpsEnabled()) {
      await _startLocationUpdates();
      return;
    }
    overlay = LocationUiOverlay.gps;
    notifyListeners();
  }

  Future<void> onTurnOnGpsPressed() async {
    if (Platform.isIOS) {
      await GpsSettings.openLocationSettings();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (await GpsSettings.isGpsEnabled()) {
        await _startLocationUpdates();
      }
      return;
    }
    await enableGps();
  }

  void onGpsNotNowPressed() {
    overlay = LocationUiOverlay.none;
    notifyListeners();
    _callback?.gpsNotEnable();
  }

  void dismissPermissionOverlay() {
    overlay = LocationUiOverlay.none;
    notifyListeners();
  }

  Future<void> resumeAfterAppSettings() async {
    if (overlay == LocationUiOverlay.permission) {
      if (await _hasFineLocationPermission()) {
        _permanentlyDenied = false;
        overlay = LocationUiOverlay.none;
        notifyListeners();
        await _afterPermissionGranted();
        return;
      }
      _permanentlyDenied = await Permission.locationWhenInUse.isPermanentlyDenied;
      notifyListeners();
      return;
    }

    if (overlay == LocationUiOverlay.gps && await GpsSettings.isGpsEnabled()) {
      await _startLocationUpdates();
    }
  }

  Future<void> _startLocationUpdates() async {
    overlay = LocationUiOverlay.fetching;
    notifyListeners();

    final settings = _locationSettings();

    if (_continuous) {
      tracking = true;
      await _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(locationSettings: settings).listen(
        (position) {
          overlay = LocationUiOverlay.none;
          lastLocation = _map(position);
          notifyListeners();
          _callback?.getCurrentLocation(lastLocation!);
        },
        onError: (Object error) {
          overlay = LocationUiOverlay.none;
          tracking = false;
          errorMessage = error.toString();
          notifyListeners();
        },
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 25));
      overlay = LocationUiOverlay.none;
      lastLocation = _map(position);
      notifyListeners();
      _callback?.getCurrentLocation(lastLocation!);
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      overlay = LocationUiOverlay.none;
      if (last != null) {
        lastLocation = _map(last);
        notifyListeners();
        _callback?.getCurrentLocation(lastLocation!);
      } else {
        errorMessage = 'Unable to fetch location. Please try again.';
        notifyListeners();
      }
    } catch (error) {
      overlay = LocationUiOverlay.none;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  LocationSettings _locationSettings() {
    final accuracy = LocationAccuracy.high;
    final distance = _distanceInterval > 0 ? _distanceInterval.round() : 0;
    final interval = _timeIntervalMs > 0
        ? Duration(milliseconds: _timeIntervalMs)
        : const Duration(seconds: 1);

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distance,
        intervalDuration: interval,
        forceLocationManager: false,
      );
    }

    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distance,
        activityType: ActivityType.other,
        pauseLocationUpdatesAutomatically: false,
      );
    }

    return LocationSettings(accuracy: accuracy, distanceFilter: distance);
  }

  CurrentLocationData _map(Position position) {
    return CurrentLocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
    );
  }

  Future<bool> _hasFineLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    final geo = await Geolocator.checkPermission();
    return geo == LocationPermission.always ||
        geo == LocationPermission.whileInUse;
  }

  /// Android: `stopLocationTracking()`.
  Future<void> stopLocationTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    tracking = false;
    overlay = LocationUiOverlay.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
