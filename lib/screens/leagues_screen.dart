import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/leagues_list.dart';

/// Лиги отдельным экраном — вход с главной, из блока «Сервисы».
///
/// Тот же список, что в разделе «Лиги» на экране турниров: список живёт в
/// [LeaguesList], экран добавляет только шапку.
class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: AppBackButton(),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.leaguesTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: const SafeArea(child: LeaguesList()),
    );
  }
}
