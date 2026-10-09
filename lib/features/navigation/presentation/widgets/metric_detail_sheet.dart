import 'package:flutter/material.dart';
import 'package:viranav/core/localization/app_localizations.dart';

enum MetricType {
  sog,
  hdg,
  cog,
  wind,
  waveHeight,
  wavePeriod,
  current,
  pressure,
  temperature,
  humidity,
  location,
}

class MetricDetailSheet extends StatelessWidget {
  final MetricType type;
  final double value;
  final double? secondaryValue;
  final String? stringValue;
  final AppStrings strings;
  final bool isNightVision;

  const MetricDetailSheet({
    super.key,
    required this.type,
    required this.value,
    this.secondaryValue,
    this.stringValue,
    required this.strings,
    this.isNightVision = false,
  });

  static void show(
    BuildContext context, {
    required MetricType type,
    required double value,
    double? secondaryValue,
    String? stringValue,
    required AppStrings strings,
    bool isNightVision = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MetricDetailSheet(
        type: type,
        value: value,
        secondaryValue: secondaryValue,
        stringValue: stringValue,
        strings: strings,
        isNightVision: isNightVision,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final info = _resolveMetricInfo(strings);

    return Container(
      decoration: BoxDecoration(
        color: isNightVision
            ? const Color(0xFF1E0303)
            : (isDark ? const Color(0xFF112240) : Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header: Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  info.icon,
                  color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isNightVision ? const Color(0xFFFF6B6B) : null,
                      ),
                    ),
                    Text(
                      info.category,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Primary Value Display Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isNightVision
                  ? const Color(0xFF2A0000)
                  : (isDark ? const Color(0xFF0A192F) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.interpretation,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.displayValue,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isNightVision ? const Color(0xFFFF3B30) : const Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    info.statusTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Unit conversions / breakdown
          Text(
            strings.unitDetails,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: info.conversions.map((conv) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  conv,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Safety Guidance & Maritime Advice
          Text(
            strings.safetyAdvice,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info.safetyAdvice,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: isDark ? Colors.amber.shade100 : Colors.brown.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  _MetricData _resolveMetricInfo(AppStrings s) {
    switch (type) {
      case MetricType.sog:
        final kmh = value * 1.852;
        final ms = value * 0.514444;
        return _MetricData(
          title: s.sogLabel,
          category: 'GNSS Doppler / GPS Navigation',
          icon: Icons.speed,
          displayValue: '${value.toStringAsFixed(1)} KTS',
          statusTag: value > 0.5 ? s.underWay : s.anchoredMoored,
          conversions: [
            '${kmh.toStringAsFixed(1)} km/h',
            '${ms.toStringAsFixed(1)} m/s',
            '${(value * 1.15078).toStringAsFixed(1)} mph',
          ],
          safetyAdvice: value > 15.0
              ? 'Yüksek seyir sürati. Çatışmayı önleme tüzüğü (COLREG) uyarınca daimi gözcülük (lookout) şarttır.'
              : 'Konforlu seyir sürati. Rota üzerindeki balıkçı ağlarına ve sığlıklara dikkat ediniz.',
        );

      case MetricType.hdg:
        final rad = (value % 360 + 360) % 360;
        return _MetricData(
          title: s.hdgLabel,
          category: 'Magnetic Fluxgate / Gyro Sensor',
          icon: Icons.explore,
          displayValue: '${rad.round().toString().padLeft(3, '0')}° MAG',
          statusTag: 'Pusula Rotası',
          conversions: [
            'Manyetik Sapma (Var): ~+4.5° E (Ege)',
            'Hakiki Rota (True): ~${((rad + 4.5) % 360).round()}°',
          ],
          safetyAdvice: 'Pusula çevresindeki hoparlör, cep telefonu ve demirli metaller manyetik sapmaya yol açabilir.',
        );

      case MetricType.cog:
        return _MetricData(
          title: s.cogLabel,
          category: 'GPS Course Over Ground',
          icon: Icons.navigation_outlined,
          displayValue: '${value.round().toString().padLeft(3, '0')}° TRUE',
          statusTag: 'GPS İzi',
          conversions: [
            'Doğruluk: <1.5° GNSS',
            'Fark (Drift / Rüzgar Düşmesi): Hesaplanıyor',
          ],
          safetyAdvice: 'COG ve HDG arasındaki fark rüzgar düşmesi (leeway) veya yüzey akıntısı etkisini gösterir.',
        );

      case MetricType.wind:
        final bft = _calcBeaufort(value);
        final kmh = value * 1.852;
        return _MetricData(
          title: s.twsLabel,
          category: 'Open-Meteo Marine / Anemometer',
          icon: Icons.air,
          displayValue: '${value.toStringAsFixed(1)} KTS (Bft $bft)',
          statusTag: 'Beaufort $bft',
          conversions: [
            '${kmh.toStringAsFixed(1)} km/h',
            '${(value * 0.514444).toStringAsFixed(1)} m/s',
            'Yön: ${secondaryValue?.round() ?? 0}°',
          ],
          safetyAdvice: bft >= 6
              ? 'Kuvvetli Rüzgar (Bft 6+). Yelkenlerde 2. camadanı (reef) vurun veya fırtına floku açın.'
              : 'Seyir için elverişli rüzgar şartları. Tramola kör açısı ±45° hesaplanmaktadır.',
        );

      case MetricType.waveHeight:
        final feet = value * 3.28084;
        return _MetricData(
          title: s.waveHeight,
          category: 'Oceanography / Significant Wave Height (Hs)',
          icon: Icons.waves,
          displayValue: '${value.toStringAsFixed(1)} M',
          statusTag: value < 1.0 ? 'Sakin Deniz' : (value < 2.0 ? 'Orta Dalgalı' : 'Kaba Deniz'),
          conversions: [
            '${feet.toStringAsFixed(1)} ft',
            'Maksimum Dalga (Hmax): ${(value * 1.8).toStringAsFixed(1)} m',
          ],
          safetyAdvice: value > 2.0
              ? 'Dalga boyu 2 metrenin üzerinde. Başomuzluktan gelen dalgalarda tekne baş vurması ve serpinti artar.'
              : 'Deniz durumu stabil. Kıyı ve açık seyir için güvenli derinlik mevcuttur.',
        );

      case MetricType.wavePeriod:
        return _MetricData(
          title: s.wavePeriod,
          category: 'Swell & Wind Sea Dominant Period',
          icon: Icons.timer_outlined,
          displayValue: '${value.toStringAsFixed(1)} SN',
          statusTag: value > 7.0 ? 'Uzun Soluğan (Swell)' : 'Kısa Dik Dalga',
          conversions: [
            'Dalga Boyu (λ): ~${(1.56 * value * value).round()} m',
            'Dalga Sürati: ~${(3.03 * value).toStringAsFixed(1)} kn',
          ],
          safetyAdvice: value < 4.5
              ? 'Kısa periyotlu dik dalgalar tekneyi sarsabilir. Seyir hızını azaltıp dalgayı bordadan almamaya çalışın.'
              : 'Geniş aralıklı soluğan dalga. Tekne salınımı daha yumuşaktır.',
        );

      case MetricType.current:
        return _MetricData(
          title: s.surfaceCurrent,
          category: 'Copernicus Ocean Current Model',
          icon: Icons.water,
          displayValue: '${value.toStringAsFixed(1)} KTS',
          statusTag: 'Akıntı Vektörü',
          conversions: [
            'Yön Açısı: ${secondaryValue?.round() ?? 180}°',
            'Drift Hızı: ${(value * 1.852).toStringAsFixed(1)} km/h',
          ],
          safetyAdvice: 'Dar boğazlarda (ör. Boğazlar veya adalar arası) akıntı hızı yerel olarak 2 katına çıkabilir.',
        );

      case MetricType.pressure:
        return _MetricData(
          title: s.pressureLabel,
          category: 'Marine Barometer / Sensor',
          icon: Icons.speed,
          displayValue: '${value.toStringAsFixed(1)} hPa',
          statusTag: value < 1010 ? 'Alçak Basınç' : 'Yüksek / Kararlı',
          conversions: [
            '${(value * 0.02953).toStringAsFixed(2)} inHg',
            '${(value * 0.75006).toStringAsFixed(1)} mmHg',
          ],
          safetyAdvice: 'Barometrede 3 saatte 3 hPa ve üzeri düşüş fırtına habercisidir. Barometre trendini yakından izleyiniz.',
        );

      case MetricType.temperature:
        final f = (value * 9 / 5) + 32;
        return _MetricData(
          title: s.tempLabel,
          category: 'Marine Weather Sensor',
          icon: Icons.thermostat,
          displayValue: '${value.toStringAsFixed(1)}°C',
          statusTag: 'Hava Sıcaklığı',
          conversions: [
            '${f.toStringAsFixed(1)}°F',
            '${(value + 273.15).toStringAsFixed(1)} K',
          ],
          safetyAdvice: 'Deniz üzerindeki rüzgar soğutma etkisi (wind chill) hissedilen sıcaklığı 3-5°C daha düşük hissettirebilir.',
        );

      case MetricType.humidity:
        return _MetricData(
          title: s.humidityLabel,
          category: 'Hygrometer / Atmospheric Moisture',
          icon: Icons.water_drop,
          displayValue: '${value.round()}%',
          statusTag: value > 80 ? 'Yüksek Nem / Sis Riski' : 'Normal',
          conversions: [
            'Çiy Noktası (Dewpoint): ~${(secondaryValue ?? 16.0).toStringAsFixed(1)}°C',
          ],
          safetyAdvice: value > 85
              ? 'Yüksek bağıl nem ve soğuyan hava durumunda gece ve şafak vaktinde deniz sisi oluşabilir.'
              : 'Görüş mesafesi açık.',
        );

      case MetricType.location:
        return _MetricData(
          title: s.locationGps,
          category: 'High-Precision GNSS Receiver',
          icon: Icons.my_location,
          displayValue: stringValue ?? '37.034° N, 27.430° E',
          statusTag: '3D GPS Kilitli',
          conversions: [
            'Datum: WGS-84 Marine Standard',
            'Güncelleme: Her 1 saniye (Canlı)',
          ],
          safetyAdvice: 'Açık denizde uydu sinyalleri kesintisizdir. Kıyılarda sığlık ve kardinal şamandıralara dikkat ediniz.',
        );
    }
  }

  int _calcBeaufort(double knots) {
    if (knots < 1) return 0;
    if (knots <= 3) return 1;
    if (knots <= 6) return 2;
    if (knots <= 10) return 3;
    if (knots <= 16) return 4;
    if (knots <= 21) return 5;
    if (knots <= 27) return 6;
    if (knots <= 33) return 7;
    if (knots <= 40) return 8;
    return 9;
  }
}

class _MetricData {
  final String title;
  final String category;
  final IconData icon;
  final String displayValue;
  final String statusTag;
  final List<String> conversions;
  final String safetyAdvice;

  const _MetricData({
    required this.title,
    required this.category,
    required this.icon,
    required this.displayValue,
    required this.statusTag,
    required this.conversions,
    required this.safetyAdvice,
  });
}
