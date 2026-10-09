import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/localization/app_localizations.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/theme/theme_provider.dart';

void main() {
  group('Localization & Language Tests', () {
    test('Default language is strictly English (AppLanguage.en)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentLang = container.read(languageProvider);
      expect(currentLang, equals(AppLanguage.en));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Cockpit'));
      expect(strings.navSettings, equals('Settings'));
      expect(strings.sogLabel, contains('SOG'));
    });

    test('Switching to Turkish updates all localized strings reactively', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage(AppLanguage.tr);

      final currentLang = container.read(languageProvider);
      expect(currentLang, equals(AppLanguage.tr));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Kokpit'));
      expect(strings.navSettings, equals('Ayarlar'));
      expect(strings.navLogbook, equals('Defter'));
    });
  });

  group('Theme Selection Tests', () {
    test('Default theme is dark navy', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(themeSelectionProvider);
      expect(theme, equals(AppThemeSelection.dark));
      expect(container.read(isNightVisionProvider), isFalse);
    });

    test('Can switch to light maritime and system default', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeSelectionProvider.notifier).setTheme(AppThemeSelection.light);
      expect(container.read(themeSelectionProvider), equals(AppThemeSelection.light));

      await container.read(themeSelectionProvider.notifier).setTheme(AppThemeSelection.system);
      expect(container.read(themeSelectionProvider), equals(AppThemeSelection.system));
    });

    test('Night vision toggle enables and restores previous theme', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeSelectionProvider.notifier).toggleNightVision();
      expect(container.read(themeSelectionProvider), equals(AppThemeSelection.nightVision));
      expect(container.read(isNightVisionProvider), isTrue);

      container.read(themeSelectionProvider.notifier).toggleNightVision();
      expect(container.read(themeSelectionProvider), equals(AppThemeSelection.dark));
      expect(container.read(isNightVisionProvider), isFalse);
    });
  });
}
