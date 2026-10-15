import 'package:flutter_test/flutter_test.dart';
import 'package:current_location_helper/current_location_helper.dart';

void main() {
  test('CurrentLocationData stores coordinate fields', () {
    final timestamp = DateTime.utc(2026, 1, 1);
    final location = CurrentLocationData(
      latitude: 26.8,
      longitude: 75.7,
      accuracy: 5.0,
      timestamp: timestamp,
      altitude: 300,
      speed: 0,
      heading: 0,
    );

    expect(location.latitude, 26.8);
    expect(location.longitude, 75.7);
    expect(location.accuracy, 5.0);
    expect(location.timestamp, timestamp);
  });
}
