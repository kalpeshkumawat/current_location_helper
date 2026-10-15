import 'package:current_location_helper/src/current_location_data.dart';

/// Mirrors Android [IFetchLocation].
abstract class FetchLocationCallback {
  void getCurrentLocation(CurrentLocationData location);

  void gpsNotEnable();
}
