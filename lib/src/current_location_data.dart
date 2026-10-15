/// Cross-platform location payload (Android [android.location.Location] equivalent).
class CurrentLocationData {
  const CurrentLocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.altitude,
    this.speed,
    this.heading,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final double? altitude;
  final double? speed;
  final double? heading;

  @override
  String toString() {
    return 'lat=$latitude, lng=$longitude, accuracy=${accuracy}m';
  }
}
