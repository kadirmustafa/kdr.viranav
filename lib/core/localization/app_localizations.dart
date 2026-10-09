import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/services/database_service.dart';

enum AppLanguage {
  en, // English - Default
  tr, // Türkçe
}

class AppStrings {
  // Navigation Tabs
  final String navCockpit;
  final String navMap;
  final String navLogbook;
  final String navAnchor;
  final String navSettings;

  // Cockpit
  final String cockpitTitle;
  final String activeTripRibbon;
  final String pointsCountLabel;
  final String locationGps;
  final String sogLabel;
  final String hdgLabel;
  final String cogLabel;
  final String twsLabel;
  final String underWay;
  final String anchoredMoored;
  final String trueCourse;
  final String beaufort;
  final String waveHeight;
  final String wavePeriod;
  final String surfaceCurrent;
  final String significantHs;
  final String waveSec;
  final String knotsUnit;
  final String currentDirection;
  final String windRoseTitle;
  final String noGoZone;
  final String optimumTack;
  final String barometerTitle;
  final String pressureLabel;
  final String tempLabel;
  final String humidityLabel;
  final String stormAlert;
  final String normalPressure;
  final String stormWarningDesc;
  final String normalPressureDesc;

  // Map
  final String mapTitle;
  final String myLocation;
  final String locateMeTooltip;
  final String sailboatMode;
  final String motorYachtMode;
  final String tackRoute;
  final String directRoute;
  final String shallowWaterLimit;
  final String distance;
  final String estimatedTime;
  final String hoursUnit;
  final String fuelUsage;
  final String vmgSpeed;
  final String tackingNotice;

  // Logbook
  final String logbookTitle;
  final String tripStatus;
  final String tripActive;
  final String tripIdle;
  final String startNewTrip;
  final String stopTrip;
  final String stopTripConfirmTitle;
  final String stopTripConfirmDesc;
  final String stopTripConfirmButton;
  final String tripStartedMsg;
  final String tripEndedMsg;
  final String tripErrorMsg;
  final String pastTrips;
  final String noTripsYet;
  final String tripCount;
  final String shareGpx;
  final String deleteTrip;
  final String r2Synced;
  final String newTripDialogTitle;
  final String newTripDialogDesc;
  final String tripNameLabel;
  final String tripNameDefault;
  final String vesselLabel;
  final String cancelButton;
  final String startButton;
  final String maxSog;
  final String avgSog;
  final String points;

  // Anchor Watch
  final String anchorTitle;
  final String anchorLocked;
  final String anchorNotLocked;
  final String dropAnchor;
  final String raiseAnchor;
  final String radius;
  final String currentDrift;
  final String safeStatus;
  final String dragAlarm;
  final String mobEmergency;
  final String mobActive;
  final String mobReset;

  // Settings
  final String settingsTitle;
  final String languageSection;
  final String languageLabel;
  final String themeSection;
  final String themeLabel;
  final String themeDark;
  final String themeLight;
  final String themeSystem;
  final String themeNightVision;
  final String vesselProfileSection;
  final String vesselType;
  final String vesselName;
  final String vesselDraft;
  final String noGoAngle;
  final String fuelBurnRate;
  final String safetyChecklist;
  final String safetyChecklistDesc;
  final String appInfoSection;
  final String appVersion;
  final String aboutViranav;
  final String aboutViranavDesc;
  final String savedSuccess;

  // Metric Details Modal (like kdr.pedal)
  final String metricDetailTitle;
  final String closeButton;
  final String interpretation;
  final String safetyAdvice;
  final String unitDetails;

