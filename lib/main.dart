import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/navigation/presentation/cockpit_screen.dart';
import 'features/navigation/presentation/navigation_map_screen.dart';
import 'features/logbook/presentation/logbook_screen.dart';
import 'features/anchor_watch/presentation/anchor_watch_screen.dart';
import 'features/boat_garage/presentation/boat_garage_screen.dart';

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
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ViraNav',
      debugShowCheckedModeBanner: false,
      theme: themeMode == NavThemeMode.nightVisionRed
          ? AppTheme.nightVisionTheme
          : AppTheme.darkNavyTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CockpitScreen(),
    NavigationMapScreen(),
    LogbookScreen(),
    AnchorWatchScreen(),
    BoatGarageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Kokpit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Defter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.anchor_outlined),
            activeIcon: Icon(Icons.anchor),
            label: 'Demir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_boat_outlined),
            activeIcon: Icon(Icons.directions_boat),
            label: 'Garaj',
          ),
        ],
      ),
    );
  }
}
