import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viranav/features/navigation/presentation/widgets/wind_rose_widget.dart';
import 'package:viranav/features/navigation/presentation/widgets/hud_data_tile.dart';

void main() {
  testWidgets('WindRoseWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WindRoseWidget(
            headingDeg: 120.0,
            windDirectionDeg: 60.0,
            windSpeedKnots: 16.5,
          ),
        ),
      ),
    );

    expect(find.byType(WindRoseWidget), findsOneWidget);
  });

  testWidgets('HudDataTile displays metric values and labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HudDataTile(
            label: 'Yer Hızı (SOG)',
            value: '7.4',
            unit: 'KTS',
            subtitle: 'Seyir Hali',
          ),
        ),
      ),
    );

    expect(find.text('YER HIZI (SOG)'), findsOneWidget);
    expect(find.text('7.4'), findsOneWidget);
    expect(find.text('KTS'), findsOneWidget);
    expect(find.text('Seyir Hali'), findsOneWidget);
  });
}
