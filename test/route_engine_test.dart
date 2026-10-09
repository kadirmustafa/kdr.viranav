import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/models/vessel.dart';
import 'package:viranav/features/navigation/domain/route_engine.dart';

void main() {
  group('RouteEngine Tacking & Weather Routing Tests', () {
    final departure = const LatLng(36.985, 27.350); // Bodrum
    // Target due north (bearing ~0°)
    final destNorth = const LatLng(37.150, 27.350);
    // Target due south (bearing ~180°)
    final destSouth = const LatLng(36.800, 27.350);

    test('Sailboat sailing directly into true wind (No-Go Zone) generates tacking legs', () {
      final sailboat = Vessel.defaultSailboat();
      // True wind coming from North (0°)
      const trueWindDir = 0.0;
      const windSpeed = 15.0;

      final route = RouteEngine.calculateRoute(
        departure: departure,
        destination: destNorth, // trying to sail North into North wind
        vessel: sailboat,
        trueWindDirectionDeg: trueWindDir,
        windSpeedKnots: windSpeed,
      );

      expect(route.requiresTacking, isTrue);
      expect(route.legs.length, greaterThanOrEqualTo(2));
      expect(route.waypoints.length, greaterThanOrEqualTo(3));
      expect(route.estimatedFuelLiters, equals(0.0)); // Sailboat uses wind
      expect(route.minSafeDepthMeters, equals(sailboat.draftMeters + 1.5));
    });

    test('Sailboat sailing downwind does not require tacking (direct route)', () {
      final sailboat = Vessel.defaultSailboat();
      // True wind coming from North (0°), sailing South (180°)
      const trueWindDir = 0.0;
      const windSpeed = 15.0;

      final route = RouteEngine.calculateRoute(
        departure: departure,
        destination: destSouth,
        vessel: sailboat,
        trueWindDirectionDeg: trueWindDir,
        windSpeedKnots: windSpeed,
      );

      expect(route.requiresTacking, isFalse);
      expect(route.legs.length, equals(1));
    });

    test('Motor Yacht always generates direct route regardless of wind direction', () {
      final motorYacht = Vessel.defaultMotorYacht();
      const trueWindDir = 0.0; // North wind
      const windSpeed = 25.0;

      final route = RouteEngine.calculateRoute(
        departure: departure,
        destination: destNorth, // heading into wind
        vessel: motorYacht,
        trueWindDirectionDeg: trueWindDir,
        windSpeedKnots: windSpeed,
      );

      expect(route.requiresTacking, isFalse);
      expect(route.legs.length, equals(1));
      expect(route.estimatedFuelLiters, greaterThan(0.0));
      expect(route.minSafeDepthMeters, equals(motorYacht.draftMeters + 1.5));
    });
  });
}
