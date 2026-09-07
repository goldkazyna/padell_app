import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/screens/admin/admin_pairing_screen.dart';
import 'package:padel_app/services/admin_service.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Сбор пар в мобильной админке при неполном составе.
///
/// Раньше экран показывал только предупреждение «сбор пар откроется при
/// полном составе»: одна заявка на модерации — и организатор не мог тронуть
/// пары. Теперь пары собираются из подтверждённых.
class _FakeAdmin extends AdminService {
  _FakeAdmin(this._state) : super(ApiService(), StorageService());

  final Map<String, dynamic> _state;

  @override
  Future<Map<String, dynamic>> getPairing(int tournamentId) async => _state;
}

Map<String, dynamic> _pairing({
  required int approved,
  required int max,
  required int pending,
  required int unpairedCount,
}) {
  return {
    'max_pairs': max ~/ 2,
    'pairs_count': 0,
    'approved_count': approved,
    'pending_count': pending,
    'max_participants': max,
    'roster_ready': approved >= max,
    'can_start': false,
    'teams': <dynamic>[],
    'unpaired': [
      for (int i = 1; i <= unpairedCount; i++)
        {'id': i, 'name': 'Игрок $i', 'rating': 2000 + i, 'level': '3.00'},
    ],
  };
}

void main() {
  Future<void> pump(WidgetTester tester, Map<String, dynamic> state) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AdminService>.value(value: _FakeAdmin(state)),
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: const AdminPairingScreen(
            tournamentId: 1477,
            tournamentName: 'Тест',
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('при неполном составе список игроков доступен', (tester) async {
    await pump(
      tester,
      _pairing(approved: 15, max: 16, pending: 1, unpairedCount: 15),
    );

    // Предупреждение осталось, но оно больше не заслоняет работу.
    expect(find.textContaining('Состав ещё не полный'), findsOneWidget);
    expect(find.text('Без пары · 15'), findsOneWidget);
    expect(find.text('Игрок 1'), findsOneWidget);
  });

  testWidgets('при полном составе предупреждения нет', (tester) async {
    await pump(
      tester,
      _pairing(approved: 16, max: 16, pending: 0, unpairedCount: 16),
    );

    expect(find.textContaining('Состав ещё не полный'), findsNothing);
    expect(find.text('Без пары · 16'), findsOneWidget);
  });

  testWidgets('когда пары составлять не из кого — списка нет', (tester) async {
    await pump(
      tester,
      _pairing(approved: 1, max: 16, pending: 0, unpairedCount: 1),
    );

    expect(find.text('Без пары · 1'), findsOneWidget);
    // Кнопка авто-пар появляется только когда есть кого объединять.
    expect(find.textContaining('Авто'), findsNothing);
  });
}
