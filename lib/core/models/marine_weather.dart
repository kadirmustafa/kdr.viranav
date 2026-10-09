class MarineWeather {
  final double lat;
  final double lon;
  final DateTime timestamp;

  // Atmospheric
  final double temperature; // °C
  final int relativeHumidity; // %
  final double surfacePressure; // hPa
  final bool pressureTrendWarning; // Storm warning

  // Wind
  final double windSpeedKnots; // Knots
  final double windDirectionDeg; // 0-360°
  final int beaufortScale; // 0-12
  final String beaufortDescription;

  // Marine & Oceanography
  final double waveHeightMeters; // Hs in meters
  final double wavePeriodSeconds; // Tp in seconds
  final double waveDirectionDeg; // 0-360°
  final double currentVelocityKnots; // Knots
  final double currentDirectionDeg; // 0-360°

  final bool isCached;

  const MarineWeather({
    required this.lat,
    required this.lon,
    required this.timestamp,
    required this.temperature,
    required this.relativeHumidity,
    required this.surfacePressure,
    required this.pressureTrendWarning,
    required this.windSpeedKnots,
    required this.windDirectionDeg,
    required this.beaufortScale,
    required this.beaufortDescription,
    required this.waveHeightMeters,
    required this.wavePeriodSeconds,
    required this.waveDirectionDeg,
    required this.currentVelocityKnots,
    required this.currentDirectionDeg,
    this.isCached = false,
  });

  factory MarineWeather.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    final atm = json['atmospheric'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final marine = json['marine'] as Map<String, dynamic>? ?? {};

    return MarineWeather(
      lat: (coords['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (coords['lon'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      temperature: (atm['temperature'] as num?)?.toDouble() ?? 22.0,
      relativeHumidity: (atm['relativeHumidity'] as num?)?.toInt() ?? 65,
      surfacePressure: (atm['surfacePressure'] as num?)?.toDouble() ?? 1013.2,
      pressureTrendWarning: atm['pressureTrendWarning'] as bool? ?? false,
      windSpeedKnots: (wind['speedKnots'] as num?)?.toDouble() ?? 12.0,
      windDirectionDeg: (wind['directionDeg'] as num?)?.toDouble() ?? 45.0,
      beaufortScale: (wind['beaufortScale'] as num?)?.toInt() ?? 4,
      beaufortDescription: wind['beaufortDescription'] as String? ?? 'Orta Rüzgar',
      waveHeightMeters: (marine['waveHeightMeters'] as num?)?.toDouble() ?? 0.8,
      wavePeriodSeconds: (marine['wavePeriodSeconds'] as num?)?.toDouble() ?? 5.5,
      waveDirectionDeg: (marine['waveDirectionDeg'] as num?)?.toDouble() ?? 50.0,
      currentVelocityKnots: (marine['currentVelocityKnots'] as num?)?.toDouble() ?? 0.4,
      currentDirectionDeg: (marine['currentDirectionDeg'] as num?)?.toDouble() ?? 180.0,
      isCached: json['_cached'] as bool? ?? false,
    );
  }

  factory MarineWeather.defaultDummy(double lat, double lon) {
    return MarineWeather(
      lat: lat,
      lon: lon,
      timestamp: DateTime.now(),
      temperature: 24.5,
      relativeHumidity: 68,
      surfacePressure: 1014.0,
      pressureTrendWarning: false,
      windSpeedKnots: 14.2,
      windDirectionDeg: 65.0,
      beaufortScale: 4,
      beaufortDescription: 'Orta Rüzgar (Moderate Breeze)',
      waveHeightMeters: 0.9,
      wavePeriodSeconds: 5.2,
      waveDirectionDeg: 70.0,
      currentVelocityKnots: 0.6,
      currentDirectionDeg: 195.0,
      isCached: false,
    );
  }
}
