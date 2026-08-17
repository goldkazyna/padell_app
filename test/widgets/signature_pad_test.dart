import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/widgets/waiver/signature_pad.dart';

/// Холст подписи под отказом от ответственности.
///
/// Главное здесь — что палец превращается в PNG, который сервер примет:
/// он отклоняет одноцветную картинку как пустую подпись.
///
/// Растеризацию зовём через runAsync: в фейковом времени тестов
/// Canvas.toImage не завершается никогда.
void main() {
  Future<void> pumpPad(WidgetTester tester, SignaturePadController pad) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: SignaturePad(controller: pad),
        ),
      ),
    ));
  }

  testWidgets('пустой холст не отдаёт картинку', (tester) async {
    final pad = SignaturePadController();
    await pumpPad(tester, pad);

    expect(pad.isEmpty, isTrue);
    expect(await pad.toPng(), isNull);
  });

  testWidgets('один тап без движения подписью не считается', (tester) async {
    final pad = SignaturePadController();
    await pumpPad(tester, pad);

    await tester.tapAt(const Offset(150, 90));
    await tester.pump();

    expect(pad.isEmpty, isTrue, reason: 'точка без штриха — это не подпись');
  });

  testWidgets('росчерк даёт непустой PNG', (tester) async {
    final pad = SignaturePadController();
    await pumpPad(tester, pad);

    final gesture = await tester.startGesture(const Offset(60, 60));
    await gesture.moveTo(const Offset(140, 120));
    await gesture.moveTo(const Offset(220, 70));
    await gesture.up();
    await tester.pump();

    expect(pad.isEmpty, isFalse);

    final png = await tester.runAsync(() => pad.toPng());
    expect(png, isNotNull);
    // Сигнатура формата: сервер проверяет ровно эти восемь байт.
    expect(png!.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  });

  testWidgets('вертикальный штрих на прокручиваемом экране рисуется',
      (tester) async {
    // Экран подписи — это список: распознаватель прокрутки забирал себе
    // движение пальцем вниз, и вертикальные штрихи не появлялись.
    final pad = SignaturePadController();
    final scroll = ScrollController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          controller: scroll,
          children: [
            const SizedBox(height: 400),
            SizedBox(width: 300, child: SignaturePad(controller: pad)),
            const SizedBox(height: 800),
          ],
        ),
      ),
    ));

    final center = tester.getCenter(find.byType(SignaturePad));
    final gesture = await tester.startGesture(center);
    // Мелкими шагами, как настоящий палец: одним скачком распознаватели
    // разрешают спор иначе, и ошибка не воспроизводится.
    for (int i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 5));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(pad.isEmpty, isFalse, reason: 'вертикальный штрих должен рисоваться');
    expect(scroll.offset, 0, reason: 'список не должен ехать под пальцем');
  });

  testWidgets('очистка возвращает холст в пустое состояние', (tester) async {
    final pad = SignaturePadController();
    await pumpPad(tester, pad);

    final gesture = await tester.startGesture(const Offset(60, 60));
    await gesture.moveTo(const Offset(200, 100));
    await gesture.up();
    await tester.pump();
    expect(pad.isEmpty, isFalse);

    pad.clear();
    await tester.pump();

    expect(pad.isEmpty, isTrue);
    expect(await pad.toPng(), isNull);
  });
}
