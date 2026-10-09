import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/constants/marine_constants.dart';

enum AnchorStatus {
  idle,
  safe,
  warning, // Approaching geofence boundary (85%-100%)
  alarmTriggered, // Dragging anchor / outside circle
}

class MobState {
  final bool isActive;
  final LatLng? mobLocation;
  final DateTime? triggeredAt;
  final double distanceMeters;
  final double returnBearingDeg;

  const MobState({
    this.isActive = false,
    this.mobLocation,
    this.triggeredAt,
    this.distanceMeters = 0.0,
    this.returnBearingDeg = 0.0,
  });

  MobState copyWith({
    bool? isActive,
    LatLng? mobLocation,
    DateTime? triggeredAt,
    double? distanceMeters,
    double? returnBearingDeg,
  }) {
    return MobState(
      isActive: isActive ?? this.isActive,
      mobLocation: mobLocation ?? this.mobLocation,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      returnBearingDeg: returnBearingDeg ?? this.returnBearingDeg,
    );
  }
}

class AnchorWatchState {
  final bool isArmed;
  final LatLng? anchorPosition;
  final double chainScopeMeters; // Permitted swing radius
  final double currentDistanceMeters;
  final AnchorStatus status;
  final DateTime? dropTime;

  const AnchorWatchState({
    this.isArmed = false,
    this.anchorPosition,
    this.chainScopeMeters = MarineConstants.defaultAnchorRadiusMeters,
    this.currentDistanceMeters = 0.0,
    this.status = AnchorStatus.idle,
    this.dropTime,
  });

  AnchorWatchState copyWith({
    bool? isArmed,
    LatLng? anchorPosition,
    double? chainScopeMeters,
    double? currentDistanceMeters,
    AnchorStatus? status,
    DateTime? dropTime,
  }) {
    return AnchorWatchState(
      isArmed: isArmed ?? this.isArmed,
      anchorPosition: anchorPosition ?? this.anchorPosition,
      chainScopeMeters: chainScopeMeters ?? this.chainScopeMeters,
      currentDistanceMeters: currentDistanceMeters ?? this.currentDistanceMeters,
      status: status ?? this.status,
      dropTime: dropTime ?? this.dropTime,
    );
  }
}

class AnchorAlarmService {
  final Distance _distance = const Distance();

  AnchorWatchState _anchorState = const AnchorWatchState();
  MobState _mobState = const MobState();

  final _anchorController = StreamController<AnchorWatchState>.broadcast();
  final _mobController = StreamController<MobState>.broadcast();

  Stream<AnchorWatchState> get anchorStream => _anchorController.stream;
  Stream<MobState> get mobStream => _mobController.stream;

  AnchorWatchState get currentAnchorState => _anchorState;
  MobState get currentMobState => _mobState;

  /// Arm anchor watch at specific GPS point with defined swing radius
  void dropAnchor({
    required LatLng position,
    double radiusMeters = MarineConstants.defaultAnchorRadiusMeters,
  }) {
    _anchorState = AnchorWatchState(
      isArmed: true,
      anchorPosition: position,
      chainScopeMeters: radiusMeters,
      currentDistanceMeters: 0.0,
      status: AnchorStatus.safe,
      dropTime: DateTime.now(),
    );
    _anchorController.add(_anchorState);
  }

  /// Disarm anchor watch
  void weighAnchor() {
    _anchorState = const AnchorWatchState();
    _anchorController.add(_anchorState);
  }

  /// Update boat position to test against geofence and calculate MOB return vector
  void updatePosition(LatLng boatPos) {
    // 1. Anchor Watch evaluation
    if (_anchorState.isArmed && _anchorState.anchorPosition != null) {
      final distMeters = _distance.as(
        LengthUnit.Meter,
        _anchorState.anchorPosition!,
        boatPos,
      );

      AnchorStatus newStatus;
      if (distMeters > _anchorState.chainScopeMeters) {
        newStatus = AnchorStatus.alarmTriggered;
      } else if (distMeters > (_anchorState.chainScopeMeters * MarineConstants.warningAnchorRadiusRatio)) {
        newStatus = AnchorStatus.warning;
      } else {
        newStatus = AnchorStatus.safe;
      }

      _anchorState = _anchorState.copyWith(
        currentDistanceMeters: distMeters,
        status: newStatus,
      );
      _anchorController.add(_anchorState);
    }

    // 2. MOB return vector evaluation
    if (_mobState.isActive && _mobState.mobLocation != null) {
      final mobDist = _distance.as(
        LengthUnit.Meter,
        boatPos,
        _mobState.mobLocation!,
      );

      final bearing = _calculateBearing(boatPos, _mobState.mobLocation!);

      _mobState = _mobState.copyWith(
        distanceMeters: mobDist,
        returnBearingDeg: bearing,
      );
      _mobController.add(_mobState);
    }
  }

  /// Trigger emergency Man Overboard
  void triggerMob(LatLng currentPos) {
    _mobState = MobState(
      isActive: true,
      mobLocation: currentPos,
      triggeredAt: DateTime.now(),
      distanceMeters: 0.0,
      returnBearingDeg: 0.0,
    );
    _mobController.add(_mobState);
  }

  /// Clear emergency MOB
  void clearMob() {
    _mobState = const MobState(isActive: false);
    _mobController.add(_mobState);
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final dLon = (end.longitude - start.longitude) * (3.141592653589793 / 180.0);
    final lat1 = start.latitude * (3.141592653589793 / 180.0);
    final lat2 = end.latitude * (3.141592653589793 / 180.0);

    final y = (dLon) * (lat2 - lat1); // simplified planar bearing for immediate nearby range
    final bearing = (180.0 / 3.141592653589793) * y;
    return (bearing + 360.0) % 360.0;
  }

  void dispose() {
    _anchorController.close();
    _mobController.close();
  }
}
