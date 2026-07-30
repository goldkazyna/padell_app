import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../providers/game_provider.dart';
import '../../models/game.dart';
import '../../l10n/app_localizations.dart';

/// Секция раундов игры: отображение счёта по раундам + ввод/редактирование
/// (для Американо — счёт по существующим раундам, для Sets/Points — добавление
/// новых раундов вручную).
class GameRoundsSection extends StatelessWidget {
  final Game game;

  const GameRoundsSection({super.key, required this.game});

  bool get _editable => game.isCreator && game.isInProgress && !game.scoreLocked;

  String _nameFor(int userId) {
    for (final p in game.players) {
      if (p.id == userId) return p.fullName;
    }
    return '?';
  }

  Future<void> _handleResult(
    BuildContext context,
    ({bool success, String message}) result,
  ) async {
    if (!context.mounted) return;
    if (!result.success) {
      showAppAlert(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<GameProvider>();
    final isLoading = provider.isActionLoading;

    final bool canRegenerate = _editable &&
        game.isAmericano &&
        game.rounds.every((r) => !r.isPlayed);
    final bool canAddRound = _editable && (game.isSets || game.isPoints);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.gameRoundsTitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (canRegenerate)
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          final result =
                              await context.read<GameProvider>().regenerate(game.id);
                          if (context.mounted) {
                            await _handleResult(context, result);
                          }
                        },
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l10n.gameRegenerate,
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (game.rounds.isEmpty)
            Text(
              '—',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            )
          else
            ...List.generate(game.rounds.length, (index) {
              final round = game.rounds[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < game.rounds.length - 1 ? 10 : 0,
                ),
                child: _RoundCard(
                  game: game,
                  round: round,
                  editable: _editable,
                  isLoading: isLoading,
                  nameFor: _nameFor,
                  onSaveScore: (a, b) async {
                    final result = await context.read<GameProvider>().updateRound(
                      game.id,
                      round.id,
                      {'score_a': a, 'score_b': b},
                    );
                    if (context.mounted) {
                      await _handleResult(context, result);
                    }
                  },
                  onDelete: canAddRound
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                l10n.gameRoundDeleteConfirm,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.no),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    l10n.gameActionRemove,
                                    style: TextStyle(color: AppTheme.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true || !context.mounted) return;
                          final result = await context
                              .read<GameProvider>()
                              .deleteRound(game.id, round.id);
                          if (context.mounted) {
                            await _handleResult(context, result);
                          }
                        }
                      : null,
                ),
              );
            }),
          if (canAddRound) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => _showAddRoundSheet(context),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLoading
                        ? AppTheme.accent.withAlpha(76)
                        : AppTheme.accent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.gameAddRound,
                  style: TextStyle(
                    color: isLoading
                        ? AppTheme.accent.withAlpha(76)
                        : AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddRoundSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accepted = game.players.where((p) => p.isAccepted).toList();
    final scoreAController = TextEditingController();
    final scoreBController = TextEditingController();
    final List<int> selectedA = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final remaining = accepted
                .where((p) => !selectedA.contains(p.id))
                .map((p) => p.id)
                .toList();
            final teamB = selectedA.length == 2 ? remaining : <int>[];

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 20, 16,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gameAddRound,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.gamePickTeamA,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: accepted.map((p) {
                      final isSelectedA = selectedA.contains(p.id);
                      final isTeamB = teamB.contains(p.id);
                      final Color chipColor = isSelectedA
                          ? AppTheme.accent
                          : isTeamB
                              ? const Color(0xFF7C3AED)
                              : AppTheme.textSecondary;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelectedA) {
                              selectedA.remove(p.id);
                            } else if (selectedA.length < 2) {
                              selectedA.add(p.id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: chipColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: chipColor, width: 1),
                          ),
                          child: Text(
                            p.fullName,
                            style: TextStyle(
                              color: chipColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreField(
                          label: l10n.gameRoundScoreA,
                          controller: scoreAController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ScoreField(
                          label: l10n.gameRoundScoreB,
                          controller: scoreBController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<GameProvider>(
                    builder: (_, provider, _) {
                      final isLoading = provider.isActionLoading;
                      final canSubmit = selectedA.length == 2 && teamB.length == 2;
                      return GestureDetector(
                        onTap: (!canSubmit || isLoading)
                            ? null
                            : () async {
                                final a = int.tryParse(scoreAController.text);
                                final b = int.tryParse(scoreBController.text);
                                final result = await context.read<GameProvider>().addRound(
                                  game.id,
                                  {
                                    'pair_a': selectedA,
                                    'pair_b': teamB,
                                    'score_a': a,
                                    'score_b': b,
                                  },
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  await _handleResult(context, result);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (!canSubmit || isLoading)
                                ? AppTheme.accent.withAlpha(76)
                                : AppTheme.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.gameRoundSave,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ScoreField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ScoreField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 2,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            hintText: '0',
            hintStyle: TextStyle(
              color: AppTheme.textPrimary.withAlpha(77),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: AppTheme.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2A3330), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Карточка одного раунда: заголовок, команды A/B со счётом,
/// в режиме редактирования — поля ввода счёта (Американо) либо иконка удаления
/// (Sets/Points).
class _RoundCard extends StatefulWidget {
  final Game game;
  final GameRound round;
  final bool editable;
  final bool isLoading;
  final String Function(int userId) nameFor;
  final Future<void> Function(int a, int b) onSaveScore;
  final Future<void> Function()? onDelete;

  const _RoundCard({
    required this.game,
    required this.round,
    required this.editable,
    required this.isLoading,
    required this.nameFor,
    required this.onSaveScore,
    this.onDelete,
  });

  @override
  State<_RoundCard> createState() => _RoundCardState();
}

class _RoundCardState extends State<_RoundCard> {
  late TextEditingController _controllerA;
  late TextEditingController _controllerB;

  @override
  void initState() {
    super.initState();
    _controllerA = TextEditingController(
      text: widget.round.scoreA?.toString() ?? '',
    );
    _controllerB = TextEditingController(
      text: widget.round.scoreB?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    super.dispose();
  }

  bool get _aWinning {
    final a = widget.round.scoreA;
    final b = widget.round.scoreB;
    if (a == null || b == null) return false;
    return a > b;
  }

  bool get _bWinning {
    final a = widget.round.scoreA;
    final b = widget.round.scoreB;
    if (a == null || b == null) return false;
    return b > a;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAmericano = widget.game.isAmericano;
    final showScoreEntry = widget.editable && isAmericano;
    final showDelete = widget.editable && widget.onDelete != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.gameRoundNo(widget.round.roundNo),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (showDelete)
                GestureDetector(
                  onTap: widget.isLoading ? null : widget.onDelete,
                  child: Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTeamRow(
            label: l10n.gameTeamA,
            pair: widget.round.pairA,
            score: widget.round.scoreA,
            isWinning: _aWinning,
          ),
          const SizedBox(height: 6),
          _buildTeamRow(
            label: l10n.gameTeamB,
            pair: widget.round.pairB,
            score: widget.round.scoreB,
            isWinning: _bWinning,
          ),
          if (showScoreEntry) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ScoreField(
                    label: l10n.gameRoundScoreA,
                    controller: _controllerA,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScoreField(
                    label: l10n.gameRoundScoreB,
                    controller: _controllerB,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: widget.isLoading
                  ? null
                  : () {
                      final a = int.tryParse(_controllerA.text) ?? 0;
                      final b = int.tryParse(_controllerB.text) ?? 0;
                      widget.onSaveScore(a, b);
                    },
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? AppTheme.accent.withAlpha(76)
                      : AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.gameRoundSave,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required String label,
    required List<int> pair,
    required int? score,
    required bool isWinning,
  }) {
    final names = pair.map(widget.nameFor).join(' / ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isWinning ? AppTheme.accent.withAlpha(15) : Colors.white.withAlpha(7),
        borderRadius: BorderRadius.circular(10),
        border: isWinning
            ? Border.all(color: AppTheme.accent.withAlpha(38), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  names.isEmpty ? '—' : names,
                  style: TextStyle(
                    color: isWinning ? Colors.white : Colors.white.withAlpha(178),
                    fontSize: 13,
                    fontWeight: isWinning ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score?.toString() ?? '–',
            style: TextStyle(
              color: isWinning ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
