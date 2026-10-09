import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/localization/app_localizations.dart';
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
    final s = ref.watch(stringsProvider);
    final isNightVision = ref.watch(isNightVisionProvider);

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
        title: Text(s.anchorTitle),
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
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              s.mobEmergency,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.8,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        if (mobState.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('ALARM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (mobState.isActive) ...[
                      Text(
                        s.mobActive,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MOB Koordinat: ${mobState.mobLocation?.latitude.toStringAsFixed(4)}°N, ${mobState.mobLocation?.longitude.toStringAsFixed(4)}°E',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Uzaklık: ${mobState.distanceMeters.toStringAsFixed(0)} metre  |  Kerteriz: ${mobState.returnBearingDeg.round()}°',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: Text(s.mobReset),
                        onPressed: () => anchorService.clearMob(),
                      ),
                    ] else ...[
                      const Text(
                        'Acil durumda tek dokunuşla kazazedenin GPS koordinatını kilitler, sesli alarm başlatır ve geri dönüş rotasını çizer.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.sos, size: 22),
                          label: const Text('MOB ACİL DURUM BUTONU', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            anchorService.triggerMob(currentPos);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ANCHOR WATCH (DEMİR ALARMI) CARD
            Card(
              color: isAlarmActive
                  ? Colors.red.shade900.withValues(alpha: 0.3)
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
                              color: isAlarmActive
                                  ? Colors.redAccent
                                  : (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              anchorState.isArmed ? s.anchorLocked : s.anchorNotLocked,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        _buildStatusBadge(anchorState.status),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visual Swinging Circle
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isNightVision ? AppTheme.nightSurface : const Color(0xFF071426),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isAlarmActive ? Colors.redAccent : AppTheme.neonCyan).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Swing Circle Boundary
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (isAlarmActive ? Colors.red : AppTheme.neonCyan).withValues(alpha: 0.7),
                                width: 2,
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
                                  ? '${s.currentDrift}: ${anchorState.currentDistanceMeters.toStringAsFixed(1)} m / ${_chainScopeRadius.toStringAsFixed(0)} m'
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
                        Text('${s.radius}:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${_chainScopeRadius.round()} m', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              label: Text(s.raiseAnchor),
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
                              label: Text(s.dropAnchor, style: const TextStyle(fontWeight: FontWeight.bold)),
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
