import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/providers/navigation_providers.dart';
import 'package:viranav/features/anchor_watch/services/anchor_alarm_service.dart';

class AnchorWatchScreen extends ConsumerStatefulWidget {
  const AnchorWatchScreen({super.key});

  @override
  ConsumerState<AnchorWatchScreen> createState() => _AnchorWatchScreenState();
}

class _AnchorWatchScreenState extends ConsumerState<AnchorWatchScreen> {
  double _chainScopeRadius = 35.0; // meters

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNightVision = ref.watch(themeModeProvider) == NavThemeMode.nightVisionRed;

    final anchorService = ref.watch(anchorServiceProvider);
    final anchorState = ref.watch(anchorStateStreamProvider).value ?? anchorService.currentAnchorState;
    final mobState = ref.watch(mobStateStreamProvider).value ?? anchorService.currentMobState;

    final trackingState = ref.watch(trackingStateStreamProvider).value ??
        ref.read(trackingServiceProvider).currentState;

    final currentPos = trackingState.lastPosition != null
        ? LatLng(trackingState.lastPosition!.latitude, trackingState.lastPosition!.longitude)
        : const LatLng(36.985, 27.350);

    // Keep updating anchor service with live boat position
    anchorService.updatePosition(currentPos);

    final isAlarmActive = anchorState.status == AnchorStatus.alarmTriggered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMİR ALARMI & EMNİYET'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // EMERGENCY MAN OVERBOARD (MOB) CARD
            Card(
              color: mobState.isActive
                  ? Colors.red.shade900
                  : (isNightVision ? AppTheme.nightCard : const Color(0xFF2A0F14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.redAccent.shade700, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.redAccent, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'MAN OVERBOARD (MOB)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        if (mobState.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('ACİL DURUM!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (mobState.isActive) ...[
                      Text(
                        'Dönüş Kerterizi: ${mobState.returnBearingDeg.round()}°  |  Mesafe: ${mobState.distanceMeters.toStringAsFixed(0)} m',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Koordinat: ${mobState.mobLocation?.latitude.toStringAsFixed(5)}, ${mobState.mobLocation?.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('KAZAZEDE BULUNDU / MOB İPTAL'),
                        onPressed: () {
                          anchorService.clearMob();
                        },
                      ),
                    ] else ...[
                      const Text(
                        'Denize adam düşmesi anında tek dokunuşla anlık GPS noktasını kilitler ve geri dönüş vektörü hesaplar.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.sos, size: 28),
                          label: const Text('MOB ACİL KİLİTLE (DENİZE ADAM DÜŞTÜ)', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            anchorService.triggerMob(currentPos);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('MOB KİLİTLENDİ! Geri dönüş vektörü aktif.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ANCHOR WATCH (DEMİR ALARMI) CARD
            Card(
              color: isAlarmActive
                  ? Colors.red.shade900.withValues(alpha: 0.5)
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
                              Icons.anchor,
                              color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'DEMİR ALARMI (ANCHOR WATCH)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                        _buildStatusBadge(anchorState.status),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visual Swing Ring Graphic
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAlarmActive ? Colors.red : (isNightVision ? AppTheme.nightRedSecondary : Colors.blueGrey),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Permitted Geofence boundary
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isAlarmActive ? Colors.red : AppTheme.successGreen,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              color: (isAlarmActive ? Colors.red : AppTheme.successGreen).withValues(alpha: 0.08),
                            ),
                          ),
                          // Center Anchor Icon
                          const Icon(Icons.anchor, size: 28, color: Colors.white70),
                          // Drift distance text
                          Positioned(
                            bottom: 12,
                            child: Text(
                              anchorState.isArmed
                                  ? 'Sürüklenme: ${anchorState.currentDistanceMeters.toStringAsFixed(1)} m / ${_chainScopeRadius.toStringAsFixed(0)} m'
                                  : 'Demir serbest (Kilitlenmedi)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAlarmActive ? Colors.redAccent : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Scope / Kaloma slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Emniyet Yarıçapı (Kaloma):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${_chainScopeRadius.round()} metre', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _chainScopeRadius,
                      min: 15.0,
                      max: 120.0,
                      divisions: 21,
                      activeColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                      onChanged: anchorState.isArmed
                          ? null
                          : (val) {
                              setState(() {
                                _chainScopeRadius = val;
                              });
                            },
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: anchorState.isArmed
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.arrow_upward),
                              label: const Text('DEMİRİ AL (WEIGH ANCHOR)'),
                              onPressed: () {
                                anchorService.weighAnchor();
                              },
                            )
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                                foregroundColor: isNightVision ? Colors.white : AppTheme.navyBackground,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.anchor),
                              label: const Text('DEMİR AT & KİLİTLE (DROP ANCHOR)', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                anchorService.dropAnchor(
                                  position: currentPos,
                                  radiusMeters: _chainScopeRadius,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AnchorStatus status) {
    Color bg;
    String text;
    switch (status) {
      case AnchorStatus.safe:
        bg = Colors.green;
        text = 'EMNİYETTE';
        break;
      case AnchorStatus.warning:
        bg = Colors.amber;
        text = 'SINIRDA';
        break;
      case AnchorStatus.alarmTriggered:
        bg = Colors.red;
        text = 'DEMİR TARADI!';
        break;
      case AnchorStatus.idle:
        bg = Colors.grey;
        text = 'KAPALI';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bg)),
    );
  }
}
