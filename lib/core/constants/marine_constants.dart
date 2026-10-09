class MarineConstants {
  // Conversion factors
  static const double mpsToKnots = 1.94384;
  static const double kmhToKnots = 0.539957;
  static const double metersToFeet = 3.28084;
  static const double nmToKm = 1.852;
  static const double kmToNm = 0.539957;

  // Sailing Dynamics
  static const double defaultNoGoZoneDegrees = 45.0; // +/- 45 deg from true wind
  static const double optimumTackAngleDegrees = 48.0;

  // Safety & Anchor Watch
  static const double defaultAnchorRadiusMeters = 35.0;
  static const double warningAnchorRadiusRatio = 0.85;

  // Default OpenSeaMap Tile & Style URLs
  static const String openStreetMapUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String openSeaMapTileUrl =
      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png';

  // Barometric Storm Warning: pressure dropping faster than 3 hPa in 3 hours
  static const double stormPressureDropThresholdHpa = 3.0;
}
