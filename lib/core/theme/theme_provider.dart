import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

class ThemeModeNotifier extends Notifier<NavThemeMode> {
  @override
  NavThemeMode build() {
    return NavThemeMode.darkNavy;
  }

  void toggleNightVision() {
    state = state == NavThemeMode.darkNavy
        ? NavThemeMode.nightVisionRed
        : NavThemeMode.darkNavy;
  }

  void setTheme(NavThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, NavThemeMode>(ThemeModeNotifier.new);
