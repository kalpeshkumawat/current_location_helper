import 'package:geolocator/geolocator.dart';

/// Helpers for checking device location services and opening settings.
///
/// For cross-platform compatibility this class does not force-enable GPS.
/// Android and iOS require the user to enable location services themselves.
class GpsSettings {
  GpsSettings._();

  static Future<bool> isGpsEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Opens the device's location settings page.
  static Future<bool> requestEnableGps() async {
    await Geolocator.openLocationSettings();
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
