import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/services/database_service.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class ViraNavStrings {
  final String languageCode;

  const ViraNavStrings(this.languageCode);

  String _t(Map<String, String> map, [String? fallback]) {
    return map[languageCode] ?? map['en'] ?? fallback ?? map['tr'] ?? '';
  }

  // Navigation
  String get navCockpit => _t({
    'en': 'Cockpit',
    'tr': 'Kokpit',
    'it': 'Pozzetto',
    'es': 'Cabina',
    'fr': 'Cockpit',
    'de': 'Cockpit',
    'ar': 'قمرة القيادة',
    'ru': 'Кокпит',
    'el': 'Κόκπιτ',
    'pt': 'Cockpit',
    'nl': 'Cockpit',
  });

  String get navMap => _t({
    'en': 'Chart & Route',
    'tr': 'Harita',
    'it': 'Mappa',
    'es': 'Carta',
    'fr': 'Carte',
    'de': 'Seekarte',
    'ar': 'الخريطة',
    'ru': 'Карта',
    'el': 'Χάρτης',
    'pt': 'Carta Náutica',
    'nl': 'Kaart',
  });

  String get navLogbook => _t({
    'en': 'Logbook',
    'tr': 'Defter',
    'it': 'Giornale',
    'es': 'Diario',
    'fr': 'Livre de bord',
    'de': 'Logbuch',
    'ar': 'سجل الرحلة',
    'ru': 'Журнал',
    'el': 'Ημερολόγιο',
    'pt': 'Diário',
    'nl': 'Logboek',
  });

  String get navAnchor => _t({
    'en': 'Anchor',
    'tr': 'Demir',
    'it': 'Ancora',
    'es': 'Ancla',
    'fr': 'Ancre',
    'de': 'Anker',
    'ar': 'المرساة',
    'ru': 'Якорь',
    'el': 'Άγκυρα',
    'pt': 'Âncora',
    'nl': 'Anker',
  });

  String get navSettings => _t({
    'en': 'Settings',
    'tr': 'Ayarlar',
    'it': 'Impostazioni',
    'es': 'Ajustes',
    'fr': 'Paramètres',
    'de': 'Einstellungen',
    'ar': 'الإعدادات',
    'ru': 'Настройки',
    'el': 'Ρυθμίσεις',
    'pt': 'Ajustes',
    'nl': 'Instellingen',
  });

  // Cockpit
  String get cockpitTitle => _t({
    'en': 'VIRANAV COCKPIT',
    'tr': 'VIRANAV KOKPİT',
    'it': 'VIRANAV POZZETTO',
    'es': 'VIRANAV CABINA',
    'fr': 'VIRANAV COCKPIT',
    'de': 'VIRANAV COCKPIT',
    'ar': 'قمرة قيادة فيراناف',
    'ru': 'ВИРАНАВ КОКПИТ',
    'el': 'VIRANAV ΚΟΚΠΙΤ',
    'pt': 'VIRANAV COCKPIT',
    'nl': 'VIRANAV COCKPIT',
  });

  String get activeTripRibbon => _t({
    'en': 'ACTIVE VOYAGE',
    'tr': 'SEYİR KAYDI AKTİF',
    'it': 'NAVIGAZIONE ATTIVA',
    'es': 'VIAJE ACTIVO',
    'fr': 'VOYAGE ACTIF',
    'de': 'AKTIVE FAHRT',
    'ar': 'تسجيل الرحلة نشط',
    'ru': 'АКТИВНЫЙ ПЕРЕХОД',
    'el': 'ΕΝΕΡΓΟΣ ΠΛΟΥΣ',
    'pt': 'VIAGEM ATIVA',
    'nl': 'ACTIEVE TOCHT',
  });

  String get pointsCountLabel => _t({
    'en': 'GPS points',
    'tr': 'GPS noktası',
    'it': 'punti GPS',
    'es': 'puntos GPS',
    'fr': 'points GPS',
    'de': 'GPS-Punkte',
    'ar': 'نقاط GPS',
    'ru': 'точек GPS',
    'el': 'σημεία GPS',
    'pt': 'pontos GPS',
    'nl': 'GPS-punten',
  });

  String get locationGps => _t({
    'en': 'Marine GPS Position',
    'tr': 'Deniz GPS Konumu',
    'it': 'Posizione GPS Marina',
    'es': 'Posición GPS Marina',
    'fr': 'Position GPS Marine',
    'de': 'Marine GPS-Position',
    'ar': 'موقع GPS البحري',
    'ru': 'Морская GPS позиция',
    'el': 'Θέση Marine GPS',
    'pt': 'Posição GPS Marítima',
    'nl': 'Maritieme GPS-positie',
  });

  String get sogLabel => _t({
    'en': 'Speed Over Ground (SOG)',
    'tr': 'Yer Hızı (SOG)',
    'it': 'Velocità al Suolo (SOG)',
    'es': 'Velocidad de Fondo (SOG)',
    'fr': 'Vitesse Fond (SOG)',
    'de': 'Geschwindigkeit über Grund (SOG)',
    'ar': 'السرعة الأرضية (SOG)',
    'ru': 'Скорость относ. грунта (SOG)',
    'el': 'Ταχύτητα ως προς βυθό (SOG)',
    'pt': 'Velocidade no Fundo (SOG)',
    'nl': 'Snelheid over de grond (SOG)',
  });

  String get hdgLabel => _t({
    'en': 'Compass Heading (HDG)',
    'tr': 'Pusula Açısı (HDG)',
    'it': 'Prua Bussola (HDG)',
    'es': 'Rumbo de Brújula (HDG)',
    'fr': 'Cap Compas (HDG)',
    'de': 'Kompasskurs (HDG)',
    'ar': 'اتجاه البوصلة (HDG)',
    'ru': 'Курс по компасу (HDG)',
    'el': 'Πορεία πυξίδας (HDG)',
    'pt': 'Rumo da Agulha (HDG)',
    'nl': 'Kompaskoers (HDG)',
  });

  String get cogLabel => _t({
    'en': 'Course Over Ground (COG)',
    'tr': 'Rota Açısı (COG)',
    'it': 'Rotta al Suolo (COG)',
    'es': 'Rumbo de Fondo (COG)',
    'fr': 'Route Fond (COG)',
    'de': 'Kurs über Grund (COG)',
    'ar': 'المسار فوق الأرض (COG)',
    'ru': 'Путевой угол (COG)',
    'el': 'Πορεία ως προς βυθό (COG)',
    'pt': 'Rumo no Fundo (COG)',
    'nl': 'Grondkoers (COG)',
  });

  String get twsLabel => _t({
    'en': 'True Wind Speed (TWS)',
    'tr': 'Gerçek Rüzgar (TWS)',
    'it': 'Vento Reale (TWS)',
    'es': 'Viento Real (TWS)',
    'fr': 'Vent Réel (TWS)',
    'de': 'Wahrer Wind (TWS)',
    'ar': 'سرعة الرياح الحقيقية (TWS)',
    'ru': 'Истинный ветер (TWS)',
    'el': 'Αληθής άνεμος (TWS)',
    'pt': 'Vento Real (TWS)',
    'nl': 'Ware windsnelheid (TWS)',
  });

  String get underWay => _t({
    'en': 'Underway',
    'tr': 'Seyir Hali',
    'it': 'In navigazione',
    'es': 'En navegación',
    'fr': 'En route',
    'de': 'In Fahrt',
    'ar': 'في الإبحار',
    'ru': 'На ходу',
    'el': 'Εν πλω',
    'pt': 'Em navegação',
    'nl': 'Onderweg',
  });

  String get anchoredMoored => _t({
    'en': 'Moored / Anchored',
    'tr': 'Demirde / Rıhtımda',
    'it': 'Ormeggiato / All\'ancora',
    'es': 'Fondeado / Amarrado',
    'fr': 'Au mouillage / À quai',
    'de': 'Vor Anker / Festgemacht',
    'ar': 'على المخطاف / راسي',
    'ru': 'На якоре / У причала',
    'el': 'Αγκυροβολημένο',
    'pt': 'Fundeado / Atracado',
    'nl': 'Voor anker / Gemeerd',
  });

  String get trueCourse => _t({
    'en': 'GPS Track Course',
    'tr': 'GPS İz Rotası',
    'it': 'Traccia GPS',
    'es': 'Derrota GPS',
    'fr': 'Route GPS',
    'de': 'GPS-Spur',
    'ar': 'مسار تتبع GPS',
    'ru': 'Линия пути GPS',
    'el': 'Ίχνος GPS',
    'pt': 'Traçado GPS',
    'nl': 'GPS-spoor',
  });

  String get beaufort => _t({
    'en': 'Bft',
    'tr': 'Bft',
    'it': 'Bft',
    'es': 'Bft',
    'fr': 'Bft',
    'de': 'Bft',
    'ar': 'بوفورت',
    'ru': 'Бофорт',
    'el': 'Μποφόρ',
    'pt': 'Bft',
    'nl': 'Bft',
  });

  String get waveHeight => _t({
    'en': 'Wave Height (Hs)',
    'tr': 'Dalga Boyu (Hs)',
    'it': 'Altezza Onde (Hs)',
    'es': 'Altura de Ola (Hs)',
    'fr': 'Hauteur Vagues (Hs)',
    'de': 'Wellenhöhe (Hs)',
    'ar': 'ارتفاع الموج (Hs)',
    'ru': 'Высота волны (Hs)',
    'el': 'Ύψος κύματος (Hs)',
    'pt': 'Altura da Onda (Hs)',
    'nl': 'Golfhoogte (Hs)',
  });

  String get wavePeriod => _t({
    'en': 'Wave Period (Tp)',
    'tr': 'Dalga Periyodu (Tp)',
    'it': 'Periodo Onde (Tp)',
    'es': 'Período de Ola (Tp)',
    'fr': 'Période Vagues (Tp)',
    'de': 'Wellenperiode (Tp)',
    'ar': 'فترة الموج (Tp)',
    'ru': 'Период волны (Tp)',
    'el': 'Περίοδος κύματος (Tp)',
    'pt': 'Período da Onda (Tp)',
    'nl': 'Golfperiode (Tp)',
  });

  String get surfaceCurrent => _t({
    'en': 'Surface Current',
    'tr': 'Yüzey Akıntısı',
    'it': 'Corrente Superficie',
    'es': 'Corriente Superficie',
    'fr': 'Courant Surface',
    'de': 'Oberflächenströmung',
    'ar': 'التيار السطحي',
    'ru': 'Поверхностное течение',
    'el': 'Επιφανειακό ρεύμα',
    'pt': 'Corrente de Superfície',
    'nl': 'Oppervlaktestroom',
  });

  String get significantHs => _t({
    'en': 'Significant Hs',
    'tr': 'Hs Belirgin',
    'it': 'Significativa Hs',
    'es': 'Significativa Hs',
    'fr': 'Significative Hs',
    'de': 'Signifikante Hs',
    'ar': 'دلالة Hs',
    'ru': 'Значимая Hs',
    'el': 'Σημαντικό Hs',
    'pt': 'Significativa Hs',
    'nl': 'Significante Hs',
  });

  String get waveSec => _t({
    'en': 'Sec Period',
    'tr': 'SN Periyot',
    'it': 'Sec Periodo',
    'es': 'Seg Período',
    'fr': 'Sec Période',
    'de': 'Sek Periode',
    'ar': 'ثانية',
    'ru': 'сек период',
    'el': 'δευτ περίοδος',
    'pt': 'Seg Período',
    'nl': 'sec periode',
  });

  String get knotsUnit => _t({
    'en': 'KTS',
    'tr': 'KTS',
    'it': 'ND',
    'es': 'ND',
    'fr': 'ND',
    'de': 'KN',
    'ar': 'عقدة',
    'ru': 'УЗЛ',
    'el': 'ΚΟΜ',
    'pt': 'NÓS',
    'nl': 'KN',
  });

  String get currentDirection => _t({
    'en': 'Set Direction',
    'tr': 'Akıntı Yönü',
    'it': 'Direzione Corrente',
    'es': 'Dirección Corriente',
    'fr': 'Direction Courant',
    'de': 'Stromrichtung',
    'ar': 'اتجاه التيار',
    'ru': 'Направление течения',
    'el': 'Διεύθυνση ρεύματος',
    'pt': 'Direção da Corrente',
    'nl': 'Stroomrichting',
  });

  String get windRoseTitle => _t({
    'en': 'WIND ROSE & TACK INDICATOR',
    'tr': 'RÜZGAR GÜLÜ & TRAMOLA (TACK) GÖSTERGESİ',
    'it': 'ROSA DEI VENTI & INDICATORE VIRATA',
    'es': 'ROSA DE LOS VIENTOS Y VIRAJE',
    'fr': 'ROSE DES VENTS & VIREMENT',
    'de': 'WINDROSE & WENDE-INDIKATOR',
    'ar': 'وردة الرياح ومؤشر المناورة',
    'ru': 'РОЗА ВЕТРОВ И ЛАВИРОВКА',
    'el': 'ΑΝΕΜΟΛΟΓΙΟ & ΔΕΙΚΤΗΣ ΤΑΚ',
    'pt': 'ROSA DOS VENTOS & BORDADA',
    'nl': 'WINDROOS & OVERSTAG-INDICATOR',
  });

  String get noGoZone => _t({
    'en': 'No-Go Zone (Dead Angle)',
    'tr': 'Kör Nokta (No-Go Zone)',
    'it': 'Angolo Morto (No-Go)',
    'es': 'Zona Prohibida (Ángulo Muerto)',
    'fr': 'Angle Mort (No-Go)',
    'de': 'Toter Winkel (No-Go)',
    'ar': 'الزاوية الميتة',
    'ru': 'Мертвая зона (No-Go)',
    'el': 'Νεκρή γωνία',
    'pt': 'Zona Proibida',
    'nl': 'Dode hoek',
  });

  String get optimumTack => _t({
    'en': 'Optimal Tack Angle',
    'tr': 'En İyi Tramola Açısı',
    'it': 'Angolo Virata Ottimale',
    'es': 'Ángulo Óptimo de Virada',
    'fr': 'Angle Optimal de Virement',
    'de': 'Optimaler Wendewinkel',
    'ar': 'زاوية المناورة المثالية',
    'ru': 'Оптимальный угол лавировки',
    'el': 'Βέλτιστη γωνία τακ',
    'pt': 'Ângulo Ideal de Bordo',
    'nl': 'Optimale overstaghoek',
  });

  String get barometerTitle => _t({
    'en': 'BAROMETRIC PRESSURE & FORECAST',
    'tr': 'BAROMETRİK BASINÇ & TAHMİN',
    'it': 'PRESSIONE BAROMETRICA & PREVISIONI',
    'es': 'PRESIÓN BAROMÉTRICA Y PRONÓSTICO',
    'fr': 'PRESSION BAROMÉTRIQUE & PRÉVISIONS',
    'de': 'BAROMETRISCHER DRUCK & PROGNOSE',
    'ar': 'الضغط الجوي والتنبؤ',
    'ru': 'БАРОМЕТРИЧЕСКОЕ ДАВЛЕНИЕ И ПРОГНОЗ',
    'el': 'ΒΑΡΟΜΕΤΡΙΚΗ ΠΙΕΣΗ & ΠΡΟΓΝΩΣΗ',
    'pt': 'PRESSÃO BAROMÉTRICA & PREVISÃO',
    'nl': 'BAROMETRISCHE DRUK & VERWACHTING',
  });

  String get pressureLabel => _t({
    'en': 'Atmospheric Pressure',
    'tr': 'Atmosfer Basıncı',
    'it': 'Pressione Atmosferica',
    'es': 'Presión Atmosférica',
    'fr': 'Pression Atmosphérique',
    'de': 'Luftdruck',
    'ar': 'الضغط الجوي',
    'ru': 'Атмосферное давление',
    'el': 'Ατμοσφαιρική πίεση',
    'pt': 'Pressão Atmosférica',
    'nl': 'Luchtdruk',
  });

  String get tempLabel => _t({
    'en': 'Air Temperature',
    'tr': 'Hava Sıcaklığı',
    'it': 'Temperatura Aria',
    'es': 'Temperatura del Aire',
    'fr': 'Température de l\'air',
    'de': 'Lufttemperatur',
    'ar': 'درجة حرارة الهواء',
    'ru': 'Температура воздуха',
    'el': 'Θερμοκρασία αέρα',
    'pt': 'Temperatura do Ar',
    'nl': 'Luchttemperatuur',
  });

  String get humidityLabel => _t({
    'en': 'Relative Humidity',
    'tr': 'Bağıl Nem',
    'it': 'Umidità Relativa',
    'es': 'Humedad Relativa',
    'fr': 'Humidité Relative',
    'de': 'Relative Feuchtigkeit',
    'ar': 'الرطوبة النسبية',
    'ru': 'Относительная влажность',
    'el': 'Σχετική υγρασία',
    'pt': 'Humidade Relativa',
    'nl': 'Relatieve vochtigheid',
  });

  String get stormAlert => _t({
    'en': 'RAPID DROP STORM WARNING!',
    'tr': 'ANİ BASINÇ DÜŞÜŞÜ - FIRTINA UYARISI!',
    'it': 'AVVISO TEMPESTA - CALO RAPIDO!',
    'es': '¡AVISO DE TORMENTA - CAÍDA RÁPIDA!',
    'fr': 'ALERTE TEMPÊTE - CHUTE RAPIDE !',
    'de': 'STURMWARNUNG - SCHNELLER DRUCKABFALL!',
    'ar': 'تحذير من عاصفة - انخفاض مفاجئ!',
    'ru': 'ШТОРМОВОЕ ПРЕДУПРЕЖДЕНИЕ - ПАДЕНИЕ ДАВЛЕНИЯ!',
    'el': 'ΠΡΟΕΙΔΟΠΟΙΗΣΗ ΚΑΤΑΙΓΙΔΑΣ!',
    'pt': 'AVISO DE TEMPESTADE - QUEDA RÁPIDA!',
    'nl': 'STORMWAARSCHUWING - SNELLE DRUKVAL!',
  });

  String get normalPressure => _t({
    'en': 'Pressure Steady / Good Seakeeping',
    'tr': 'Basınç Kararlı / Seyre Uygun',
    'it': 'Pressione Stabile / Buona Tenuta',
    'es': 'Presión Estable / Buena Navegabilidad',
    'fr': 'Pression Stable / Bonnes Conditions',
    'de': 'Druck Stabil / Gute Fahrt',
    'ar': 'ضغط مستقر / ملائم للإبحار',
    'ru': 'Давление стабильно / Спокойное море',
    'el': 'Σταθερή πίεση / Καλές συνθήκες',
    'pt': 'Pressão Estável / Boa Navegação',
    'nl': 'Druk stabiel / Goede vaaromstandigheden',
  });

  String get stormWarningDesc => _t({
    'en': 'Pressure dropped >3 hPa in last 3 hours. Squall/gale front approaching.',
    'tr': 'Son 3 saatte >3 hPa düşüş tespit edildi. Fırtına veya sağanak cephesi yaklaşıyor.',
    'it': 'Pressione scesa >3 hPa nelle ultime 3 ore. Fronte tempestoso in arrivo.',
    'es': 'Presión cayó >3 hPa en 3 horas. Frente tormentoso acercándose.',
    'fr': 'Chute de >3 hPa en 3 heures. Front de tempête en approche.',
    'de': 'Druckabfall >3 hPa in 3 Stunden. Sturmböenfront nähert sich.',
    'ar': 'انخفض الضغط بأكثر من 3 هكتوباسكال في 3 ساعات. جبهة عاصفة تقترب.',
    'ru': 'Падение давления >3 гПа за 3 часа. Приближается шквалистый фронт.',
    'el': 'Πτώση >3 hPa σε 3 ώρες. Πλησιάζει μέτωπο καταιγίδας.',
    'pt': 'Queda de >3 hPa em 3 horas. Frente de tempestade a aproximar-se.',
    'nl': 'Drukval >3 hPa in 3 uur. Stormfront nadert.',
  });

  String get normalPressureDesc => _t({
    'en': 'Stable barometric trend. Favorable nautical weather conditions.',
    'tr': 'İstikrarlı barometre trendi. Deniz şartları genel seyre elverişli.',
    'it': 'Trend barometrico stabile. Condizioni favorevoli.',
    'es': 'Tendencia barométrica estable. Condiciones favorables.',
    'fr': 'Tendance stable. Conditions nautiques favorables.',
    'de': 'Stabiler Barometertrend. Günstige Wetterbedingungen.',
    'ar': 'اتجاه بارومتري مستقر. الظروف البحرية مواتية.',
    'ru': 'Стабильный барометрический тренд. Благоприятные условия.',
    'el': 'Σταθερή τάση. Ευνοϊκές συνθήκες πλεύσης.',
    'pt': 'Tendência estável. Condições de navegação favoráveis.',
    'nl': 'Stabiele trend. Gunstige weersomstandigheden.',
  });

  // Map & Route
  String get mapTitle => _t({
    'en': 'CHART & ROUTE',
    'tr': 'SEYİR HARİTASI & ROTA',
    'it': 'CARTA & ROTTA',
    'es': 'CARTA Y RUTA',
    'fr': 'CARTE & ROUTE',
    'de': 'SEEKARTE & ROUTE',
    'ar': 'الخريطة والمسار',
    'ru': 'КАРТА И МАРШРУТ',
    'el': 'ΧΑΡΤΗΣ & ΠΟΡΕΙΑ',
    'pt': 'CARTA & ROTA',
    'nl': 'KAART & ROUTE',
  });

  String get myLocation => _t({
    'en': 'My Location',
    'tr': 'Konumum',
    'it': 'Mia Posizione',
    'es': 'Mi Ubicación',
    'fr': 'Ma Position',
    'de': 'Mein Standort',
    'ar': 'موقعي',
    'ru': 'Мое местоположение',
    'el': 'Η θέση μου',
    'pt': 'Minha Posição',
    'nl': 'Mijn locatie',
  });

  String get locateMeTooltip => _t({
    'en': 'Center on my GPS location',
    'tr': 'Beni GPS konumuma odakla',
    'it': 'Centra sulla mia posizione GPS',
    'es': 'Centrar en mi posición GPS',
    'fr': 'Centrer sur ma position GPS',
    'de': 'Auf meinen GPS-Standort zentrieren',
    'ar': 'التركيز على موقع GPS الخاص بي',
    'ru': 'Центрировать на моем GPS',
    'el': 'Εστίαση στη θέση μου',
    'pt': 'Centrar na minha localização GPS',
    'nl': 'Centreer op mijn GPS-positie',
  });

  String get sailboatMode => _t({
    'en': 'Sailboat',
    'tr': 'Yelkenli',
    'it': 'Barca a vela',
    'es': 'Velero',
    'fr': 'Voilier',
    'de': 'Segelboot',
    'ar': 'مركب شراعي',
    'ru': 'Парусник',
    'el': 'Ιστιοφόρο',
    'pt': 'Veleiro',
    'nl': 'Zeilboot',
  });

  String get motorYachtMode => _t({
    'en': 'Motor Yacht',
    'tr': 'Motor Yat',
    'it': 'Yacht a motore',
    'es': 'Yate de motor',
    'fr': 'Yacht à moteur',
    'de': 'Motoryacht',
    'ar': 'يخت بمحرك',
    'ru': 'Моторная яхта',
    'el': 'Μηχανοκίνητο σκάφος',
    'pt': 'Iate a Motor',
    'nl': 'Motorjacht',
  });

  String get tackRoute => _t({
    'en': 'SAILING TACKING ROUTE',
    'tr': 'YELKEN TRAMOLA ROTASI',
    'it': 'ROTTA DI VIRATA A VELA',
    'es': 'RUTA DE VIRAJE A VELA',
    'fr': 'ROUTE DE VIREMENT VOILE',
    'de': 'KREUZROUTE (SEGELN)',
    'ar': 'مسار مناورة الإبحار الشراعي',
    'ru': 'ЛАВИРОВОЧНЫЙ ПАРУСНЫЙ МАРШРУТ',
    'el': 'ΠΟΡΕΙΑ ΤΑΚ ΙΣΤΙΟΠΛΟΪΑΣ',
    'pt': 'ROTA DE BORDADA À VELA',
    'nl': 'ZEILROUTE MET SLAGEN',
  });

  String get directRoute => _t({
    'en': 'DIRECT PASSAGE ROUTE',
    'tr': 'DOĞRUDAN SEYİR ROTASI',
    'it': 'ROTTA DIRETTA',
    'es': 'RUTA DIRECTA',
    'fr': 'ROUTE DIRECTE',
    'de': 'DIREKTKURS',
    'ar': 'مسار العبور المباشر',
    'ru': 'ПРЯМОЙ КУРС',
    'el': 'ΑΠΕΥΘΕΙΑΣ ΠΟΡΕΙΑ',
    'pt': 'ROTA DIRETA',
    'nl': 'DIRECTE ROUTE',
  });

  String get shallowWaterLimit => _t({
    'en': 'Shallow Water Limit',
    'tr': 'Sığlık Limiti',
    'it': 'Limite Bassofondo',
    'es': 'Límite de Bajío',
    'fr': 'Limite Haut-fond',
    'de': 'Flachwassergrenze',
    'ar': 'حد المياه الضحلة',
    'ru': 'Предел мелководья',
    'el': 'Όριο ρηχών υδάτων',
    'pt': 'Limite de Baixio',
    'nl': 'Ondieptelimiet',
  });

  String get distance => _t({
    'en': 'Distance',
    'tr': 'Mesafe',
    'it': 'Distanza',
    'es': 'Distancia',
    'fr': 'Distance',
    'de': 'Distanz',
    'ar': 'المسافة',
    'ru': 'Дистанция',
    'el': 'Απόσταση',
    'pt': 'Distância',
    'nl': 'Afstand',
  });

  String get estimatedTime => _t({
    'en': 'Est. Time',
    'tr': 'Tahmini Süre',
    'it': 'Tempo Stim.',
    'es': 'Tiempo Est.',
    'fr': 'Temps Est.',
    'de': 'Gesch. Zeit',
    'ar': 'الوقت المقدر',
    'ru': 'Примерное время',
    'el': 'Εκτιμ. χρόνος',
    'pt': 'Tempo Estim.',
    'nl': 'Geschatte tijd',
  });

  String get hoursUnit => _t({
    'en': 'Hrs',
    'tr': 'Sa',
    'it': 'Ore',
    'es': 'Hs',
    'fr': 'h',
    'de': 'Std',
    'ar': 'ساعة',
    'ru': 'ч',
    'el': 'ώρες',
    'pt': 'h',
    'nl': 'uur',
  });

  String get fuelUsage => _t({
    'en': 'Est. Fuel',
    'tr': 'Yakıt',
    'it': 'Carburante',
    'es': 'Combustible',
    'fr': 'Carburant',
    'de': 'Treibstoff',
    'ar': 'الوقود المقدر',
    'ru': 'Топливо',
    'el': 'Καύσιμο',
    'pt': 'Combustível',
    'nl': 'Brandstof',
  });

  String get vmgSpeed => _t({
    'en': 'VMG Speed',
    'tr': 'VMG Hızı',
    'it': 'Velocità VMG',
    'es': 'Velocidad VMG',
    'fr': 'Vitesse VMG',
    'de': 'VMG-Geschwindigkeit',
    'ar': 'سرعة VMG',
    'ru': 'Скорость VMG',
    'el': 'Ταχύτητα VMG',
    'pt': 'Velocidade VMG',
    'nl': 'VMG-snelheid',
  });

  String get tackingNotice => _t({
    'en': 'Beating against wind ±45° dead angle prevented. Tacking zigzags calculated.',
    'tr': 'Rüzgara karşı ±45° kör açı engellendi. Tramola zikzakları ile varış hesaplandı.',
    'it': 'Navigazione controvento ±45° evitata. Calcolate virate a zig-zag.',
    'es': 'Ceñida contra el viento ±45° evitada. Bordadas en zigzag calculadas.',
    'fr': 'Angle mort ±45° contre le vent évité. Zig-zags de virement calculés.',
    'de': 'Gegenwind ±45° toter Winkel vermieden. Kreuzschläge berechnet.',
    'ar': 'تم تجنب الزاوية الميتة للرياح ±45 درجة. تم حساب مسار المناورة المتعرج.',
    'ru': 'Мертвый угол лавировки против ветра ±45° исключен. Рассчитаны галсы.',
    'el': 'Αποφυγή νεκρής γωνίας ±45°. Υπολογισμός τεθλασμένης πορείας τακ.',
    'pt': 'Evitado ângulo morto de ±45° contra o vento. Bordos calculados.',
    'nl': 'Dode hoek van ±45° tegen de wind vermeden. Slagen berekend.',
  });

  // Logbook
  String get logbookTitle => _t({
    'en': 'LOGBOOK',
    'tr': 'SEYİR DEFTERİ (LOGBOOK)',
    'it': 'GIORNALE DI BORDO',
    'es': 'DIARIO DE NAVEGACIÓN',
    'fr': 'LIVRE DE BORD',
    'de': 'LOGBUCH',
    'ar': 'سجل الملاحة',
    'ru': 'СУДОВОЙ ЖУРНАЛ',
    'el': 'ΗΜΕΡΟΛΟΓΙΟ ΠΛΟΙΟΥ',
    'pt': 'DIÁRIO DE BORDO',
    'nl': 'SCHEEPSLOGBOEK',
  });

  String get tripStatus => _t({
    'en': 'VOYAGE STATUS',
    'tr': 'SEYİR DURUMU',
    'it': 'STATO VIAGGIO',
    'es': 'ESTADO DEL VIAJE',
    'fr': 'STATUT VOYAGE',
    'de': 'FAHRTSTATUS',
    'ar': 'حالة الرحلة',
    'ru': 'СТАТУС ПЕРЕХОДА',
    'el': 'ΚΑΤΑΣΤΑΣΗ ΠΛΟΥ',
    'pt': 'ESTADO DA VIAGEM',
    'nl': 'REISSTATUS',
  });

  String get tripActive => _t({
    'en': 'RECORDING ACTIVE',
    'tr': 'SEYİR KAYDI AKTİF',
    'it': 'REGISTRAZIONE ATTIVA',
    'es': 'REGISTRO ACTIVO',
    'fr': 'ENREGISTREMENT ACTIF',
    'de': 'AUFZEICHNUNG AKTIV',
    'ar': 'التسجيل نشط',
    'ru': 'ЗАПИСЬ АКТИВНА',
    'el': 'ΚΑΤΑΓΡΑΦΗ ΕΝΕΡΓΗ',
    'pt': 'REGISTO ATIVO',
    'nl': 'OPNAME ACTIEF',
  });

  String get tripIdle => _t({
    'en': 'Standby',
    'tr': 'Beklemede',
    'it': 'In attesa',
    'es': 'En espera',
    'fr': 'En attente',
    'de': 'Bereit',
    'ar': 'في الانتظار',
    'ru': 'Ожидание',
    'el': 'Σε αναμονή',
    'pt': 'Em espera',
    'nl': 'Stand-by',
  });

  String get startNewTrip => _t({
    'en': 'START NEW VOYAGE',
    'tr': 'YENİ SEYİR BAŞLAT',
    'it': 'INIZIA NUOVO VIAGGIO',
    'es': 'INICIAR NUEVO VIAJE',
    'fr': 'COMMENCER NOUVEAU VOYAGE',
    'de': 'NEUE FAHRT STARTEN',
    'ar': 'بدء رحلة جديدة',
    'ru': 'НАЧАТЬ НОВЫЙ ПЕРЕХОД',
    'el': 'ΕΝΑΡΞΗ ΝΕΟΥ ΠΛΟΥ',
    'pt': 'INICIAR NOVA VIAGEM',
    'nl': 'START NIEUWE REIS',
  });

  String get stopTrip => _t({
    'en': 'FINISH VOYAGE & EXPORT GPX',
    'tr': 'SEYRİ TAMAMLA VE GPX ÇIKAR',
    'it': 'TERMINA VIAGGIO & ESPORTA GPX',
    'es': 'FINALIZAR VIAJE Y EXPORTAR GPX',
    'fr': 'TERMINER VOYAGE & EXPORTER GPX',
    'de': 'FAHRT BEENDEN & GPX EXPORTIEREN',
    'ar': 'إنهاء الرحلة وتصدير GPX',
    'ru': 'ЗАВЕРШИТЬ И ЭКСПОРТ GPX',
    'el': 'ΟΛΟΚΛΗΡΩΣΗ & ΕΞΑΓΩΓΗ GPX',
    'pt': 'TERMINAR VIAGEM & EXPORTAR GPX',
    'nl': 'BEËINDIG REIS & EXPORTEER GPX',
  });

  String get stopTripConfirmTitle => _t({
    'en': 'Finish Voyage?',
    'tr': 'Seyri Tamamla?',
    'it': 'Terminare il viaggio?',
    'es': '¿Finalizar el viaje?',
    'fr': 'Terminer le voyage ?',
    'de': 'Fahrt beenden?',
    'ar': 'هل تريد إنهاء الرحلة؟',
    'ru': 'Завершить переход?',
    'el': 'Ολοκλήρωση πλου;',
    'pt': 'Terminar a viagem?',
    'nl': 'Reis beëindigen?',
  });

  String get stopTripConfirmDesc => _t({
    'en': 'Stop background GPS logging, calculate voyage statistics and save GPX?',
    'tr': 'Arka plan GPS kaydını durdurup istatistikleri hesaplamak ve GPX oluşturmak istiyor musunuz?',
    'it': 'Interrompere la registrazione GPS, calcolare le statistiche e salvare il GPX?',
    'es': '¿Detener registro GPS, calcular estadísticas y guardar GPX?',
    'fr': 'Arrêter l\'enregistrement GPS, calculer les statistiques et enregistrer le GPX ?',
    'de': 'GPS-Aufzeichnung stoppen, Statistiken berechnen und GPX speichern?',
    'ar': 'إيقاف تسجيل GPS في الخلفية وحساب الإحصائيات وحفظ GPX؟',
    'ru': 'Остановить запись GPS, рассчитать статистику и сохранить GPX?',
    'el': 'Διακοπή καταγραφής GPS, υπολογισμός στατιστικών και αποθήκευση GPX;',
    'pt': 'Parar gravação GPS, calcular estatísticas e guardar GPX?',
    'nl': 'Stop GPS-registratie, bereken statistieken en sla GPX op?',
  });

  String get stopTripConfirmButton => _t({
    'en': 'Finish & Save',
    'tr': 'Tamamla ve Kaydet',
    'it': 'Termina e Salva',
    'es': 'Finalizar y Guardar',
    'fr': 'Terminer et Sauvegarder',
    'de': 'Beenden & Speichern',
    'ar': 'إنهاء وحفظ',
    'ru': 'Завершить и сохранить',
    'el': 'Ολοκλήρωση & Αποθήκευση',
    'pt': 'Terminar e Guardar',
    'nl': 'Beëindigen & Opslaan',
  });

  String get tripStartedMsg => _t({
    'en': 'Voyage tracking started in background!',
    'tr': 'Seyir kaydı arka planda başlatıldı!',
    'it': 'Tracciamento avviato in background!',
    'es': '¡Seguimiento iniciado en segundo plano!',
    'fr': 'Suivi démarré en arrière-plan !',
    'de': 'Hintergrund-Tracking gestartet!',
    'ar': 'تم بدء تسجيل الرحلة في الخلفية!',
    'ru': 'Запись перехода начата в фоне!',
    'el': 'Η καταγραφή ξεκίνησε στο παρασκήνιο!',
    'pt': 'Registo iniciado em segundo plano!',
    'nl': 'Reisregistratie gestart in de achtergrond!',
  });

  String get tripEndedMsg => _t({
    'en': 'Voyage completed! Distance: ',
    'tr': 'Seyir tamamlandı! Mesafe: ',
    'it': 'Viaggio completato! Distanza: ',
    'es': '¡Viaje completado! Distancia: ',
    'fr': 'Voyage terminé ! Distance : ',
    'de': 'Fahrt beendet! Distanz: ',
    'ar': 'اكتملت الرحلة! المسافة: ',
    'ru': 'Переход завершен! Дистанция: ',
    'el': 'Ο πλους ολοκληρώθηκε! Απόσταση: ',
    'pt': 'Viagem concluída! Distância: ',
    'nl': 'Reis voltooid! Afstand: ',
  });

  String get tripErrorMsg => _t({
    'en': 'Error: ',
    'tr': 'Hata: ',
    'it': 'Errore: ',
    'es': 'Error: ',
    'fr': 'Erreur : ',
    'de': 'Fehler: ',
    'ar': 'خطأ: ',
    'ru': 'Ошибка: ',
    'el': 'Σφάλμα: ',
    'pt': 'Erro: ',
    'nl': 'Fout: ',
  });

  String get pastTrips => _t({
    'en': 'PAST VOYAGES',
    'tr': 'GEÇMİŞ SEYİRLER',
    'it': 'VIAGGI PASSATI',
    'es': 'VIAJES ANTERIORES',
    'fr': 'VOYAGES PASSÉS',
    'de': 'VERGANGENE FAHRTEN',
    'ar': 'الرحلات السابقة',
    'ru': 'ПРОШЛЫЕ ПЕРЕХОДЫ',
    'el': 'ΠΡΟΗΓΟΥΜΕΝΟΙ ΠΛΟΕΣ',
    'pt': 'VIAGENS ANTERIORES',
    'nl': 'EERDERE REIZEN',
  });

  String get noTripsYet => _t({
    'en': 'No recorded voyages yet.',
    'tr': 'Henüz kaydedilmiş bir seyir yok.',
    'it': 'Nessun viaggio registrato ancora.',
    'es': 'No hay viajes registrados aún.',
    'fr': 'Aucun voyage enregistré pour le moment.',
    'de': 'Noch keine Fahrten aufgezeichnet.',
    'ar': 'لا توجد رحلات مسجلة حتى الآن.',
    'ru': 'Пока нет записанных переходов.',
    'el': 'Δεν υπάρχουν καταγεγραμμένοι πλόες.',
    'pt': 'Ainda não existem viagens registadas.',
    'nl': 'Nog geen geregistreerde reizen.',
  });

  String get tripCount => _t({
    'en': 'Trips',
    'tr': 'Kayıt',
    'it': 'Viaggi',
    'es': 'Viajes',
    'fr': 'Voyages',
    'de': 'Fahrten',
    'ar': 'رحلات',
    'ru': 'Записей',
    'el': 'Εγγραφές',
    'pt': 'Viagens',
    'nl': 'Reizen',
  });

  String get shareGpx => _t({
    'en': 'Share GPX',
    'tr': 'GPX Paylaş',
    'it': 'Condividi GPX',
    'es': 'Compartir GPX',
    'fr': 'Partager GPX',
    'de': 'GPX teilen',
    'ar': 'مشاركة GPX',
    'ru': 'Поделиться GPX',
    'el': 'Κοινοποίηση GPX',
    'pt': 'Partilhar GPX',
    'nl': 'Deel GPX',
  });

  String get deleteTrip => _t({
    'en': 'Delete',
    'tr': 'Sil',
    'it': 'Elimina',
    'es': 'Eliminar',
    'fr': 'Supprimer',
    'de': 'Löschen',
    'ar': 'حذف',
    'ru': 'Удалить',
    'el': 'Διαγραφή',
    'pt': 'Apagar',
    'nl': 'Verwijderen',
  });

  String get r2Synced => _t({
    'en': 'R2 Cloud Synced',
    'tr': 'R2 Bulut Senkron',
    'it': 'Sincronizzato R2',
    'es': 'Sincronizado R2',
    'fr': 'Synchronisé R2',
    'de': 'R2 synchronisiert',
    'ar': 'مزامنة سحابة R2',
    'ru': 'Синхронизировано R2',
    'el': 'Συγχρονισμένο R2',
    'pt': 'Sincronizado R2',
    'nl': 'R2 cloud gesynchroniseerd',
  });

  String get newTripDialogTitle => _t({
    'en': 'Start New Voyage',
    'tr': 'Yeni Seyir Başlat',
    'it': 'Inizia Nuovo Viaggio',
    'es': 'Iniciar Nuevo Viaje',
    'fr': 'Nouveau Voyage',
    'de': 'Neue Fahrt starten',
    'ar': 'بدء رحلة جديدة',
    'ru': 'Начать новый переход',
    'el': 'Έναρξη νέου πλου',
    'pt': 'Iniciar Nova Viagem',
    'nl': 'Start nieuwe reis',
  });

  String get newTripDialogDesc => _t({
    'en': 'GPS points are logged offline every 5 seconds even with screen off.',
    'tr': 'Ekran kapalıyken bile arka planda her 5 saniyede bir GPS noktası yerel veritabanına kaydedilir.',
    'it': 'I punti GPS vengono registrati ogni 5 secondi anche a schermo spento.',
    'es': 'Los puntos GPS se registran cada 5 segundos incluso con la pantalla apagada.',
    'fr': 'Points GPS enregistrés toutes les 5s même écran éteint.',
    'de': 'GPS-Punkte werden alle 5 Sekunden auch bei ausgeschaltetem Bildschirm erfasst.',
    'ar': 'يتم تسجيل نقاط GPS كل 5 ثوانٍ دون اتصال حتى عند إيقاف الشاشة.',
    'ru': 'Точки GPS записываются каждые 5 секунд даже при выключенном экране.',
    'el': 'Καταγραφή GPS κάθε 5 δευτερόλεπτα ακόμα και με κλειστή οθόνη.',
    'pt': 'Pontos GPS gravados a cada 5s mesmo com ecrã desligado.',
    'nl': 'GPS-punten worden elke 5s offline opgeslagen zelfs bij uitgeschakeld scherm.',
  });

  String get tripNameLabel => _t({
    'en': 'Voyage Title / Route',
    'tr': 'Seyir Adı / Rota',
    'it': 'Nome Viaggio / Rotta',
    'es': 'Nombre del Viaje / Ruta',
    'fr': 'Nom du Voyage / Route',
    'de': 'Fahrtname / Route',
    'ar': 'عنوان الرحلة / المسار',
    'ru': 'Название перехода / Маршрут',
    'el': 'Όνομα πλου / Διαδρομή',
    'pt': 'Nome da Viagem / Rota',
    'nl': 'Reisnaam / Route',
  });

  String get tripNameDefault => _t({
    'en': 'Coastal Passage',
    'tr': 'Bodrum - Gökova Seyri',
    'it': 'Passaggio Costiero',
    'es': 'Travesía Costera',
    'fr': 'Passage Côtier',
    'de': 'Küstentörn',
    'ar': 'رحلة ساحلية',
    'ru': 'Прибрежный переход',
    'el': 'Παράκτιος πλους',
    'pt': 'Travessia Costeira',
    'nl': 'Kustpassage',
  });

  String get vesselLabel => _t({
    'en': 'Vessel',
    'tr': 'Tekne',
    'it': 'Imbarcazione',
    'es': 'Embarcación',
    'fr': 'Navire',
    'de': 'Schiff',
    'ar': 'القارب',
    'ru': 'Судно',
    'el': 'Σκάφος',
    'pt': 'Embarcação',
    'nl': 'Schip',
  });

  String get cancelButton => _t({
    'en': 'Cancel',
    'tr': 'İptal',
    'it': 'Annulla',
    'es': 'Cancelar',
    'fr': 'Annuler',
    'de': 'Abbrechen',
    'ar': 'إلغاء',
    'ru': 'Отмена',
    'el': 'Άκυρο',
    'pt': 'Cancelar',
    'nl': 'Annuleren',
  });

  String get startButton => _t({
    'en': 'Start Voyage',
    'tr': 'Seyre Başla',
    'it': 'Salpa',
    'es': 'Zarpar',
    'fr': 'Appareiller',
    'de': 'Auslaufen',
    'ar': 'انطلاق',
    'ru': 'В путь',
    'el': 'Απόπλους',
    'pt': 'Largar amarras',
    'nl': 'Uitvaren',
  });

  String get maxSog => _t({
    'en': 'Max SOG',
    'tr': 'Max SOG',
    'it': 'Max SOG',
    'es': 'Máx SOG',
    'fr': 'Max SOG',
    'de': 'Max SOG',
    'ar': 'أقصى سرعة',
    'ru': 'Макс SOG',
    'el': 'Μέγ. SOG',
    'pt': 'Máx SOG',
    'nl': 'Max SOG',
  });

  String get avgSog => _t({
    'en': 'Avg SOG',
    'tr': 'Ortalama',
    'it': 'Media SOG',
    'es': 'Media SOG',
    'fr': 'Moyenne SOG',
    'de': 'Ø SOG',
    'ar': 'متوسط السرعة',
    'ru': 'Средн SOG',
    'el': 'Μέση SOG',
    'pt': 'Média SOG',
    'nl': 'Gem. SOG',
  });

  String get points => _t({
    'en': 'Points',
    'tr': 'Nokta',
    'it': 'Punti',
    'es': 'Puntos',
    'fr': 'Points',
    'de': 'Punkte',
    'ar': 'نقاط',
    'ru': 'Точки',
    'el': 'Σημεία',
    'pt': 'Pontos',
    'nl': 'Punten',
  });

  // Anchor Watch
  String get anchorTitle => _t({
    'en': 'ANCHOR WATCH & MOB',
    'tr': 'DEMİR ALARMI & MOB',
    'it': 'GUARDIA ANCORA & MOB',
    'es': 'ALARMA DE ANCLA Y MOB',
    'fr': 'VEILLE DE MOUILLAGE & MOB',
    'de': 'ANKERWACHE & MOB',
    'ar': 'مراقبة المرساة و MOB',
    'ru': 'АНКЕРНАЯ ВАХТА И MOB',
    'el': 'ΦΥΛΑΚΗ ΑΓΚΥΡΑΣ & MOB',
    'pt': 'VIGIA DE ÂNCORA & MOB',
    'nl': 'ANKERWACHT & MOB',
  });

  String get anchorLocked => _t({
    'en': 'ANCHOR WATCH ACTIVE',
    'tr': 'DEMİR ALARMI AKTİF',
    'it': 'GUARDIA ANCORA ATTIVA',
    'es': 'ALARMA DE ANCLA ACTIVA',
    'fr': 'ALARME ANCRE ACTIVE',
    'de': 'ANKERWACHE AKTIV',
    'ar': 'إنذار المرساة نشط',
    'ru': 'ЯКОРНАЯ ВАХТА АКТИВНА',
    'el': 'ΦΥΛΑΚΗ ΑΓΚΥΡΑΣ ΕΝΕΡΓΗ',
    'pt': 'VIGIA DE ÂNCORA ATIVA',
    'nl': 'ANKERWACHT ACTIEF',
  });

  String get anchorNotLocked => _t({
    'en': 'ANCHOR ALARM OFF',
    'tr': 'DEMİR ALARMI KAPALI',
    'it': 'GUARDIA ANCORA DISATTIVATA',
    'es': 'ALARMA DE ANCLA APAGADA',
    'fr': 'ALARME ANCRE DÉSACTIVÉE',
    'de': 'ANKERWACHE AUS',
    'ar': 'إنذار المرساة متوقف',
    'ru': 'ЯКОРНАЯ ВАХТА ВЫКЛЮЧЕНА',
    'el': 'ΦΥΛΑΚΗ ΑΓΚΥΡΑΣ ΑΝΕΝΕΡΓΗ',
    'pt': 'ALARME DE ÂNCORA DESLIGADO',
    'nl': 'ANKERWACHT UIT',
  });

  String get dropAnchor => _t({
    'en': 'DROP ANCHOR & LOCK GPS',
    'tr': 'DEMİR AT VE GPS KİLİTLE',
    'it': 'CALA ANCORA & BLOCCA GPS',
    'es': 'FONDEAR Y BLOQUEAR GPS',
    'fr': 'MOUILLER & VERROUILLER GPS',
    'de': 'ANKERN & GPS SPERREN',
    'ar': 'إلقاء المرساة وقفل GPS',
    'ru': 'ОТДАТЬ ЯКОРЬ И ЗАФИКСИРОВАТЬ GPS',
    'el': 'ΦΟΥΝΤΑΡΙΣΜΑ & ΚΛΕΙΔΩΜΑ GPS',
    'pt': 'LARGAR ÂNCORA & BLOQUEAR GPS',
    'nl': 'ANKER VALLEN & GPS VASTZETTEN',
  });

  String get raiseAnchor => _t({
    'en': 'WEIGH ANCHOR (DISABLE ALARM)',
    'tr': 'DEMİRİ AL (ALARMI KAPAT)',
    'it': 'SALPA ANCORA (DISATTIVA)',
    'es': 'LEVAR ANCLA (DESACTIVAR)',
    'fr': 'LEVER L\'ANCRE (DÉSACTIVER)',
    'de': 'ANKER LICHTEN (DEAKTIVIEREN)',
    'ar': 'رفع المرساة (تعطيل الإنذار)',
    'ru': 'ВЫБРАТЬ ЯКОРЬ (ОТКЛЮЧИТЬ)',
    'el': 'ΑΝΑΚΡΟΥΣΗ ΑΓΚΥΡΑΣ',
    'pt': 'LEVANTAR ÂNCORA (DESLIGAR)',
    'nl': 'ANKER LICHTEN (UITSCHAKELEN)',
  });

  String get radius => _t({
    'en': 'Swing Radius',
    'tr': 'Kaloma Dairesi',
    'it': 'Raggio di Giro',
    'es': 'Radio de Borneo',
    'fr': 'Rayon d\'évitage',
    'de': 'Schwojkreis',
    'ar': 'دائرة الحركة',
    'ru': 'Радиус циркуляции',
    'el': 'Ακτίνα περιστροφής',
    'pt': 'Raio de Giro',
    'nl': 'Draaicirkel',
  });

  String get currentDrift => _t({
    'en': 'Current Drift',
    'tr': 'Mevcut Sürüklenme',
    'it': 'Deriva Attuale',
    'es': 'Garreo Actual',
    'fr': 'Dérive Actuelle',
    'de': 'Aktuelle Abdrift',
    'ar': 'الانجراف الحالي',
    'ru': 'Текущий дрейф',
    'el': 'Τρέχουσα έκπτωση',
    'pt': 'Deriva Atual',
    'nl': 'Huidige verlijering',
  });

  String get mobEmergency => _t({
    'en': 'MAN OVERBOARD (MOB SOS)',
    'tr': 'DENİZE ADAM DÜŞTÜ (MOB SOS)',
    'it': 'UOMO IN MARE (MOB SOS)',
    'es': 'HOMBRE AL AGUA (MOB SOS)',
    'fr': 'HOMME À LA MER (MOB SOS)',
    'de': 'MANN ÜBER BORD (MOB SOS)',
    'ar': 'سقوط شخص في البحر (MOB SOS)',
    'ru': 'ЧЕЛОВЕК ЗА БОРТОМ (MOB SOS)',
    'el': 'ΑΝΘΡΩΠΟΣ ΣΤΗ ΘΑΛΑΣΣΑ (MOB SOS)',
    'pt': 'HOMEM AO MAR (MOB SOS)',
    'nl': 'MAN OVERBOORD (MOB SOS)',
  });

  String get mobActive => _t({
    'en': 'MOB POSITION LOCKED!',
    'tr': 'MOB NOKTASI KİLİTLENDİ!',
    'it': 'POSIZIONE MOB BLOCCATA!',
    'es': '¡POSICIÓN MOB BLOQUEADA!',
    'fr': 'POSITION MOB VERROUILLÉE !',
    'de': 'MOB-POSITION GESPERRT!',
    'ar': 'تم قفل موقع MOB!',
    'ru': 'ПОЗИЦИЯ MOB ЗАФИКСИРОВАНА!',
    'el': 'Η ΘΕΣΗ MOB ΚΛΕΙΔΩΘΗΚΕ!',
    'pt': 'POSIÇÃO MOB BLOQUEADA!',
    'nl': 'MOB-POSITIE VASTGEZET!',
  });

  String get mobReset => _t({
    'en': 'Reset MOB Alert',
    'tr': 'MOB Alarmını Sıfırla',
    'it': 'Resetta Allarme MOB',
    'es': 'Restablecer Alerta MOB',
    'fr': 'Réinitialiser Alerte MOB',
    'de': 'MOB-Alarm zurücksetzen',
    'ar': 'إعادة ضبط تنبيه MOB',
    'ru': 'Сбросить тревогу MOB',
    'el': 'Επαναφορά ειδοποίησης MOB',
    'pt': 'Repor Alerta MOB',
    'nl': 'Reset MOB-alarm',
  });

  // Settings
  String get settingsTitle => _t({
    'en': 'SETTINGS',
    'tr': 'AYARLAR',
    'it': 'IMPOSTAZIONI',
    'es': 'AJUSTES',
    'fr': 'PARAMÈTRES',
    'de': 'EINSTELLUNGEN',
    'ar': 'الإعدادات',
    'ru': 'НАСТРОЙКИ',
    'el': 'ΡΥΘΜΙΣΕΙΣ',
    'pt': 'AJUSTES',
    'nl': 'INSTELLINGEN',
  });

  String get languageSection => _t({
    'en': 'Language',
    'tr': 'Dil Seçimi',
    'it': 'Lingua',
    'es': 'Idioma',
    'fr': 'Langue',
    'de': 'Sprache',
    'ar': 'اللغة',
    'ru': 'Язык',
    'el': 'Γλώσσα',
    'pt': 'Idioma',
    'nl': 'Taal',
  });

  String get languageLabel => _t({
    'en': 'Application Language',
    'tr': 'Uygulama Dili',
    'it': 'Lingua dell\'applicazione',
    'es': 'Idioma de la aplicación',
    'fr': 'Langue de l\'application',
    'de': 'App-Sprache',
    'ar': 'لغة التطبيق',
    'ru': 'Язык приложения',
    'el': 'Γλώσσα εφαρμογής',
    'pt': 'Idioma da aplicação',
    'nl': 'App-taal',
  });

  String get themeSection => _t({
    'en': 'Theme & Appearance',
    'tr': 'Görünüm ve Tema',
    'it': 'Tema & Aspetto',
    'es': 'Tema y Apariencia',
    'fr': 'Thème & Apparence',
    'de': 'Design & Erscheinungsbild',
    'ar': 'المظهر والسمة',
    'ru': 'Тема и оформление',
    'el': 'Θέμα & Εμφάνιση',
    'pt': 'Tema & Aspeto',
    'nl': 'Thema & Weergave',
  });

  String get themeDark => _t({
    'en': 'Dark Navy (Marine)',
    'tr': 'Koyu Deniz (Lacivert)',
    'it': 'Blu Notte Marino',
    'es': 'Azul Marino Oscuro',
    'fr': 'Bleu Marine Sombre',
    'de': 'Dunkelblau Marine',
    'ar': 'أزرق داكن بحري',
    'ru': 'Темно-синий морской',
    'el': 'Σκούρο μπλε ναυτικό',
    'pt': 'Azul Escuro Marítimo',
    'nl': 'Donker marineblauw',
  });

  String get themeLight => _t({
    'en': 'Maritime Light (Daylight)',
    'tr': 'Açık Deniz (Gündüz)',
    'it': 'Luce Marittima (Giorno)',
    'es': 'Luz Marítima (Día)',
    'fr': 'Lumière Maritime (Jour)',
    'de': 'Helles Maritim (Tag)',
    'ar': 'نهاري فاتح',
    'ru': 'Светлый дневной морской',
    'el': 'Φωτεινό ναυτικό (Ημέρα)',
    'pt': 'Luz Marítima (Dia)',
    'nl': 'Licht maritiem (Dag)',
  });

  String get themeSystem => _t({
    'en': 'System Default',
    'tr': 'Sistem Varsayılanı',
    'it': 'Predefinito di Sistema',
    'es': 'Predeterminado del Sistema',
    'fr': 'Par Défaut du Système',
    'de': 'Systemstandard',
    'ar': 'افتراضي النظام',
    'ru': 'Системная тема',
    'el': 'Προεπιλογή συστήματος',
    'pt': 'Padrão do Sistema',
    'nl': 'Systeemstandaard',
  });

  String get themeNightVision => _t({
    'en': 'Night Vision Red (Nautical)',
    'tr': 'Kırmızı Gece Modu (Pusula Güvenliği)',
    'it': 'Visione Notturna Rossa',
    'es': 'Visión Nocturna Roja',
    'fr': 'Vision Nocturne Rouge',
    'de': 'Nachtsicht Rot (Nautisch)',
    'ar': 'الرؤية الليلية الحمراء',
    'ru': 'Ночной красный режим',
    'el': 'Κόκκινη νυχτερινή όραση',
    'pt': 'Visão Noturna Vermelha',
    'nl': 'Nachtzicht Rood (Nautisch)',
  });

  String get vesselProfileSection => _t({
    'en': 'Vessel Profile & Specs',
    'tr': 'Tekne Profili ve Özellikleri',
    'it': 'Profilo & Specifiche Imbarcazione',
    'es': 'Perfil y Especificaciones del Barco',
    'fr': 'Profil & Spécifications du Navire',
    'de': 'Schiffsprofil & Daten',
    'ar': 'ملف ومواصفات القارب',
    'ru': 'Профиль и данные судна',
    'el': 'Προφίλ & Στοιχεία σκάφους',
    'pt': 'Perfil e Especificações da Embarcação',
    'nl': 'Scheepsprofiel & Specificaties',
  });

  String get vesselType => _t({
    'en': 'Vessel Type',
    'tr': 'Tekne Tipi',
    'it': 'Tipo Imbarcazione',
    'es': 'Tipo de Barco',
    'fr': 'Type de Navire',
    'de': 'Schiffstyp',
    'ar': 'نوع القارب',
    'ru': 'Тип судна',
    'el': 'Τύπος σκάφους',
    'pt': 'Tipo de Embarcação',
    'nl': 'Scheepstype',
  });

  String get vesselDraft => _t({
    'en': 'Draft (Su Çekimi)',
    'tr': 'Su Çekimi (Draft)',
    'it': 'Pescaggio',
    'es': 'Calado',
    'fr': 'Tirant d\'eau',
    'de': 'Tiefgang',
    'ar': 'الغاطس',
    'ru': 'Осадка',
    'el': 'Βύθισμα',
    'pt': 'Calado',
    'nl': 'Diepgang',
  });

  String get noGoAngle => _t({
    'en': 'No-Go Beating Angle (±Deg)',
    'tr': 'Orsa Kör Açısı (±Derece)',
    'it': 'Angolo Morto Bolina (±Gradi)',
    'es': 'Ángulo Muerto de Ceñida (±Grados)',
    'fr': 'Angle Mort au Près (±Deg)',
    'de': 'Kreuz-Totwinkel (±Grad)',
    'ar': 'زاوية الرياح الميتة (±درجة)',
    'ru': 'Угол лавировки (±Град)',
    'el': 'Νεκρή γωνία όρτσα (±Μοίρες)',
    'pt': 'Ângulo Morto de Bolina (±Graus)',
    'nl': 'Dode hoek bij kruisen (±Graden)',
  });

  String get fuelBurnRate => _t({
    'en': 'Fuel Burn (L/h)',
    'tr': 'Yakıt Tüketimi (L/saat)',
    'it': 'Consumo (L/h)',
    'es': 'Consumo (L/h)',
    'fr': 'Consommation (L/h)',
    'de': 'Verbrauch (L/h)',
    'ar': 'استهلاك الوقود (لتر/ساعة)',
    'ru': 'Расход (л/ч)',
    'el': 'Κατανάλωση (L/h)',
    'pt': 'Consumo (L/h)',
    'nl': 'Verbruik (L/u)',
  });

  String get appInfoSection => _t({
    'en': 'About ViraNav',
    'tr': 'ViraNav Hakkında',
    'it': 'Informazioni su ViraNav',
    'es': 'Acerca de ViraNav',
    'fr': 'À propos de ViraNav',
    'de': 'Über ViraNav',
    'ar': 'حول فيراناف',
    'ru': 'О приложении ViraNav',
    'el': 'Σχετικά με το ViraNav',
    'pt': 'Sobre o ViraNav',
    'nl': 'Over ViraNav',
  });

  String get aboutViranav => _t({
    'en': 'ViraNav Marine Navigation',
    'tr': 'ViraNav Denizcilik Seyir Sistemi',
    'it': 'Navigazione Marittima ViraNav',
    'es': 'Navegación Marítima ViraNav',
    'fr': 'Navigation Maritime ViraNav',
    'de': 'ViraNav Maritimes Navigationssystem',
    'ar': 'فيراناف للملاحة البحرية',
    'ru': 'Морская навигационная система ViraNav',
    'el': 'Σύστημα ναυτιλίας ViraNav',
    'pt': 'Navegação Marítima ViraNav',
    'nl': 'ViraNav Maritieme Navigatie',
  });

  String get aboutViranavDesc => _t({
    'en': 'Offline-first marine HUD, weather routing and automated logbook.',
    'tr': 'Çevrimdışı öncelikli akıllı deniz kokpiti, hava durumu rotalama ve seyir defteri.',
    'it': 'HUD marittimo offline-first, rotte meteo e giornale di bordo automatico.',
    'es': 'HUD marino offline-first, enrutamiento meteorológico y diario automático.',
    'fr': 'HUD marin hors ligne, routage météo et journal de bord automatique.',
    'de': 'Offline-fähiges marines HUD, Wetter-Routing und automatisches Logbuch.',
    'ar': 'قمرة قيادة بحرية تعمل دون اتصال مع توجيه حسب الطقس وسجل تلقائي.',
    'ru': 'Офлайн морской HUD, метеорологическая прокладка курса и судовой журнал.',
    'el': 'Offline ναυτικό HUD, δρομολόγηση καιρού και αυτοματοποιημένο ημερολόγιο.',
    'pt': 'HUD marítimo offline-first, rotas meteorológicas e diário automático.',
    'nl': 'Offline-first maritieme HUD, weerroutering en automatisch logboek.',
  });

  // Metric Details Modal (like kdr.pedal)
  String get metricDetailTitle => _t({
    'en': 'Metric Detail & Marine Guide',
    'tr': 'Metrik Detayı ve Denizcilik Kılavuzu',
    'it': 'Dettagli Metrica & Guida Marina',
    'es': 'Detalle de Métrica y Guía Marina',
    'fr': 'Détail Métrique & Guide Marin',
    'de': 'Messwert-Details & Maritimer Leitfaden',
    'ar': 'تفاصيل المقياس والدليل البحري',
    'ru': 'Детали показателя и морской справочник',
    'el': 'Λεπτομέρειες μέτρησης & Ναυτικός οδηγός',
    'pt': 'Detalhes da Métrica & Guia Marítimo',
    'nl': 'Metriekdetails & Maritieme gids',
  });

  String get closeButton => _t({
    'en': 'Close',
    'tr': 'Kapat',
    'it': 'Chiudi',
    'es': 'Cerrar',
    'fr': 'Fermer',
    'de': 'Schließen',
    'ar': 'إغلاق',
    'ru': 'Закрыть',
    'el': 'Κλείσιμο',
    'pt': 'Fechar',
    'nl': 'Sluiten',
  });

  String get interpretation => _t({
    'en': 'Interpretation & Standard',
    'tr': 'Yorum ve Standart',
    'it': 'Interpretazione & Standard',
    'es': 'Interpretación y Estándar',
    'fr': 'Interprétation & Standard',
    'de': 'Interpretation & Standard',
    'ar': 'التفسير والمعيار',
    'ru': 'Интерпретация и стандарт',
    'el': 'Ερμηνεία & Πρότυπο',
    'pt': 'Interpretação & Padrão',
    'nl': 'Interpretatie & Standaard',
  });

  String get safetyAdvice => _t({
    'en': 'Skipper Advice & Safety',
    'tr': 'Kaptan Tavsiyesi & Güvenlik',
    'it': 'Consigli Skipper & Sicurezza',
    'es': 'Consejos del Patrón y Seguridad',
    'fr': 'Conseil Skipper & Sécurité',
    'de': 'Skipper-Tipps & Sicherheit',
    'ar': 'نصائح القبطان والسلامة',
    'ru': 'Совет шкипера и безопасность',
    'el': 'Συμβουλή κυβερνήτη & Ασφάλεια',
    'pt': 'Conselho do Capitão & Segurança',
    'nl': 'Schipperstips & Veiligheid',
  });

  String get unitDetails => _t({
    'en': 'Converted Units',
    'tr': 'Dönüştürülmüş Birimler',
    'it': 'Unità Convertite',
    'es': 'Unidades Convertidas',
    'fr': 'Unités Converties',
    'de': 'Umgerechnete Einheiten',
    'ar': 'الوحدات المحولة',
    'ru': 'Конвертированные единицы',
    'el': 'Μετατροπές μονάδων',
    'pt': 'Unidades Convertidas',
    'nl': 'Omgerekende eenheden',
  });
}

class LocaleNotifier extends Notifier<String> {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English (Default)', flag: '🇬🇧'),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    AppLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά', flag: '🇬🇷'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
  ];

  @override
  String build() {
    _loadSavedLanguage();
    // DEFAULT IS STRICTLY ENGLISH AS PER USER SPECIFICATION!
    return 'en';
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final db = DatabaseService();
      final saved = await db.getSetting('app_language');
      if (saved != null && supportedLanguages.any((l) => l.code == saved)) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (supportedLanguages.any((l) => l.code == code)) {
      state = code;
      try {
        final db = DatabaseService();
        await db.setSetting('app_language', code);
      } catch (_) {}
    }
  }

  bool get isRtl => state == 'ar';
}

final languageProvider = NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);

final stringsProvider = Provider<ViraNavStrings>((ref) {
  final langCode = ref.watch(languageProvider);
  return ViraNavStrings(langCode);
});

final isRtlProvider = Provider<bool>((ref) {
  final langCode = ref.watch(languageProvider);
  return langCode == 'ar';
});

typedef AppStrings = ViraNavStrings;
