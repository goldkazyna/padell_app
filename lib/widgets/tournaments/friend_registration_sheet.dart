import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../utils/rating_formatter.dart';

/// Bottom-sheet «Записаться с другом» для одиночных турниров.
/// Ищет другого игрока по номеру телефона, выбирает и регистрирует
/// обоих как отдельных участников (запрос идёт в endpoint /register
/// с параметром friend_user_id).
class FriendRegistrationSheet extends StatefulWidget {
  final int tournamentId;

  const FriendRegistrationSheet({super.key, required this.tournamentId});

  @override
  State<FriendRegistrationSheet> createState() => _FriendRegistrationSheetState();
}

class _FriendRegistrationSheetState extends State<FriendRegistrationSheet> {
  final _phoneController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Сбрасываем предыдущий выбор / результаты поиска чтобы sheet открывался
    // с чистого состояния, даже если до этого открывали team-sheet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().clearPartnerSearch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    _debounce?.cancel();
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 5) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        context.read<TournamentProvider>().searchPartner(widget.tournamentId, digits);
      });
    }
  }

  void _onRegister() async {
    final provider = context.read<TournamentProvider>();
    final selected = provider.selectedPartner;
    if (selected == null) return;

    var result = await provider.registerForTournament(
      widget.tournamentId,
      friendUserId: selected.id,
    );

    if (result.isWaitlistConfirm && mounted) {
      final pos = result.result?.waitlistPosition;
      final size = result.result?.waitlistSize ?? 0;
      final posText = pos != null && size > 0 ? '\nВаша позиция: $pos из $size' : '';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Мест для двоих нет'),
          content: Text(
              'Встать вдвоём в лист ожидания? Если кто-то отменит запись — вас переведут на турнир.$posText'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Встать в очередь')),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      result = await provider.registerForTournament(
        widget.tournamentId,
        friendUserId: selected.id,
        confirmWaitlist: true,
      );
    }

    if (mounted) {
      if (result.isSuccess) {
        Navigator.of(context).pop();
      }
      showAppAlert(context, result.message, isError: !result.isSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2A3330),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Записать с другом',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Вы оба попадёте как отдельные участники, заявка пойдёт на модерацию.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Phone input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              onChanged: _onPhoneChanged,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterPhoneNumber,
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A3330), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A3330), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Consumer<TournamentProvider>(
            builder: (context, provider, _) {
              if (provider.isSearchingPartner) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2.5),
                    ),
                  ),
                );
              }

              final results = provider.partnerSearchResults;
              final selected = provider.selectedPartner;
              final phoneLen = _phoneController.text.replaceAll(RegExp(r'\D'), '').length;

              if (results.isEmpty && phoneLen >= 5) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.of(context)!.playersNotFound,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final player = results[index];
                    final isSelected = selected?.id == player.id;
                    return _buildPlayerRow(player, isSelected, provider);
                  },
                ),
              );
            },
          ),

          // Register button
          Consumer<TournamentProvider>(
            builder: (context, provider, _) {
              final selected = provider.selectedPartner;
              if (selected == null) return const SizedBox(height: 16);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isActionLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: provider.isActionLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Записать нас обоих',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
      PartnerSearchResult player, bool isSelected, TournamentProvider provider) {
    return GestureDetector(
      onTap: () => provider.selectPartner(player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent.withAlpha(15) : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent.withAlpha(60) : const Color(0xFF2A3330),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent : const Color(0xFF2A3330),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  player.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Builder(builder: (ctx) {
                    final precise = ctx.watch<SettingsProvider>().preciseRating;
                    return Text(
                      RatingFormatter.formatLevelLabel(
                        bucketedLevel: player.level,
                        rating: player.rating,
                        precise: precise,
                      ),
                      style: TextStyle(
                        color: isSelected ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Builder(builder: (ctx) {
              final precise = ctx.watch<SettingsProvider>().preciseRating;
              return Text(
                RatingFormatter.formatRating(player.rating, precise),
                style: TextStyle(
                  color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}
