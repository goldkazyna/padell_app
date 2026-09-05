import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/tournament_navigation.dart';
import '../widgets/app_back_button.dart';

/// Куда ведёт ссылка на трансляцию (`padelp://live/{id}`).
///
/// У ссылки есть только номер турнира, а live-экранов шесть — какой открыть,
/// зависит от формата. Экран спрашивает формат у сервера и подменяет себя
/// нужным live-экраном, поэтому в истории он не остаётся: «назад» со
/// трансляции возвращает зрителя туда, откуда он пришёл.
class TournamentLiveEntryScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentLiveEntryScreen({super.key, required this.tournamentId});

  @override
  State<TournamentLiveEntryScreen> createState() =>
      _TournamentLiveEntryScreenState();
}

class _TournamentLiveEntryScreenState extends State<TournamentLiveEntryScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    try {
      final token = await StorageService().getToken();
      final response = await ApiService().get(
        '/tournaments/${widget.tournamentId}',
        token,
      );
      if (!mounted) return;

      final tournament = response['tournament'] as Map<String, dynamic>?;
      final type = tournament?['type'] as String?;
      if (response['success'] != true || type == null) {
        setState(() {
          _error = (response['message'] as String?) ??
              AppLocalizations.of(context)!.failedToLoadTournament;
        });
        return;
      }

      openTournamentLiveByType(
        context,
        tournamentId: widget.tournamentId,
        tournamentType: type,
        replace: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: const [AppBackButton()]),
            ),
            Expanded(
              child: Center(
                child: _error == null
                    ? CircularProgressIndicator(color: AppTheme.accent)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
