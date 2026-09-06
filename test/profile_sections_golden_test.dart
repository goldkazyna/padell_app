import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/home/section_title.dart';
import 'package:padel_app/widgets/profile/profile_menu.dart';

/// Заголовки разделов профиля — одним начертанием.
///
/// «Настройки» и «Информация» были мелким серым капслоком, а «Достижения» и
/// «С кем играю» — крупным белым. Снимок держит их вместе: разъедутся —
/// увидим.
void main() {
  testWidgets('заголовки разделов профиля одинаковые', (tester) async {
    tester.view.physicalSize = const Size(390, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Достижения',
                  subtitle: '8 из 30',
                  trailing: 'Все',
                ),
                const SizedBox(height: 12),
                _block(72),
                const SizedBox(height: 20),
                const SectionTitle(title: 'С кем играю', subtitle: '4 партнёра'),
                const SizedBox(height: 12),
                _block(72),
                const SizedBox(height: 20),
                SettingsSection(
                  label: 'Настройки',
                  children: [
                    SettingsRow(
                      icon: Icons.person_outline,
                      title: 'Редактировать профиль',
                      subtitle: 'Имя, фото, уровень',
                      onTap: _noop,
                    ),
                    SettingsRow(
                      icon: Icons.notifications_none,
                      title: 'Уведомления',
                      subtitle: 'Что и когда присылать',
                      onTap: _noop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/profile_sections.png'),
    );
  });
}

void _noop() {}

Widget _block(double height) => Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
    );
