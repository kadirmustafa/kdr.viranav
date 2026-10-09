enum VesselType {
  sailboat,
  motorYacht,
}

class Vessel {
  final String id;
  final String name;
  final VesselType type;
  final double lengthMeters; // LOA
  final double draftMeters; // Su çekimi (Sığlık emniyeti)
  final double beamMeters; // En
  final double cruisingSpeedKnots; // Seyir sürati
  final double fuelBurnLitersPerHour; // Motor yat için saatlik tüketim
  final double noGoZoneAngle; // Yelkenli için kör açı (varsayılan 45°)

  const Vessel({
    required this.id,
    required this.name,
    required this.type,
    required this.lengthMeters,
    required this.draftMeters,
    required this.beamMeters,
    required this.cruisingSpeedKnots,
    required this.fuelBurnLitersPerHour,
    this.noGoZoneAngle = 45.0,
  });

  bool get isSailboat => type == VesselType.sailboat;
  bool get isMotorYacht => type == VesselType.motorYacht;

  Vessel copyWith({
    String? id,
    String? name,
    VesselType? type,
    double? lengthMeters,
    double? draftMeters,
    double? beamMeters,
    double? cruisingSpeedKnots,
    double? fuelBurnLitersPerHour,
    double? noGoZoneAngle,
  }) {
    return Vessel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lengthMeters: lengthMeters ?? this.lengthMeters,
      draftMeters: draftMeters ?? this.draftMeters,
      beamMeters: beamMeters ?? this.beamMeters,
      cruisingSpeedKnots: cruisingSpeedKnots ?? this.cruisingSpeedKnots,
      fuelBurnLitersPerHour: fuelBurnLitersPerHour ?? this.fuelBurnLitersPerHour,
      noGoZoneAngle: noGoZoneAngle ?? this.noGoZoneAngle,
    );
  }

  static Vessel defaultSailboat() {
    return const Vessel(
      id: 'vessel_1',
      name: 'Vira 40 (Bavaria C42)',
      type: VesselType.sailboat,
      lengthMeters: 12.38,
      draftMeters: 2.10,
      beamMeters: 4.29,
      cruisingSpeedKnots: 6.8,
      fuelBurnLitersPerHour: 3.5,
      noGoZoneAngle: 45.0,
    );
  }

  static Vessel defaultMotorYacht() {
    return const Vessel(
      id: 'vessel_2',
      name: 'Aegean Star (Azimut 43)',
      type: VesselType.motorYacht,
      lengthMeters: 12.90,
      draftMeters: 1.25,
      beamMeters: 4.22,
      cruisingSpeedKnots: 22.0,
      fuelBurnLitersPerHour: 65.0,
      noGoZoneAngle: 0.0,
    );
  }
}
