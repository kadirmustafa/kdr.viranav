import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/app_localizations.dart';
import 'features/navigation/presentation/cockpit_screen.dart';
import 'features/navigation/presentation/navigation_map_screen.dart';
import 'features/logbook/presentation/logbook_screen.dart';
import 'features/anchor_watch/presentation/anchor_watch_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env: $e');
  }

  runApp(const ProviderScope(child: ViraNavApp()));
}

class ViraNavApp extends ConsumerWidget {
  const ViraNavApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSelection = ref.watch(themeSelectionProvider);
    final lang = ref.watch(languageProvider);

    ThemeData lightTheme = AppTheme.lightMaritimeTheme;
    ThemeData darkTheme = AppTheme.darkNavyTheme;
    ThemeMode mode;

    switch (themeSelection) {
      case AppThemeSelection.light:
        mode = ThemeMode.light;
        break;
      case AppThemeSelection.system:
        mode = ThemeMode.system;
        break;
      case AppThemeSelection.nightVision:
        mode = ThemeMode.dark;
        darkTheme = AppTheme.nightVisionTheme;
        lightTheme = AppTheme.nightVisionTheme;
        break;
      case AppThemeSelection.dark:
        mode = ThemeMode.dark;
        break;
    }

    return MaterialApp(
      title: 'ViraNav',
      debugShowCheckedModeBanner: false,
      locale: Locale(lang.name),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: mode,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CockpitScreen(),
    NavigationMapScreen(),
    LogbookScreen(),
    AnchorWatchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: s.navCockpit,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: s.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: s.navLogbook,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.anchor_outlined),
            activeIcon: const Icon(Icons.anchor),
            label: s.navAnchor,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: s.navSettings,
          ),
        ],
      ),
    );
  }
}
