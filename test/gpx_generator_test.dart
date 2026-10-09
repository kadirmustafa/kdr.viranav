import 'package:flutter_test/flutter_test.dart';
import 'package:viranav/features/logbook/domain/trip.dart';
import 'package:viranav/features/logbook/domain/gps_track_point.dart';
import 'package:viranav/features/logbook/domain/gpx_generator.dart';

void main() {
  group('GpxGenerator Tests', () {
    test('generateGpx produces valid GPX 1.1 with track points and metadata', () {
      final trip = Trip(
        id: 'test_trip_123',
        title: 'Bodrum - Kos Test Seyri',
        startTime: DateTime.utc(2026, 10, 9, 10, 0),
        endTime: DateTime.utc(2026, 10, 9, 14, 0),
        totalDistanceNm: 12.5,
        maxSpeedKnots: 8.2,
        avgSpeedKnots: 5.6,
        vesselName: 'Vira 40',
      );

      final points = [
        GpsTrackPoint(
          tripId: trip.id,
          latitude: 36.985,
          longitude: 27.350,
          speedKnots: 5.4,
          courseDeg: 210.0,
          timestamp: DateTime.utc(2026, 10, 9, 10, 5),
        ),
        GpsTrackPoint(
          tripId: trip.id,
          latitude: 36.950,
          longitude: 27.300,
          speedKnots: 6.8,
          courseDeg: 215.0,
          timestamp: DateTime.utc(2026, 10, 9, 10, 10),
        ),
      ];

      final gpx = GpxGenerator.generateGpx(trip: trip, points: points);

      expect(gpx, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('<gpx version="1.1"'));
      expect(gpx, contains('creator="ViraNav Marine Navigation'));
      expect(gpx, contains('<name>Bodrum - Kos Test Seyri</name>'));
      expect(gpx, contains('lat="36.9850000" lon="27.3500000"'));
      expect(gpx, contains('lat="36.9500000" lon="27.3000000"'));
      expect(gpx, contains('<speed_knots>5.4</speed_knots>'));
      expect(gpx, contains('<course_cog>210.0</course_cog>'));
    });
  });
}
