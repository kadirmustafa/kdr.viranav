# ViraNav - Denizcilik Seyir, Hava ve Logbook Mobil Uygulaması

Modern denizciler, yelkenli ve motor yat kaptanları için geliştirilmiş cross-platform (Flutter) mobil navigasyon, canlı kokpit ve çevrimdışı seyir defteri uygulaması.

---

## 🛥️ Temel Modüller

1. **Canlı Deniz Kokpiti (Glass Cockpit / HUD):**
   * Yer Hızı (SOG), Pusula (HDG), Rota (COG), Gerçek Rüzgar (TWS & TWD).
   * Rüzgar Gülü ve Yelken Tramola (No-Go Zone ±45°) göstergesi.
   * Belirgin dalga yüksekliği ($H_s$), dalga periyodu ($T_p$) ve yüzey akıntısı.
   * Barometrik basınç & ani düşüş fırtına uyarı alarmı.
   * Retinayı koruyan **Kırmızı Gece Görüş Modu (Night Vision)**.

2. **Akıllı Rota & Yelken (Weather Routing):**
   * Yelkenli Modunda rüzgara karşı kör açıyı engelleyip VMG maksimizasyonu ile tramola (tacking) rotası çizer.
   * Motor Yat Modunda rüzgardan bağımsız en kısa rotayı ve tahmini yakıt tüketimini hesaplar.
   * Tekne su çekimi (draft) + 1.5m tampon derinlik kontrolü.
   * OpenSeaMap Seamarks (şamandıralar, fenerler) deniz harita katmanı.

3. **Çevrimdışı Seyir Defteri (Offline-First Logbook):**
   * 5 saniyede bir GPS koordinatlarını yerel SQLite veritabanına yazar.
   * **Sıfır Maliyet Kuralı:** Seyir bittiğinde standart GPX 1.1 formatına çevirip Cloudflare R2'ye yükler.
   * GPX / KML paylaşımı ve seyir özetleri.

4. **Demir Alarmı & Güvenlik (Anchor Watch & MOB):**
   * Emniyet dairesi ve kaloma mesafesi denetimi ile çapa tarama alarmı.
   * Tek dokunuşla **MOB (Man Overboard)** acil kilitleme ve geri dönüş kerteriz vektörü.
   * 10 maddelik seyir öncesi güvenlik kontrol listesi (Checklist).

---

## 🚀 CI/CD & Firebase App Distribution (GitHub Actions)

Projede `.github/workflows/firebase_app_distribution.yml` iş akışı bulunmaktadır.

### GitHub Repository Secrets Yapılandırması:
GitHub deponuzda **Settings -> Secrets and variables -> Actions** menüsüne aşağıdaki gizli anahtarları ekleyin:

1. `FIREBASE_APP_ID`: Firebase Console -> Project Settings -> Your Apps -> Android App ID (örn: `1:1234567890:android:abcdef123456`)
2. `FIREBASE_SERVICE_CREDENTIALS`: Google Cloud Console / Firebase Service Account JSON dosyasının tamamı (`Firebase App Distribution Admin` yetkisine sahip servis hesabı).

### Otomatik Dağıtım:
* `main` veya `master` branch'ine `push` yapıldığında veya GitHub Actions arayüzünden manuel tetiklendiğinde APK derlenir.
* `kadirmo@gmail.com` test kullanıcısına otomatik davet ve APK yükleme bağlantısı gönderilir.

---

## 🛠️ Yerel Geliştirme

```bash
# Bağımlılıkları yükleyin
flutter pub get

# Testleri ve analizleri çalıştırın
flutter analyze
flutter test

# Uygulamayı çalıştırın
flutter run
```