  const AppStrings({
    required this.navCockpit,
    required this.navMap,
    required this.navLogbook,
    required this.navAnchor,
    required this.navSettings,
    required this.cockpitTitle,
    required this.activeTripRibbon,
    required this.pointsCountLabel,
    required this.locationGps,
    required this.sogLabel,
    required this.hdgLabel,
    required this.cogLabel,
    required this.twsLabel,
    required this.underWay,
    required this.anchoredMoored,
    required this.trueCourse,
    required this.beaufort,
    required this.waveHeight,
    required this.wavePeriod,
    required this.surfaceCurrent,
    required this.significantHs,
    required this.waveSec,
    required this.knotsUnit,
    required this.currentDirection,
    required this.windRoseTitle,
    required this.noGoZone,
    required this.optimumTack,
    required this.barometerTitle,
    required this.pressureLabel,
    required this.tempLabel,
    required this.humidityLabel,
    required this.stormAlert,
    required this.normalPressure,
    required this.stormWarningDesc,
    required this.normalPressureDesc,
    required this.mapTitle,
    required this.myLocation,
    required this.locateMeTooltip,
    required this.sailboatMode,
    required this.motorYachtMode,
    required this.tackRoute,
    required this.directRoute,
    required this.shallowWaterLimit,
    required this.distance,
    required this.estimatedTime,
    required this.hoursUnit,
    required this.fuelUsage,
    required this.vmgSpeed,
    required this.tackingNotice,
    required this.logbookTitle,
    required this.tripStatus,
    required this.tripActive,
    required this.tripIdle,
    required this.startNewTrip,
    required this.stopTrip,
    required this.stopTripConfirmTitle,
    required this.stopTripConfirmDesc,
    required this.stopTripConfirmButton,
    required this.tripStartedMsg,
    required this.tripEndedMsg,
    required this.tripErrorMsg,
    required this.pastTrips,
    required this.noTripsYet,
    required this.tripCount,
    required this.shareGpx,
    required this.deleteTrip,
    required this.r2Synced,
    required this.newTripDialogTitle,
    required this.newTripDialogDesc,
    required this.tripNameLabel,
    required this.tripNameDefault,
    required this.vesselLabel,
    required this.cancelButton,
    required this.startButton,
    required this.maxSog,
    required this.avgSog,
    required this.points,
    required this.anchorTitle,
    required this.anchorLocked,
    required this.anchorNotLocked,
    required this.dropAnchor,
    required this.raiseAnchor,
    required this.radius,
    required this.currentDrift,
    required this.safeStatus,
    required this.dragAlarm,
    required this.mobEmergency,
    required this.mobActive,
    required this.mobReset,
    required this.settingsTitle,
    required this.languageSection,
    required this.languageLabel,
    required this.themeSection,
    required this.themeLabel,
    required this.themeDark,
    required this.themeLight,
    required this.themeSystem,
    required this.themeNightVision,
    required this.vesselProfileSection,
    required this.vesselType,
    required this.vesselName,
    required this.vesselDraft,
    required this.noGoAngle,
    required this.fuelBurnRate,
    required this.safetyChecklist,
    required this.safetyChecklistDesc,
    required this.appInfoSection,
    required this.appVersion,
    required this.aboutViranav,
    required this.aboutViranavDesc,
    required this.savedSuccess,
    required this.metricDetailTitle,
    required this.closeButton,
    required this.interpretation,
    required this.safetyAdvice,
    required this.unitDetails,
  });

