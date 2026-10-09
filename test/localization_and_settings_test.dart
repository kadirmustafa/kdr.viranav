import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/localization/app_localizations.dart';
import 'package:viranav/core/theme/app_theme.dart';
import 'package:viranav/core/theme/theme_provider.dart';

void main() {
  group('Multi-Language & Localization Tests', () {
    test('Default language is strictly English (code: "en")', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentLang = container.read(languageProvider);
      expect(currentLang, equals('en'));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Cockpit'));
      expect(strings.navSettings, equals('Settings'));
      expect(strings.sogLabel, contains('SOG'));
      expect(container.read(isRtlProvider), isFalse);
    });

    test('Supported languages include en, tr, it, es, fr, de, ar, ru, el, pt, nl', () {
      final codes = LocaleNotifier.supportedLanguages.map((l) => l.code).toList();
      expect(codes, containsAll(['en', 'tr', 'it', 'es', 'fr', 'de', 'ar', 'ru', 'el', 'pt', 'nl']));
    });

    test('Switching to Turkish updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('tr');
      expect(container.read(languageProvider), equals('tr'));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Kokpit'));
      expect(strings.navSettings, equals('Ayarlar'));
      expect(strings.navLogbook, equals('Defter'));
    });

    test('Switching to Italian updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('it');
      expect(container.read(languageProvider), equals('it'));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Pozzetto'));
      expect(strings.navSettings, equals('Impostazioni'));
    });

    test('Switching to Spanish updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('es');
      expect(container.read(languageProvider), equals('es'));

      final strings = container.read(stringsProvider);
      expect(strings.navCockpit, equals('Cabina'));
      expect(strings.navSettings, equals('Ajustes'));
    });

    test('Switching to French updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('fr');
      expect(container.read(languageProvider), equals('fr'));

      final strings = container.read(stringsProvider);
      expect(strings.navSettings, equals('Paramètres'));
    });

    test('Switching to German updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('de');
      expect(container.read(languageProvider), equals('de'));

      final strings = container.read(stringsProvider);
      expect(strings.navSettings, equals('Einstellungen'));
    });

    test('Switching to Arabic activates RTL and updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('ar');
      expect(container.read(languageProvider), equals('ar'));
      expect(container.read(isRtlProvider), isTrue);

      final strings = container.read(stringsProvider);
      expect(strings.navSettings, equals('الإعدادات'));
    });

    test('Switching to Russian updates strings', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.notifier).setLanguage('ru');
      expect(container.read(languageProvider), equals('ru'));

      final strings = container.read(stringsProvider);
      expect(strings.navSettings, equals('Настройки'));
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
