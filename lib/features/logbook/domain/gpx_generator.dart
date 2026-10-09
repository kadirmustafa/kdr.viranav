import 'package:xml/xml.dart';
import 'trip.dart';
import 'gps_track_point.dart';

class GpxGenerator {
  /// Converts a trip and its GPS points into standard GPX 1.1 XML format.
  static String generateGpx({
    required Trip trip,
    required List<GpsTrackPoint> points,
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', nest: () {
      builder.attribute('version', '1.1');
      builder.attribute('creator', 'ViraNav Marine Navigation (https://viranav.app)');
      builder.attribute('xmlns', 'http://www.topografix.com/GPX/1/1');
      builder.attribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
      builder.attribute(
        'xsi:schemaLocation',
        'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd',
      );

      // Metadata
      builder.element('metadata', nest: () {
        builder.element('name', nest: trip.title);
        builder.element('desc', nest: 'Vessel: ${trip.vesselName}. Distance: ${trip.totalDistanceNm.toStringAsFixed(2)} NM. Max SOG: ${trip.maxSpeedKnots.toStringAsFixed(1)} kn.');
        builder.element('time', nest: trip.startTime.toUtc().toIso8601String());
      });

      // Track
      builder.element('trk', nest: () {
        builder.element('name', nest: trip.title);
        builder.element('type', nest: 'SAILING_VOYAGE');

        builder.element('trkseg', nest: () {
          for (final pt in points) {
            builder.element('trkpt', nest: () {
              builder.attribute('lat', pt.latitude.toStringAsFixed(7));
              builder.attribute('lon', pt.longitude.toStringAsFixed(7));

              if (pt.altitude != null) {
                builder.element('ele', nest: pt.altitude!.toStringAsFixed(1));
              }
              builder.element('time', nest: pt.timestamp.toUtc().toIso8601String());

              // Extensions: Speed (m/s) and Course
              builder.element('extensions', nest: () {
                // 1 knot = 0.514444 m/s in standard GPX extension
                final speedMps = pt.speedKnots * 0.514444;
                builder.element('speed_knots', nest: pt.speedKnots.toStringAsFixed(1));
                builder.element('course_cog', nest: pt.courseDeg.toStringAsFixed(1));
                builder.element('speed', nest: speedMps.toStringAsFixed(2));
              });
            });
          }
        });
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }
}
