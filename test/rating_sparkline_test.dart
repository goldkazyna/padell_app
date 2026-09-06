import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/profile/rating_sparkline.dart';

/// График рейтинга — один и тот же в карточке профиля и на экране всей
/// динамики. В карточке он влезает в ширину экрана, на экране — тянется по
/// числу точек и листается вбок.
void main() {
  const short = [2410, 2455, 2402, 2470, 2521, 2498, 2560, 2612, 2578, 2634];
  const long = [
    2410, 2455, 2402, 2470, 2521, 2498, 2560, 2612, 2578, 2634,
    2690, 2651, 2601, 2669, 2642, 2679, 2689,
  ];

  testWidgets('карточка и вся динамика рисуются одним виджетом',
      (tester) async {
    tester.view.physicalSize = const Size(390, 420);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Как в карточке профиля: десять точек по ширине экрана.
              RatingSparkline(
                trend: short,
                selectedIdx: short.length - 1,
                green: AppTheme.accent,
                card: AppTheme.card,
                size: const Size(358, 96),
              ),
              const SizedBox(height: 24),
              // Как на экране «Вся динамика»: 17 точек с шагом 46 и скроллом.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RatingSparkline(
                  trend: long,
                  selectedIdx: long.length - 1,
                  green: AppTheme.accent,
                  card: AppTheme.card,
                  size: Size(long.length * 46, 110),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/rating_sparkline.png'),
    );
  });

  test('ближайшая точка ищется по горизонтали', () {
    const size = Size(460, 110);

    // Крайние случаи: левее первой точки и правее последней.
    expect(nearestPoint(long, size, -50), 0);
    expect(nearestPoint(long, size, 10000), long.length - 1);

    // Середина полотна — примерно середина ряда.
    final middle = nearestPoint(long, size, size.width / 2);
    expect(middle, closeTo(long.length ~/ 2, 1));
  });
}
