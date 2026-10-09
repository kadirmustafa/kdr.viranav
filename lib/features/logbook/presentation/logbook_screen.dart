import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'package:viranav/features/logbook/domain/trip.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final repo = ref.read(tripRepositoryProvider);
    final list = await repo.getAllTrips();
    setState(() {
      _trips = list;
      _isLoading = false;
    });
  }

  void _showStartTripDialog() {
    final vessel = ref.read(vesselProvider);
    final textController = TextEditingController(
      text: 'Bodrum - Gökova Seyri',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Seyir Başlat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ekran kapalıyken bile arka planda her 5 saniyede bir GPS noktası yerel veritabanına kaydedilir.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Seyir Adı / Rota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text('Tekne: ${vessel.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final tripId = const Uuid().v4();
              try {
                await ref.read(trackingServiceProvider).startTrip(
                  tripId: tripId,
                  title: textController.text.trim().isEmpty
                      ? 'Seyir'
                      : textController.text.trim(),
                  vesselName: vessel.name,
                );
                await _loadTrips();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seyir kaydı arka planda başlatıldı!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Seyre Başla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNightVision = ref.watch(themeModeProvider) == NavThemeMode.nightVisionRed;
    final trackingState = ref.watch(trackingStateStreamProvider).value ??
        ref.read(trackingServiceProvider).currentState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEYİR DEFTERİ (LOGBOOK)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Voyage Recording Card
              Card(
                color: trackingState.isTracking
                    ? (isNightVision ? AppTheme.nightCard : const Color(0xFF0F3254))
                    : theme.cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                trackingState.isTracking ? Icons.fiber_manual_record : Icons.trip_origin,
                                color: trackingState.isTracking
                                    ? Colors.redAccent
                                    : (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                trackingState.isTracking ? 'SEYİR KAYDI AKTİF' : 'SEYİR DURUMU',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: trackingState.isTracking
                                  ? Colors.redAccent.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              trackingState.isTracking ? '5s GPS Kayıt' : 'Beklemede',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: trackingState.isTracking ? Colors.redAccent : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (trackingState.isTracking) ...[
                        Text(
                          trackingState.currentTrip?.title ?? 'Aktif Seyir',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kaydedilen Nokta: ${trackingState.pointsLogged}  |  Anlık Hız: ${trackingState.currentSogKnots.toStringAsFixed(1)} kn',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.stop),
                            label: const Text('SEYRİ TAMAMLA VE GPX ÇIKAR'),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final finished = await ref.read(trackingServiceProvider).stopTrip();
                              await _loadTrips();
                              if (mounted && finished != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Seyir tamamlandı! Mesafe: ${finished.totalDistanceNm.toStringAsFixed(2)} NM, GPX hazırlandı.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Yeni bir seyre başlayarak rotanızı çevrimdışı kaydedebilir, bittiğinde GPX ve Cloudflare R2 yedeklemesi alabilirsiniz.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                              foregroundColor: isNightVision ? Colors.white : AppTheme.navyBackground,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('YENİ SEYİR BAŞLAT', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: _showStartTripDialog,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GEÇMİŞ SEYİRLER',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  Text(
                    '${_trips.length} Kayıt',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_trips.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.menu_book, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text('Henüz kaydedilmiş bir seyir yok.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _trips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    return _buildTripCard(trip, isNightVision);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip, bool isNightVision) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trip.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (trip.isSynced)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('R2 Bulut Senkron', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(trip.startTime)}  •  ${trip.vesselName}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTripMetric('Mesafe', '${trip.totalDistanceNm.toStringAsFixed(1)} NM'),
                _buildTripMetric('Max SOG', '${trip.maxSpeedKnots.toStringAsFixed(1)} kn'),
                _buildTripMetric('Ortalama', '${trip.avgSpeedKnots.toStringAsFixed(1)} kn'),
                _buildTripMetric('Nokta', '${trip.totalPointsCount}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('GPX Paylaş', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    await ref.read(tripRepositoryProvider).shareGpx(trip.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () async {
                    await ref.read(tripRepositoryProvider).deleteTrip(trip.id);
                    await _loadTrips();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
