import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/widgets/app_back_button.dart';

/// Кнопка «назад» одинаковая на всех вложенных экранах.
void main() {
  testWidgets('кнопка держит 34×34 даже в жёстких ограничениях', (tester) async {
    // Именно так её зажимал AppBar: leading отдаёт tight-ограничения,
    // и без Center круг растягивался на всю область.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 56,
          height: 56,
          child: AppBackButton(),
        ),
      ),
    ));

    final circle = tester.getSize(
      find.descendant(of: find.byType(AppBackButton), matching: find.byType(Container)),
    );

    expect(circle.width, 34);
    expect(circle.height, 34);
  });

  testWidgets('в шапке экрана размер тот же', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: AppBackButton(),
          ),
        ),
      ),
    ));

    final circle = tester.getSize(
      find.descendant(of: find.byType(AppBackButton), matching: find.byType(Container)),
    );

    expect(circle, const Size(34, 34));
  });
}
