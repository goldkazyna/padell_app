import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/court_menu_panel.dart';

/// Три способа разложить «Сервисы» на корте — рядом, для выбора.
///
/// А — ряды по две зоны, как в меню профиля: с подписью под названием.
/// Б — четыре колонки, иконка в квадратной плашке (стоит сейчас).
/// В — четыре колонки, иконка без плашки, акцентом: так было в макете.
void main() {
  const items = [
    ('Лиги', 'Сезон из этапов', Icons.leaderboard_outlined, true, null),
    ('Клубы', 'Корты и расписание', Icons.apartment_outlined, false, null),
    ('Тренировки', 'Записаться к тренеру', Icons.fitness_center_outlined, false, 'NEW'),
    ('Игры', 'Поединки 2×2', Icons.sports_esports_outlined, false, '5'),
    ('Комьюнити', 'Сообщества игроков', Icons.groups_outlined, false, null),
    ('Клубные карты', 'Часы и списания', Icons.credit_card_outlined, false, null),
    ('Сертификаты', 'Подарить игру', Icons.workspace_premium_outlined, false, null),
    ('Магазин', 'Ракетки и мячи', Icons.shopping_bag_outlined, false, null),
  ];

  CourtMenuZone zone(int i, {bool compact = false, bool bare = false}) {
    final (title, subtitle, icon, accent, mark) = items[i];

    return CourtMenuZone(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accent: accent,
      compact: compact,
      bareIcon: bare,
      value: mark != null && mark != 'NEW' ? mark : null,
      valueColor: AppTheme.accent,
      tag: mark == 'NEW' ? mark : null,
      onTap: () {},
    );
  }

  Widget label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  /// Четыре колонки в два ряда.
  Widget quad({required bool bare}) => CourtMenuPanel(rows: [
        for (int r = 0; r < 2; r++)
          CourtMenuRow.cells(
            divider: r == 0,
            cells: [
              for (int c = 0; c < 4; c++)
                zone(r * 4 + c, compact: true, bare: bare),
            ],
          ),
      ]);

  testWidgets('раскладки корта рядом', (tester) async {
    tester.view.physicalSize = const Size(1180, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('А · по две зоны, как в профиле'),
                    CourtMenuPanel(rows: [
                      for (int r = 0; r < 4; r++)
                        CourtMenuRow(
                          left: zone(r * 2),
                          right: zone(r * 2 + 1),
                          divider: r < 3,
                        ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Б · плашки под иконками (стоит сейчас)'),
                    quad(bare: false),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('В · иконки без плашек, как в макете'),
                    quad(bare: true),
                  ],
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
      matchesGoldenFile('goldens/services_court_compare.png'),
    );
  });
}
