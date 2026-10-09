import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/models/marine_weather.dart';
import 'package:viranav/core/models/vessel.dart';
import 'package:viranav/core/services/tracking_service.dart';
import 'package:viranav/core/services/sensors_service.dart';
import 'package:viranav/features/weather/data/weather_repository.dart';
import 'package:viranav/features/anchor_watch/services/anchor_alarm_service.dart';
import 'package:viranav/features/boat_garage/domain/checklist_item.dart';
import 'package:viranav/features/logbook/data/trip_repository.dart';

// Vessel Provider
class VesselNotifier extends Notifier<Vessel> {
  @override
  Vessel build() {
    return Vessel.defaultSailboat();
  }

  void updateVessel(Vessel vessel) {
    state = vessel;
  }

  void toggleType() {
    if (state.isSailboat) {
      state = Vessel.defaultMotorYacht();
    } else {
      state = Vessel.defaultSailboat();
    }
  }
}

final vesselProvider = NotifierProvider<VesselNotifier, Vessel>(VesselNotifier.new);

// Repositories & Services
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository();
});

final trackingServiceProvider = Provider<TrackingService>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  final service = TrackingService(repository: repo);
  ref.onDispose(() => service.dispose());
  return service;
});

final trackingStateStreamProvider = StreamProvider<TrackingState>((ref) {
  final service = ref.watch(trackingServiceProvider);
  return service.stateStream;
});

final sensorsServiceProvider = Provider<SensorsService>((ref) {
  return SensorsService();
});

final compassHeadingStreamProvider = StreamProvider<double?>((ref) {
  final sensors = ref.watch(sensorsServiceProvider);
  return sensors.headingStream;
});

// Anchor Alarm Service
final anchorServiceProvider = Provider<AnchorAlarmService>((ref) {
  final service = AnchorAlarmService();
  ref.onDispose(() => service.dispose());
  return service;
});

final anchorStateStreamProvider = StreamProvider<AnchorWatchState>((ref) {
  final service = ref.watch(anchorServiceProvider);
  return service.anchorStream;
});

final mobStateStreamProvider = StreamProvider<MobState>((ref) {
  final service = ref.watch(anchorServiceProvider);
  return service.mobStream;
});

// Marine Weather Provider
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

class WeatherCoords {
  final double lat;
  final double lon;
  const WeatherCoords(this.lat, this.lon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherCoords &&
          runtimeType == other.runtimeType &&
          (lat - other.lat).abs() < 0.02 &&
          (lon - other.lon).abs() < 0.02;

  @override
  int get hashCode => (lat * 100).round().hashCode ^ (lon * 100).round().hashCode;
}

final marineWeatherProvider = FutureProvider.family<MarineWeather, WeatherCoords>((ref, coords) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return await repo.getMarineWeather(lat: coords.lat, lon: coords.lon);
});

// Safety Checklist Notifier
class ChecklistNotifier extends Notifier<List<ChecklistItem>> {
  @override
  List<ChecklistItem> build() {
    return ChecklistItem.defaultMaritimeChecklist();
  }

  void toggleItem(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
  }

  void resetAll() {
    state = ChecklistItem.defaultMaritimeChecklist();
  }
}

final checklistProvider = NotifierProvider<ChecklistNotifier, List<ChecklistItem>>(ChecklistNotifier.new);
