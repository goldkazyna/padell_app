import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_flex_pairs.dart';
import 'package:padel_app/models/admin_participant.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/admin/admin_flex_player_menu.dart';

Map<String, dynamic> _u(int id, String name) =>
    {'id': id, 'name': name, 'level': 3.0, 'rating': 2000 + id, 'status': 'registered'};

void main() {
  testWidgets('снимок шторки', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final pairs = AdminFlexPairs.fromJson({
      'max_pairs': 6,
      'pairs': [
        for (var i = 1; i <= 5; i++)
          {
            'id': i,
            'position': i,
            'rating_avg': 2100 + i,
            'player1': _u(i * 2, 'Тест #${i * 2}'),
            'player2': _u(i * 2 + 1, 'Тест #${i * 2 + 1}'),
          },
      ],
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 932 * 0.72),
                child: AdminFlexPlayerMenuBody(
                  player: AdminParticipant.fromJson(_u(99, 'Денис Дудников')),
                  pairs: pairs,
                  onAction: (_) {},
                  onSeat: (_) {},
                  onClose: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/admin_flex_menu.png'),
    );
  });
}
