import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_flex_pairs.dart';
import 'package:padel_app/models/admin_participant.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/admin/admin_flex_pairs_view.dart';

/// Снимок состава: место с пометкой «на модерации» должно быть видно.
Map<String, dynamic> _u(int id, String name, {String status = 'registered'}) =>
    {'id': id, 'name': name, 'level': 3.0, 'rating': 2000 + id, 'status': status};

void main() {
  testWidgets('снимок сетки пар', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final pairs = AdminFlexPairs.fromJson({
      'max_pairs': 3,
      'pairs': [
        {
          'id': 1,
          'position': 1,
          'rating_avg': 2100,
          'player1': _u(1, 'Ержан'),
          'player2': _u(2, 'Данияр', status: 'pending'),
        },
        {
          'id': 2,
          'position': 2,
          'rating_avg': 2200,
          'player1': _u(3, 'Марат'),
          'player2': null,
        },
      ],
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AdminFlexPairsView(
            pairs: pairs,
            participants: [
              AdminParticipant.fromJson(_u(1, 'Ержан')),
              AdminParticipant.fromJson(_u(2, 'Данияр', status: 'pending')),
              AdminParticipant.fromJson(_u(3, 'Марат')),
              AdminParticipant.fromJson(_u(4, 'Асель', status: 'waiting')),
            ],
            maxParticipants: 6,
            canModify: true,
            onFillSeat: (_) {},
            onOpenNewPair: () {},
            onPlayerMenu: (_) {},
            onDisbandPair: (_) {},
            onSeatPlayer: (_) {},
          ),
        ),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/admin_flex_pairs.png'),
    );
  });
}
