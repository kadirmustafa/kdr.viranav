import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/constants/marine_constants.dart';
import 'package:viranav/core/services/database_service.dart';
import 'package:viranav/features/logbook/domain/trip.dart';
import 'package:viranav/features/logbook/domain/gps_track_point.dart';
import 'package:viranav/features/logbook/domain/gpx_generator.dart';

class TripRepository {
  final DatabaseService _dbService;

  TripRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  Future<void> createTrip(Trip trip) async {
    await _dbService.insertTrip(trip);
  }

  Future<void> logPoint(GpsTrackPoint point) async {
    await _dbService.insertPoint(point);
  }

  Future<Trip?> getTrip(String id) async {
    return await _dbService.getTrip(id);
  }

  Future<List<Trip>> getAllTrips() async {
    return await _dbService.getAllTrips();
  }

  Future<List<GpsTrackPoint>> getTripPoints(String tripId) async {
    return await _dbService.getPointsForTrip(tripId);
  }

  Future<void> deleteTrip(String tripId) async {
    await _dbService.deleteTrip(tripId);
  }

  /// Concludes the active voyage, aggregates stats, generates GPX,
  /// and uploads to Cloudflare R2 + Firestore summary (Zero-cost architecture).
  Future<Trip> finishTrip(String tripId) async {
    final trip = await _dbService.getTrip(tripId);
    if (trip == null) {
      throw Exception('Trip $tripId not found');
    }

    final points = await _dbService.getPointsForTrip(tripId);

    // Calculate distance, max speed, avg speed
    double totalDistanceKm = 0.0;
    double maxSpeed = 0.0;
    double speedSum = 0.0;
    final distanceCalc = const Distance();

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.speedKnots > maxSpeed) maxSpeed = p.speedKnots;
      speedSum += p.speedKnots;

      if (i > 0) {
        final prev = points[i - 1];
        final distMeters = distanceCalc.as(
          LengthUnit.Meter,
          LatLng(prev.latitude, prev.longitude),
          LatLng(p.latitude, p.longitude),
        );
        totalDistanceKm += (distMeters / 1000.0);
      }
    }

    final totalDistanceNm = totalDistanceKm * MarineConstants.kmToNm;
    final avgSpeed = points.isNotEmpty ? speedSum / points.length : 0.0;

    final updatedTrip = trip.copyWith(
      endTime: DateTime.now(),
      totalDistanceNm: totalDistanceNm,
      maxSpeedKnots: maxSpeed,
      avgSpeedKnots: avgSpeed,
      totalPointsCount: points.length,
    );

    await _dbService.updateTrip(updatedTrip);

    // Generate GPX string
    final gpxXml = GpxGenerator.generateGpx(trip: updatedTrip, points: points);

    // Upload to Cloudflare R2 Worker endpoint (Zero cost Spark/R2 tier)
    // Non-blocking with 3s timeout so offline/slow connections never freeze the finish flow
    try {
      final workerUrl = dotenv.env['CLOUDFLARE_WORKER_URL'] ??
          'https://marine-api.viranav.workers.dev';
      final response = await http.post(
        Uri.parse('$workerUrl/api/trips/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tripId': updatedTrip.id,
          'gpx': gpxXml,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final finalized = updatedTrip.copyWith(
          isSynced: true,
          gpxCloudKey: body['key'] ?? 'trips/${updatedTrip.id}.gpx',
        );
        await _dbService.updateTrip(finalized);
        return finalized;
      }
    } catch (_) {
      // Offline / network failure: safely retained in local SQLite for later sync
    }

    return updatedTrip;
  }

  /// Exports GPX to temporary file and triggers system share sheet.
  Future<void> shareGpx(String tripId) async {
    final trip = await _dbService.getTrip(tripId);
    if (trip == null) return;

    final points = await _dbService.getPointsForTrip(tripId);
    final gpxXml = GpxGenerator.generateGpx(trip: trip, points: points);

    final tempDir = await getTemporaryDirectory();
    final fileName = 'viranav_${trip.title.replaceAll(' ', '_')}_${trip.id.substring(0, 6)}.gpx';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(gpxXml);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'ViraNav Seyir Kaydı: ${trip.title} (${trip.totalDistanceNm.toStringAsFixed(1)} NM)',
      ),
    );
  }
}
