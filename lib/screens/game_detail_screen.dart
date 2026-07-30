import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../l10n/app_localizations.dart';

/// Заглушка экрана деталей игры. Наполнение — в F4.
class GameDetailScreen extends StatelessWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.gameDetailTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.gameSoon,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
