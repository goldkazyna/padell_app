import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/chat_icon_button.dart';

/// Кнопка чата — одна на турнир и на профиль.
///
/// Раньше в профиле стоял свой кружок: 34 пикселя, другая иконка и красный
/// бейдж, — и он не читался как та же кнопка, по которой заходят в чат
/// турнира. Снимок держит оба состояния вместе.
void main() {
  testWidgets('вид кнопки: пустая и с непрочитанными', (tester) async {
    tester.view.physicalSize = const Size(200, 90);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChatIconButton(onTap: () {}),
              ChatIconButton(unread: 3, onTap: () {}),
              ChatIconButton(unread: 120, onTap: () {}),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/chat_icon_button.png'),
    );
  });

  testWidgets('бейдж появляется только с непрочитанными', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: ChatIconButton(onTap: () {}))),
    ));
    expect(find.textContaining('0'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: ChatIconButton(unread: 7, onTap: () {})),
      ),
    ));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('трёхзначное число сворачивается в 99+', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: ChatIconButton(unread: 145, onTap: () {})),
      ),
    ));

    expect(find.text('99+'), findsOneWidget);
  });
}
