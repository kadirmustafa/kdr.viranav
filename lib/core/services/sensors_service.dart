import 'package:flutter_compass/flutter_compass.dart';

class SensorsService {
  Stream<double?> get headingStream {
    try {
      return FlutterCompass.events?.map((event) => event.heading) ??
          Stream.value(0.0);
    } catch (_) {
      return Stream.value(0.0);
    }
  }
}
