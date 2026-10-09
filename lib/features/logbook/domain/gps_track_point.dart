class GpsTrackPoint {
  final int? id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double speedKnots; // SOG
  final double courseDeg; // COG
  final double? altitude;
  final DateTime timestamp;

  const GpsTrackPoint({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.courseDeg,
    this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed_knots': speedKnots,
      'course_deg': courseDeg,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GpsTrackPoint.fromMap(Map<String, dynamic> map) {
    return GpsTrackPoint(
      id: map['id'] as int?,
      tripId: map['trip_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      speedKnots: (map['speed_knots'] as num).toDouble(),
      courseDeg: (map['course_deg'] as num).toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
