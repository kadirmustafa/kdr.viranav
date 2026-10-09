import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/constants/marine_constants.dart';
import 'package:viranav/core/models/vessel.dart';

class RouteLeg {
  final LatLng start;
  final LatLng end;
  final double bearingDeg;
  final double distanceNm;
  final bool isTackLeg;
  final String tackType; // 'Port Tack', 'Starboard Tack', 'Direct Course'

  const RouteLeg({
    required this.start,
    required this.end,
    required this.bearingDeg,
    required this.distanceNm,
    required this.isTackLeg,
    required this.tackType,
  });
}

class PlannedRoute {
  final List<LatLng> waypoints;
  final List<RouteLeg> legs;
  final double totalDistanceNm;
  final double estimatedTimeHours;
  final double estimatedFuelLiters;
  final bool requiresTacking;
  final double vmgKnots; // Velocity Made Good
  final double minSafeDepthMeters;

  const PlannedRoute({
    required this.waypoints,
    required this.legs,
    required this.totalDistanceNm,
    required this.estimatedTimeHours,
    required this.estimatedFuelLiters,
    required this.requiresTacking,
    required this.vmgKnots,
    required this.minSafeDepthMeters,
  });
}

class RouteEngine {
  static const Distance _distance = Distance();

  /// Calculates navigation route considering vessel type and true wind direction.
  static PlannedRoute calculateRoute({
    required LatLng departure,
    required LatLng destination,
    required Vessel vessel,
    required double trueWindDirectionDeg, // direction wind is COMING from
    required double windSpeedKnots,
  }) {
    // 1. Calculate direct bearing and distance
    final directBearing = _calculateBearing(departure, destination);
    final directDistMeters = _distance.as(LengthUnit.Meter, departure, destination);
    final directDistNm = (directDistMeters / 1000.0) * MarineConstants.kmToNm;

    // Minimum safe depth = Vessel draft + 1.5m safety margin under keel
    final minSafeDepth = vessel.draftMeters + 1.5;

    // 2. Check if direct course falls inside the No-Go Zone
    // Angular difference between direct bearing and wind direction
    final windBearingDiff = _angleDifference(directBearing, trueWindDirectionDeg);
    final inNoGoZone = vessel.isSailboat && (windBearingDiff < vessel.noGoZoneAngle);

    if (!inNoGoZone) {
      // Direct Route (Motor Yacht or Sailing Off the Wind)
      final leg = RouteLeg(
        start: departure,
        end: destination,
        bearingDeg: directBearing,
        distanceNm: directDistNm,
        isTackLeg: false,
        tackType: vessel.isSailboat ? 'Açık Rota (Free Sailing)' : 'Düz Rota (Direct)',
      );

      final speed = vessel.cruisingSpeedKnots > 0 ? vessel.cruisingSpeedKnots : 6.0;
      final eteHours = directDistNm / speed;
      final fuel = vessel.isMotorYacht
          ? (eteHours * vessel.fuelBurnLitersPerHour)
          : (eteHours * vessel.fuelBurnLitersPerHour * 0.2); // sailing uses minor engine/generator

      return PlannedRoute(
        waypoints: [departure, destination],
        legs: [leg],
        totalDistanceNm: directDistNm,
        estimatedTimeHours: eteHours,
        estimatedFuelLiters: fuel,
        requiresTacking: false,
        vmgKnots: speed,
        minSafeDepthMeters: minSafeDepth,
      );
    }

    // 3. TACKING (TRAMOLA) ROUTE GENERATION
    // Target is head-to-wind. We must beat upwind with alternating tacks.
    // Optimal close-hauled angle is typically windDirection ± (noGoZoneAngle + 3°)
    final tackAngle = vessel.noGoZoneAngle + 3.0; // e.g. 48°

    // Compute midpoint tack waypoint
    // We create a 2-leg or 3-leg zigzag upwind
    final midProgress = 0.5;
    final midLat = departure.latitude + (destination.latitude - departure.latitude) * midProgress;
    final midLon = departure.longitude + (destination.longitude - departure.longitude) * midProgress;

    // Offset the midpoint perpendicular to direct bearing by a distance proportional to track
    final perpBearing = _normalizeAngle(directBearing + 90.0);
    final lateralOffsetMeters = directDistMeters * 0.35; // lateral displacement
    final tackWaypoint = _offsetCoordinate(
      LatLng(midLat, midLon),
      perpBearing,
      lateralOffsetMeters,
    );

    final leg1DistMeters = _distance.as(LengthUnit.Meter, departure, tackWaypoint);
    final leg1DistNm = (leg1DistMeters / 1000.0) * MarineConstants.kmToNm;
    final leg1Bearing = _calculateBearing(departure, tackWaypoint);

    final leg2DistMeters = _distance.as(LengthUnit.Meter, tackWaypoint, destination);
    final leg2DistNm = (leg2DistMeters / 1000.0) * MarineConstants.kmToNm;
    final leg2Bearing = _calculateBearing(tackWaypoint, destination);

    final leg1 = RouteLeg(
      start: departure,
      end: tackWaypoint,
      bearingDeg: leg1Bearing,
      distanceNm: leg1DistNm,
      isTackLeg: true,
      tackType: 'Sancak Tramola (Starboard Tack)',
    );

    final leg2 = RouteLeg(
      start: tackWaypoint,
      end: destination,
      bearingDeg: leg2Bearing,
      distanceNm: leg2DistNm,
      isTackLeg: true,
      tackType: 'İskele Tramola (Port Tack)',
    );

    final totalTackDistNm = leg1DistNm + leg2DistNm;
    final sailSpeed = vessel.cruisingSpeedKnots;
    final eteHours = totalTackDistNm / sailSpeed;

    // VMG = BoatSpeed * cos(tackAngle relative to direct target)
    final vmg = sailSpeed * math.cos(_degToRad(tackAngle));

    return PlannedRoute(
      waypoints: [departure, tackWaypoint, destination],
      legs: [leg1, leg2],
      totalDistanceNm: totalTackDistNm,
      estimatedTimeHours: eteHours,
      estimatedFuelLiters: 0.0, // 100% wind powered
      requiresTacking: true,
      vmgKnots: vmg,
      minSafeDepthMeters: minSafeDepth,
    );
  }

  static double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = _degToRad(start.latitude);
    final lat2 = _degToRad(end.latitude);
    final dLon = _degToRad(end.longitude - start.longitude);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x);
    return (_radToDeg(bearing) + 360.0) % 360.0;
  }

  static LatLng _offsetCoordinate(LatLng origin, double bearingDeg, double distanceMeters) {
    const earthRadius = 6371000.0; // meters
    final distRad = distanceMeters / earthRadius;
    final bearingRad = _degToRad(bearingDeg);

    final lat1 = _degToRad(origin.latitude);
    final lon1 = _degToRad(origin.longitude);

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(distRad) +
          math.cos(lat1) * math.sin(distRad) * math.cos(bearingRad),
    );

    final lon2 = lon1 +
        math.atan2(
          math.sin(bearingRad) * math.sin(distRad) * math.cos(lat1),
          math.cos(distRad) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(_radToDeg(lat2), _radToDeg(lon2));
  }

  static double _angleDifference(double a1, double a2) {
    final diff = ((a1 - a2).abs()) % 360.0;
    return diff > 180.0 ? 360.0 - diff : diff;
  }

  static double _normalizeAngle(double angle) {
    return (angle % 360.0 + 360.0) % 360.0;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
