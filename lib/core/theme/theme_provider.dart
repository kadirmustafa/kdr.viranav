import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viranav/core/services/database_service.dart';
import 'app_theme.dart';

class ThemeSelectionNotifier extends Notifier<AppThemeSelection> {
  AppThemeSelection _previousTheme = AppThemeSelection.dark;

  @override
  AppThemeSelection build() {
    _loadSavedTheme();
    return AppThemeSelection.dark;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final db = DatabaseService();
      final saved = await db.getSetting('app_theme');
      if (saved != null) {
        switch (saved) {
          case 'light':
            state = AppThemeSelection.light;
            break;
          case 'system':
            state = AppThemeSelection.system;
            break;
          case 'nightVision':
            state = AppThemeSelection.nightVision;
            break;
          case 'dark':
          default:
            state = AppThemeSelection.dark;
            break;
        }
      }
    } catch (_) {}
  }

  Future<void> setTheme(AppThemeSelection mode) async {
    if (state != AppThemeSelection.nightVision) {
      _previousTheme = state;
    }
    state = mode;
    try {
      final db = DatabaseService();
      await db.setSetting('app_theme', mode.name);
    } catch (_) {}
  }

  void toggleNightVision() {
    if (state == AppThemeSelection.nightVision) {
      setTheme(_previousTheme);
    } else {
      _previousTheme = state;
      setTheme(AppThemeSelection.nightVision);
    }
  }
}

final themeSelectionProvider =
    NotifierProvider<ThemeSelectionNotifier, AppThemeSelection>(ThemeSelectionNotifier.new);

// Convenience provider to check if Night Vision is active
final isNightVisionProvider = Provider<bool>((ref) {
  return ref.watch(themeSelectionProvider) == AppThemeSelection.nightVision;
});