  static const AppStrings en = AppStrings(
    navCockpit: 'Cockpit',
    navMap: 'Map',
    navLogbook: 'Logbook',
    navAnchor: 'Anchor',
    navSettings: 'Settings',
    cockpitTitle: 'VIRANAV COCKPIT',
    activeTripRibbon: 'ACTIVE VOYAGE',
    pointsCountLabel: 'GPS points',
    locationGps: 'Marine GPS Location',
    sogLabel: 'Speed Over Ground (SOG)',
    hdgLabel: 'Compass Heading (HDG)',
    cogLabel: 'Course Over Ground (COG)',
    twsLabel: 'True Wind Speed (TWS)',
    underWay: 'Underway',
    anchoredMoored: 'Moored / Anchored',
    trueCourse: 'GPS Track Course',
    beaufort: 'Beaufort',
    waveHeight: 'Wave Height (Hs)',
    wavePeriod: 'Wave Period (Tp)',
    surfaceCurrent: 'Surface Current',
    significantHs: 'Significant Hs',
    waveSec: 'Sec Period',
    knotsUnit: 'KTS',
    currentDirection: 'Set Direction',
    windRoseTitle: 'WIND ROSE & TACK INDICATOR',
    noGoZone: 'No-Go Zone (Dead Angle)',
    optimumTack: 'Optimal Tack Angle',
    barometerTitle: 'BAROMETRIC PRESSURE & FORECAST',
    pressureLabel: 'Atmospheric Pressure',
    tempLabel: 'Air Temperature',
    humidityLabel: 'Relative Humidity',
    stormAlert: 'RAPID DROP STORM WARNING!',
    normalPressure: 'Pressure Steady / Good Seakeeping',
    stormWarningDesc: 'Pressure dropped >3 hPa in last 3 hours. Squall/gale front approaching.',
    normalPressureDesc: 'Stable barometric trend. Favorable nautical weather conditions.',
    mapTitle: 'NAVIGATION CHART & ROUTE',
    myLocation: 'My Location',
    locateMeTooltip: 'Center on my GPS location',
    sailboatMode: 'Sailboat',
    motorYachtMode: 'Motor Yacht',
    tackRoute: 'SAILING TACKING ROUTE',
    directRoute: 'DIRECT PASSAGE ROUTE',
    shallowWaterLimit: 'Shallow Water Buffer',
    distance: 'Distance',
    estimatedTime: 'Est. Time',
    hoursUnit: 'Hrs',
    fuelUsage: 'Est. Fuel',
    vmgSpeed: 'VMG Speed',
    tackingNotice: 'Beating against wind ±45° dead angle prevented. Tacking zigzags calculated.',
    logbookTitle: 'LOGBOOK',
    tripStatus: 'VOYAGE STATUS',
    tripActive: 'RECORDING ACTIVE',
    tripIdle: 'STANDBY',
    startNewTrip: 'START NEW VOYAGE',
    stopTrip: 'FINISH VOYAGE & EXPORT GPX',
    stopTripConfirmTitle: 'Finish Voyage?',
    stopTripConfirmDesc: 'Do you want to stop background GPS recording, calculate totals and generate GPX?',
    stopTripConfirmButton: 'Finish & Save',
    tripStartedMsg: 'Voyage tracking started in background!',
    tripEndedMsg: 'Voyage completed! Distance: ',
    tripErrorMsg: 'Error: ',
    pastTrips: 'PAST VOYAGES',
    noTripsYet: 'No recorded voyages yet.',
    tripCount: 'Trips',
    shareGpx: 'Share GPX',
    deleteTrip: 'Delete',
    r2Synced: 'R2 Cloud Synced',
    newTripDialogTitle: 'Start New Voyage',
    newTripDialogDesc: 'GPS points are logged offline every 5 seconds even with screen off.',
    tripNameLabel: 'Voyage Title / Route',
    tripNameDefault: 'Aegean Coastal Voyage',
    vesselLabel: 'Vessel',
    cancelButton: 'Cancel',
    startButton: 'Start Voyage',
    maxSog: 'Max SOG',
    avgSog: 'Avg SOG',
    points: 'Points',
    anchorTitle: 'ANCHOR WATCH & MOB',
    anchorLocked: 'ANCHOR WATCH ACTIVE',
    anchorNotLocked: 'ANCHOR ALARM OFF',
    dropAnchor: 'DROP ANCHOR & LOCK GPS',
    raiseAnchor: 'WEIGH ANCHOR (DISABLE ALARM)',
    radius: 'Swing Radius',
    currentDrift: 'Current Drift',
    safeStatus: 'Vessel is safely within swinging circle.',
    dragAlarm: 'DRAG ALARM TRIGGERED! VESSEL DRIFTING!',
    mobEmergency: 'MAN OVERBOARD (MOB SOS)',
    mobActive: 'MOB POSITION LOCKED!',
    mobReset: 'Reset MOB Alert',
    settingsTitle: 'SETTINGS & PREFERENCES',
    languageSection: 'Language / Dil',
    languageLabel: 'Application Language',
    themeSection: 'Theme & Appearance',
    themeLabel: 'Color Theme',
    themeDark: 'Dark Navy (Marine)',
    themeLight: 'Maritime Light (Daylight)',
    themeSystem: 'System Default',
    themeNightVision: 'Night Vision Red (Nautical)',
    vesselProfileSection: 'Vessel Profile & Specs',
    vesselType: 'Vessel Type',
    vesselName: 'Vessel Name',
    vesselDraft: 'Draft (Su Çekimi)',
    noGoAngle: 'No-Go Beating Angle (±Deg)',
    fuelBurnRate: 'Fuel Consumption (L/h)',
    safetyChecklist: 'Pre-Voyage Safety Checklist',
    safetyChecklistDesc: 'Review bilge, engine oil, seacocks, VHF and life jackets',
    appInfoSection: 'About ViraNav',
    appVersion: 'Version',
    aboutViranav: 'ViraNav Marine Navigation',
    aboutViranavDesc: 'Offline-first marine HUD, weather routing and automated logbook.',
    savedSuccess: 'Settings updated successfully.',
    metricDetailTitle: 'Metric Detail & Marine Guide',
    closeButton: 'Close',
    interpretation: 'Interpretation & Standard',
    safetyAdvice: 'Skipper Advice & Safety',
    unitDetails: 'Converted Units',
  );

