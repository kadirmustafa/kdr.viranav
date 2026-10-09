import 'dart:async';
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
  }

  Future<void> startTrip({
    required String tripId,
    required String title,
    required String vesselName,
  }) async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception('Konum izni verilmedi.');
    }

    final newTrip = Trip(
      id: tripId,
      title: title,
      startTime: DateTime.now(),
      vesselName: vesselName,
    );

    await _repository.createTrip(newTrip);

    _state = _state.copyWith(
      isTracking: true,
      currentTrip: newTrip,
      pointsLogged: 0,
    );
    _stateController.add(_state);

    // High accuracy location stream with distance filter
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // meters
    );

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
    });

    // 5-second interval offline DB recorder
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

        await _repository.logPoint(pt);

        _state = _state.copyWith(
          pointsLogged: _state.pointsLogged + 1,
        );
        _stateController.add(_state);
      }
    });
  }

  Future<Trip?> stopTrip() async {
    _positionSubscription?.cancel();
    _fiveSecondTimer?.cancel();

    final activeTrip = _state.currentTrip;
    if (activeTrip == null) return null;

    final finished = await _repository.finishTrip(activeTrip.id);

    _state = const TrackingState(isTracking: false);
    _stateController.add(_state);

    return finished;
  }

  void dispose() {
    _positionSubscription?.cancel();
    _fiveSecondTimer?.cancel();
    _stateController.close();
  }
}
