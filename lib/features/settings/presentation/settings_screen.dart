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
    final currentLangCode = ref.watch(languageProvider);
    final currentTheme = ref.watch(themeSelectionProvider);
    final isNightVision = ref.watch(isNightVisionProvider);
    final vessel = ref.watch(vesselProvider);

    final primaryAccent = isNightVision ? AppTheme.nightRedPrimary : AppTheme.neonCyan;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MULTI-LANGUAGE SELECTION SECTION (EN, TR, IT, ES, FR, DE, AR, RU, EL, PT, NL)
            _buildSectionHeader(context, s.languageSection, Icons.language, primaryAccent),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: LocaleNotifier.supportedLanguages.map((lang) {
                    final isSelected = lang.code == currentLangCode;
                    return InkWell(
                      onTap: () {
                        ref.read(languageProvider.notifier).setLanguage(lang.code);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryAccent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: primaryAccent.withValues(alpha: 0.5), width: 1.2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                      color: isSelected ? primaryAccent : null,
                                    ),
                                  ),
                                  Text(
                                    lang.name,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: primaryAccent,
                                size: 20,
                              )
                            else
                              const Icon(
                                Icons.circle_outlined,
                                color: Colors.grey,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
