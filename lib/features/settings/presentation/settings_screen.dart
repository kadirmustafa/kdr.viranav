import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/theme/theme_provider.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/localization/app_localizations.dart';
import 'package:viranav/core/providers/navigation_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final currentLang = ref.watch(languageProvider);
    final currentTheme = ref.watch(themeSelectionProvider);
    final isNightVision = ref.watch(isNightVisionProvider);
    final vessel = ref.watch(vesselProvider);
    final checklist = ref.watch(checklistProvider);

    final primaryAccent = isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan;

    final completedCount = checklist.where((c) => c.isCompleted).length;
    final totalCount = checklist.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LANGUAGE SELECTION SECTION
            _buildSectionHeader(context, s.languageSection, Icons.language, primaryAccent),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    _buildLanguageTile(
                      ref: ref,
                      title: 'English (Default)',
                      subtitle: 'Global maritime standard',
                      lang: AppLanguage.en,
                      currentLang: currentLang,
                      accent: primaryAccent,
                    ),
                    const Divider(height: 1),
                    _buildLanguageTile(
                      ref: ref,
                      title: 'Türkçe',
                      subtitle: 'Türkçe denizcilik terimleri',
                      lang: AppLanguage.tr,
                      currentLang: currentLang,
                      accent: primaryAccent,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // THEME SELECTION SECTION (Dark / Light / System Default / Night Vision)
            _buildSectionHeader(context, s.themeSection, Icons.palette_outlined, primaryAccent),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    _buildThemeTile(
                      ref: ref,
                      title: s.themeDark,
                      subtitle: '#0A192F Dark Navy Cockpit HUD',
                      mode: AppThemeSelection.dark,
                      currentMode: currentTheme,
                      accent: primaryAccent,
                    ),
                    const Divider(height: 1),
                    _buildThemeTile(
                      ref: ref,
                      title: s.themeLight,
                      subtitle: 'High-contrast bright daylight mode',
                      mode: AppThemeSelection.light,
                      currentMode: currentTheme,
                      accent: primaryAccent,
                    ),
                    const Divider(height: 1),
                    _buildThemeTile(
                      ref: ref,
                      title: s.themeSystem,
                      subtitle: 'Follows system dark/light theme',
                      mode: AppThemeSelection.system,
                      currentMode: currentTheme,
                      accent: primaryAccent,
                    ),
                    const Divider(height: 1),
                    _buildThemeTile(
                      ref: ref,
                      title: s.themeNightVision,
                      subtitle: 'Night watch red spectrum to preserve rhodopsin',
                      mode: AppThemeSelection.nightVision,
                      currentMode: currentTheme,
                      accent: Colors.redAccent,
                      isAlert: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // VESSEL PROFILE SECTION
            _buildSectionHeader(context, s.vesselProfileSection, Icons.directions_boat, primaryAccent),
            Card(
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
                              vessel.isSailboat ? Icons.sailing : Icons.directions_boat,
                              color: primaryAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vessel.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Switch(
                          value: vessel.isSailboat,
                          activeThumbColor: primaryAccent,
                          onChanged: (_) {
                            ref.read(vesselProvider.notifier).toggleType();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${s.vesselType}: ${vessel.isSailboat ? s.sailboatMode : s.motorYachtMode}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpecItem(s.vesselDraft, '${vessel.draftMeters.toStringAsFixed(1)} m'),
                        _buildSpecItem('LOA', '${vessel.lengthMeters.toStringAsFixed(1)} m'),
                        if (vessel.isSailboat)
                          _buildSpecItem(s.noGoAngle, '±${vessel.noGoZoneAngle.round()}°')
                        else
                          _buildSpecItem(s.fuelBurnRate, '${vessel.fuelBurnLitersPerHour.round()} L/h'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PRE-VOYAGE SAFETY CHECKLIST
            _buildSectionHeader(context, s.safetyChecklist, Icons.checklist, primaryAccent),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.safetyChecklistDesc,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Text(
                          '$completedCount / $totalCount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: completedCount == totalCount ? Colors.greenAccent : primaryAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalCount > 0 ? completedCount / totalCount : 0.0,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedCount == totalCount ? Colors.green : primaryAccent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...checklist.map((item) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            color: item.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(item.category, style: const TextStyle(fontSize: 11)),
                        value: item.isCompleted,
                        activeColor: primaryAccent,
                        onChanged: (_) {
                          ref.read(checklistProvider.notifier).toggleItem(item.id);
                        },
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: const Text('Sıfırla / Reset', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          ref.read(checklistProvider.notifier).resetAll();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // APP INFORMATION
            _buildSectionHeader(context, s.appInfoSection, Icons.info_outline, primaryAccent),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.aboutViranav, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text('v1.0.0+1', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.aboutViranavDesc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                    ),
                    const Divider(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Harita & Şamandıralar:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('OpenStreetMap & OpenSeaMap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Deniz Meteorolojisi:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Open-Meteo Marine (Edge Cache)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required AppLanguage lang,
    required AppLanguage currentLang,
    required Color accent,
  }) {
    final isSelected = lang == currentLang;
    return InkWell(
      onTap: () => ref.read(languageProvider.notifier).setLanguage(lang),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? accent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required AppThemeSelection mode,
    required AppThemeSelection currentMode,
    required Color accent,
    bool isAlert = false,
  }) {
    final isSelected = mode == currentMode;
    return InkWell(
      onTap: () => ref.read(themeSelectionProvider.notifier).setTheme(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? accent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isAlert ? Colors.redAccent : null,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
