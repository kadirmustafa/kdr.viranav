import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:viranav/core/constants/marine_constants.dart';
import 'package:viranav/features/logbook/domain/gps_track_point.dart';
import 'package:viranav/features/logbook/domain/trip.dart';
import 'package:viranav/features/logbook/data/trip_repository.dart';

class TrackingState {
  final bool isTracking;
  final Trip? currentTrip;
  final Position? lastPosition;
  final double currentSogKnots; // Speed Over Ground
  final double currentCogDeg; // Course Over Ground
  final int pointsLogged;

  const TrackingState({
    required this.isTracking,
    this.currentTrip,
    this.lastPosition,
    this.currentSogKnots = 0.0,
    this.currentCogDeg = 0.0,
    this.pointsLogged = 0,
  });

  TrackingState copyWith({
    bool? isTracking,
    Trip? currentTrip,
    Position? lastPosition,
    double? currentSogKnots,
    double? currentCogDeg,
    int? pointsLogged,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentTrip: currentTrip ?? this.currentTrip,
      lastPosition: lastPosition ?? this.lastPosition,
      currentSogKnots: currentSogKnots ?? this.currentSogKnots,
      currentCogDeg: currentCogDeg ?? this.currentCogDeg,
      pointsLogged: pointsLogged ?? this.pointsLogged,
    );
  }
}

class TrackingService {
  final TripRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _fiveSecondTimer;

  TrackingState _state = const TrackingState(isTracking: false);
  final _stateController = StreamController<TrackingState>.broadcast();

  TrackingService({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  Stream<TrackingState> get stateStream => _stateController.stream;
  TrackingState get currentState => _state;

  Position? _pendingPosition;

  Future<bool> checkAndRequestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return false;
    }
  }

  Future<void> startTrip({
    required String tripId,
    required String title,
    required String vesselName,
  }) async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception('Konum izni verilmedi / Location permission not granted');
    }

    final newTrip = Trip(
      id: tripId,
      title: title,
      startTime: DateTime.now(),
      vesselName: vesselName,
    );

    await _repository.createTrip(newTrip);

    // Get current position immediately if available
    try {
      final initialPos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              timeLimit: Duration(seconds: 3),
            ),
          );
      _pendingPosition = initialPos;
      final initialPoint = GpsTrackPoint(
        tripId: newTrip.id,
        latitude: initialPos.latitude,
        longitude: initialPos.longitude,
        speedKnots: (initialPos.speed >= 0 ? initialPos.speed : 0.0) * MarineConstants.mpsToKnots,
        courseDeg: initialPos.heading >= 0 ? initialPos.heading : 0.0,
        altitude: initialPos.altitude,
        timestamp: DateTime.now(),
      );
      await _repository.logPoint(initialPoint);
    } catch (_) {}

    _state = _state.copyWith(
      isTracking: true,
      currentTrip: newTrip,
      pointsLogged: _pendingPosition != null ? 1 : 0,
      lastPosition: _pendingPosition,
    );
    _stateController.add(_state);

    // High accuracy location stream with distance filter
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // meters
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      final sogKnots = (position.speed >= 0 ? position.speed : 0.0) *
          MarineConstants.mpsToKnots;
      final cogDeg = position.heading >= 0 ? position.heading : 0.0;

      _pendingPosition = position;
      _state = _state.copyWith(
        lastPosition: position,
        currentSogKnots: sogKnots,
        currentCogDeg: cogDeg,
      );
      _stateController.add(_state);
    }, onError: (e) {
      debugPrint('GPS Stream Error: $e');
    });

    // 5-second interval offline DB recorder
    _fiveSecondTimer?.cancel();
    _fiveSecondTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_state.isTracking && _pendingPosition != null) {
        final pos = _pendingPosition!;
        final sog = (pos.speed >= 0 ? pos.speed : 0.0) * MarineConstants.mpsToKnots;
        final cog = pos.heading >= 0 ? pos.heading : 0.0;

        final pt = GpsTrackPoint(
          tripId: newTrip.id,
          latitude: pos.latitude,
          longitude: pos.longitude,
          speedKnots: sog,
          courseDeg: cog,
          altitude: pos.altitude,
          timestamp: DateTime.now(),
        );

        try {
          await _repository.logPoint(pt);
          _state = _state.copyWith(
            pointsLogged: _state.pointsLogged + 1,
          );
          _stateController.add(_state);
        } catch (e) {
          debugPrint('Error logging GPS point: $e');
        }
      }
    });
  }

  /// Stops voyage recording reliably.
  /// Immediate state update ensures UI exits tracking mode deterministically.
  Future<Trip?> stopTrip() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    _fiveSecondTimer?.cancel();
    _fiveSecondTimer = null;

    final activeTrip = _state.currentTrip;

    // Immediately reflect stopped state in UI
    _state = TrackingState(
      isTracking: false,
      lastPosition: _state.lastPosition,
      currentTrip: null,
      pointsLogged: 0,
      currentSogKnots: 0.0,
      currentCogDeg: _state.currentCogDeg,
    );
    _stateController.add(_state);

    if (activeTrip == null) {
      return null;
    }

    try {
      final finished = await _repository.finishTrip(activeTrip.id);
      return finished;
    } catch (e) {
      debugPrint('Error finishing trip in DB: $e');
      // Fallback: return active trip marked as ended
      return activeTrip.copyWith(endTime: DateTime.now());
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
    _fiveSecondTimer?.cancel();
    _stateController.close();
  }
}
