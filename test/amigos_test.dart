import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/amigo.dart';
import 'package:padel_app/widgets/amigos/amigo_row.dart';
import 'package:padel_app/widgets/amigos/chat_bubble.dart';

/// Амигос: разбор ответа сервера и две строки, из которых собраны экраны.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  group('разбор ответа', () {
    test('уровень приходит и числом, и строкой', () {
      final asNumber = Amigo.fromJson({'id': 1, 'name': 'Асхат', 'level': 3.25});
      final asString = Amigo.fromJson({'id': 2, 'name': 'Диана', 'level': '3.50'});

      expect(asNumber.level, 3.25);
      expect(asString.level, 3.5);
    });

    test('нет статуса — значит человек просто в списке', () {
      final amigo = Amigo.fromJson({'id': 1, 'name': 'Тихий', 'status': null});

      expect(amigo.status, isNull);
    });

    test('статус несёт, куда провалиться', () {
      final amigo = Amigo.fromJson({
        'id': 1,
        'name': 'Асхат',
        'status': {
          'kind': 'playing',
          'title': 'играет',
          'subtitle': 'Американо · Padel Sai',
          'tournament_id': 1439,
        },
      });

      expect(amigo.status!.isPlaying, isTrue);
      expect(amigo.status!.hasTarget, isTrue);
      expect(amigo.status!.tournamentId, 1439);
    });

    test('переписка знает, кто кого заблокировал', () {
      final thread = ChatThread.fromJson({
        'player': {'id': 7, 'name': 'Асхат', 'level': '3.25'},
        'blocked_by_me': false,
        'blocked_me': true,
        'show_rules': false,
        'messages': [
          {'id': 1, 'text': 'Привет', 'is_mine': false},
        ],
      });

      expect(thread.canWrite, isFalse, reason: 'блокировка с любой стороны закрывает ввод');
      expect(thread.messages, hasLength(1));
    });
  });

  group('строка амигос', () {
    testWidgets('играющий подсвечен бейджем и кольцом', (tester) async {
      await tester.pumpWidget(wrap(AmigoRow(
        amigo: const Amigo(
          id: 1,
          name: 'Асхат Ким',
          level: 3.25,
          rating: 3240,
          status: AmigoStatus(
            kind: 'playing',
            title: 'играет',
            subtitle: 'Американо · Padel Sai',
            tournamentId: 1439,
          ),
        ),
      )));

      expect(find.text('Асхат Ким'), findsOneWidget);
      expect(find.text('ИГРАЕТ'), findsOneWidget);
      expect(find.text('Американо · Padel Sai'), findsOneWidget);
    });

    testWidgets('тап по статусу отделён от тапа по строке', (tester) async {
      var rowTaps = 0;
      var statusTaps = 0;

      await tester.pumpWidget(wrap(AmigoRow(
        amigo: const Amigo(
          id: 1,
          name: 'Асхат Ким',
          status: AmigoStatus(
            kind: 'playing',
            title: 'играет',
            subtitle: 'Американо',
            tournamentId: 1439,
          ),
        ),
        onTap: () => rowTaps++,
        onStatusTap: () => statusTaps++,
      )));

      await tester.tap(find.text('ИГРАЕТ'));
      await tester.pumpAndSettle();

      expect(statusTaps, 1, reason: 'бейдж ведёт в трансляцию');
      expect(rowTaps, 0, reason: 'а не в профиль игрока');
    });

    testWidgets('без статуса показываем уровень и рейтинг', (tester) async {
      await tester.pumpWidget(wrap(AmigoRow(
        amigo: const Amigo(id: 1, name: 'Тихий Игрок', level: 2.75, rating: 2610),
      )));

      expect(find.textContaining('2.75'), findsOneWidget);
      expect(find.textContaining('2610'), findsOneWidget);
    });

    testWidgets('взаимность — слово в мета-строке, а не бейдж', (tester) async {
      await tester.pumpWidget(wrap(AmigoRow(
        amigo: const Amigo(id: 1, name: 'Юлия', level: 2.75, rating: 2610, mutual: true),
      )));

      expect(find.textContaining('взаимно'), findsOneWidget);
    });
  });

  group('пузырь сообщения', () {
    testWidgets('своё и чужое выравниваются по разным краям', (tester) async {
      await tester.pumpWidget(wrap(Column(
        children: [
          ChatBubble(
            message: ChatMessage(
              id: 1,
              text: 'Привет',
              isMine: false,
              createdAt: DateTime(2026, 9, 5, 18, 4),
            ),
          ),
          ChatBubble(
            message: ChatMessage(
              id: 2,
              text: 'Здорово',
              isMine: true,
              createdAt: DateTime(2026, 9, 5, 18, 9),
            ),
          ),
        ],
      )));

      final theirs = tester.widget<Align>(find.ancestor(
        of: find.text('Привет'),
        matching: find.byType(Align),
      ).first);
      final mine = tester.widget<Align>(find.ancestor(
        of: find.text('Здорово'),
        matching: find.byType(Align),
      ).first);

      expect(theirs.alignment, Alignment.centerLeft);
      expect(mine.alignment, Alignment.centerRight);
      expect(find.text('18:04'), findsOneWidget);
    });

    testWidgets('удалять можно только своё сообщение', (tester) async {
      var deletes = 0;

      await tester.pumpWidget(wrap(Column(
        children: [
          ChatBubble(
            message: const ChatMessage(id: 1, text: 'Чужое', isMine: false),
            onLongPress: () => deletes++,
          ),
          ChatBubble(
            message: const ChatMessage(id: 2, text: 'Своё', isMine: true),
            onLongPress: () => deletes++,
          ),
        ],
      )));

      await tester.longPress(find.text('Чужое'));
      await tester.pumpAndSettle();
      expect(deletes, 0);

      await tester.longPress(find.text('Своё'));
      await tester.pumpAndSettle();
      expect(deletes, 1);
    });
  });
}
