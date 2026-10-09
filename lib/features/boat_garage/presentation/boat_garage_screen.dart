import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/providers/navigation_providers.dart';

class BoatGarageScreen extends ConsumerWidget {
  const BoatGarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNightVision = ref.watch(themeModeProvider) == NavThemeMode.nightVisionRed;
    final vessel = ref.watch(vesselProvider);
    final checklist = ref.watch(checklistProvider);

    final completedCount = checklist.where((c) => c.isCompleted).length;
    final progress = checklist.isNotEmpty ? completedCount / checklist.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEKNE GARAJI & CHECKLIST'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BOAT SPECIFICATIONS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
                              color: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vessel.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  vessel.isSailboat ? 'Yelkenli Tekne' : 'Motor Yat',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            ref.read(vesselProvider.notifier).toggleType();
                          },
                          child: const Text('Tipi Değiştir'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBoatStat('Boy (LOA)', '${vessel.lengthMeters} m'),
                        _buildBoatStat('Su Çekimi (Draft)', '${vessel.draftMeters} m'),
                        _buildBoatStat('Genişlik (Beam)', '${vessel.beamMeters} m'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBoatStat('Seyir Sürati', '${vessel.cruisingSpeedKnots} kn'),
                        _buildBoatStat('Tüketim', '${vessel.fuelBurnLitersPerHour} L/sa'),
                        _buildBoatStat(
                          'Kör Açı (No-Go)',
                          vessel.isSailboat ? '±${vessel.noGoZoneAngle.round()}°' : 'Yok',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PRE-VOYAGE CHECKLIST HEADER & PROGRESS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SEYİR ÖNCESİ KONTROL LİSTESİ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                Text(
                  '$completedCount / ${checklist.length} Tamam',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progress == 1.0 ? Colors.green : (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  progress == 1.0
                      ? Colors.green
                      : (isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CHECKLIST ITEMS LIST
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklist.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = checklist[index];
                return Card(
                  child: CheckboxListTile(
                    activeColor: isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan,
                    checkColor: isNightVision ? Colors.white : AppTheme.navyBackground,
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        color: item.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      item.category,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    value: item.isCompleted,
                    onChanged: (val) {
                      ref.read(checklistProvider.notifier).toggleItem(item.id);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Listeyi Sıfırla'),
                onPressed: () {
                  ref.read(checklistProvider.notifier).resetAll();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoatStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