  static const AppStrings tr = AppStrings(
    navCockpit: 'Kokpit',
    navMap: 'Harita',
    navLogbook: 'Defter',
    navAnchor: 'Demir',
    navSettings: 'Ayarlar',
    cockpitTitle: 'VIRANAV KOKPİT',
    activeTripRibbon: 'SEYİR KAYDI AKTİF',
    pointsCountLabel: 'GPS noktası',
    locationGps: 'Deniz GPS Konumu',
    sogLabel: 'Yer Hızı (SOG)',
    hdgLabel: 'Pusula Açısı (HDG)',
    cogLabel: 'Rota Açısı (COG)',
    twsLabel: 'Gerçek Rüzgar (TWS)',
    underWay: 'Seyir Hali',
    anchoredMoored: 'Demirde / Rıhtımda',
    trueCourse: 'GPS İz Rotası',
    beaufort: 'Bft',
    waveHeight: 'Dalga Boyu (Hs)',
    wavePeriod: 'Dalga Periyodu (Tp)',
    surfaceCurrent: 'Yüzey Akıntısı',
    significantHs: 'Hs Belirgin',
    waveSec: 'SN Periyot',
    knotsUnit: 'KTS',
    currentDirection: 'Akıntı Yönü',
    windRoseTitle: 'RÜZGAR GÜLÜ & TRAMOLA (TACK) GÖSTERGESİ',
    noGoZone: 'Kör Nokta (No-Go Zone)',
    optimumTack: 'En İyi Tramola Açısı',
    barometerTitle: 'BAROMETRİK BASINÇ & TAHMİN',
    pressureLabel: 'Atmosfer Basıncı',
    tempLabel: 'Hava Sıcaklığı',
    humidityLabel: 'Bağıl Nem',
    stormAlert: 'ANİ BASINÇ DÜŞÜŞÜ - FIRTINA UYARISI!',
    normalPressure: 'Basınç Kararlı / Seyre Uygun',
    stormWarningDesc: 'Son 3 saatte >3 hPa düşüş tespit edildi. Fırtına veya sağanak cephesi yaklaşıyor.',
    normalPressureDesc: 'İstikrarlı barometre trendi. Deniz şartları genel seyre elverişli.',
    mapTitle: 'SEYİR HARİTASI & ROTA',
    myLocation: 'Konumum',
    locateMeTooltip: 'Beni GPS konumuma odakla',
    sailboatMode: 'Yelkenli',
    motorYachtMode: 'Motor Yat',
    tackRoute: 'YELKEN TRAMOLA ROTASI',
    directRoute: 'DOĞRUDAN SEYİR ROTASI',
    shallowWaterLimit: 'Sığlık Limiti',
    distance: 'Mesafe',
    estimatedTime: 'Tahmini Süre',
    hoursUnit: 'Sa',
    fuelUsage: 'Yakıt Tüketimi',
    vmgSpeed: 'VMG Hızı',
    tackingNotice: 'Rüzgara karşı ±45° kör açı engellendi. Tramola zikzakları ile varış hesaplandı.',
    logbookTitle: 'SEYİR DEFTERİ (LOGBOOK)',
    tripStatus: 'SEYİR DURUMU',
    tripActive: 'SEYİR KAYDI AKTİF',
    tripIdle: 'Beklemede',
    startNewTrip: 'YENİ SEYİR BAŞLAT',
    stopTrip: 'SEYRİ TAMAMLA VE GPX ÇIKAR',
    stopTripConfirmTitle: 'Seyri Tamamla?',
    stopTripConfirmDesc: 'Arka plan GPS kaydını durdurup istatistikleri hesaplamak ve GPX oluşturmak istiyor musunuz?',
    stopTripConfirmButton: 'Tamamla ve Kaydet',
    tripStartedMsg: 'Seyir kaydı arka planda başlatıldı!',
    tripEndedMsg: 'Seyir tamamlandı! Mesafe: ',
    tripErrorMsg: 'Hata: ',
    pastTrips: 'GEÇMİŞ SEYİRLER',
    noTripsYet: 'Henüz kaydedilmiş bir seyir yok.',
    tripCount: 'Kayıt',
    shareGpx: 'GPX Paylaş',
    deleteTrip: 'Sil',
    r2Synced: 'R2 Bulut Senkron',
    newTripDialogTitle: 'Yeni Seyir Başlat',
    newTripDialogDesc: 'Ekran kapalıyken bile arka planda her 5 saniyede bir GPS noktası yerel veritabanına kaydedilir.',
    tripNameLabel: 'Seyir Adı / Rota',
    tripNameDefault: 'Bodrum - Gökova Seyri',
    vesselLabel: 'Tekne',
    cancelButton: 'İptal',
    startButton: 'Seyre Başla',
    maxSog: 'Max SOG',
    avgSog: 'Ortalama',
    points: 'Nokta',
    anchorTitle: 'DEMİR ALARMI & MOB',
    anchorLocked: 'DEMİR ALARMI AKTİF',
    anchorNotLocked: 'DEMİR ALARMI KAPALI',
    dropAnchor: 'DEMİR AT VE GPS KİLİTLE',
    raiseAnchor: 'DEMİRİ AL (ALARMI KAPAT)',
    radius: 'Kaloma Dairesi',
    currentDrift: 'Mevcut Sürüklenme',
    safeStatus: 'Tekne güvenle demirleme dairesi içinde.',
    dragAlarm: 'DEMİR TARAMA UYARISI! TEKNE SÜRÜKLENİYOR!',
    mobEmergency: 'DENİZE ADAM DÜŞTÜ (MOB SOS)',
    mobActive: 'MOB NOKTASI KİLİTLENDİ!',
    mobReset: 'MOB Alarmını Sıfırla',
    settingsTitle: 'AYARLAR VE TERCİHLER',
    languageSection: 'Dil Seçimi',
    languageLabel: 'Uygulama Dili',
    themeSection: 'Görünüm ve Tema',
    themeLabel: 'Renk Teması',
    themeDark: 'Koyu Deniz (Lacivert)',
    themeLight: 'Açık Deniz (Gündüz)',
    themeSystem: 'Sistem Varsayılanı',
    themeNightVision: 'Kırmızı Gece Modu (Pusula Güvenliği)',
    vesselProfileSection: 'Tekne Profili ve Özellikleri',
    vesselType: 'Tekne Tipi',
    vesselName: 'Tekne Adı',
    vesselDraft: 'Su Çekimi (Draft)',
    noGoAngle: 'Orsa Kör Açısı (±Derece)',
    fuelBurnRate: 'Yakıt Tüketimi (L/saat)',
    safetyChecklist: 'Seyir Öncesi Güvenlik Kontrolü',
    safetyChecklistDesc: 'Sintine, motor yağı, vanalar, telsiz ve can yeleği kontrolleri',
    appInfoSection: 'ViraNav Hakkında',
    appVersion: 'Sürüm',
    aboutViranav: 'ViraNav Denizcilik Seyir Sistemi',
    aboutViranavDesc: 'Çevrimdışı öncelikli akıllı deniz kokpiti, hava durumu rotalama ve seyir defteri.',
    savedSuccess: 'Ayarlar başarıyla güncellendi.',
    metricDetailTitle: 'Metrik Detayı ve Denizcilik Kılavuzu',
    closeButton: 'Kapat',
    interpretation: 'Yorum ve Standart',
    safetyAdvice: 'Kaptan Tavsiyesi & Güvenlik',
    unitDetails: 'Dönüştürülmüş Birimler',
  );
}

class LocaleNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    _loadSavedLanguage();
    // DEFAULT IS STRICTLY ENGLISH AS PER USER SPECIFICATION!
    return AppLanguage.en;
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final db = DatabaseService();
      final saved = await db.getSetting('app_language');
      if (saved == 'tr') {
        state = AppLanguage.tr;
      } else if (saved == 'en') {
        state = AppLanguage.en;
      }
      // If none saved, it remains AppLanguage.en (English)
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final db = DatabaseService();
      await db.setSetting('app_language', language == AppLanguage.tr ? 'tr' : 'en');
    } catch (_) {}
  }

  AppStrings get strings => state == AppLanguage.tr ? AppStrings.tr : AppStrings.en;
}

final languageProvider = NotifierProvider<LocaleNotifier, AppLanguage>(LocaleNotifier.new);

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(languageProvider);
  return lang == AppLanguage.tr ? AppStrings.tr : AppStrings.en;
});
