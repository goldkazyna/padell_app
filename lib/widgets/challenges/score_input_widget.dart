import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/challenge.dart';
import '../../l10n/app_localizations.dart';

class ScoreInputWidget extends StatefulWidget {
  final int setIndex;
  final List<ChallengePlayer> teamA;
  final List<ChallengePlayer> teamB;
  final int? scoreA;
  final int? scoreB;
  final bool isEditable;
  final Function(int scoreA, int scoreB)? onScoreChanged;
  final VoidCallback? onDelete;

  const ScoreInputWidget({
    super.key,
    required this.setIndex,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    this.isEditable = true,
    this.onScoreChanged,
    this.onDelete,
  });

  @override
  State<ScoreInputWidget> createState() => _ScoreInputWidgetState();
}

class _ScoreInputWidgetState extends State<ScoreInputWidget> {
  late TextEditingController _controllerA;
  late TextEditingController _controllerB;
  late FocusNode _focusA;
  late FocusNode _focusB;

  @override
  void initState() {
    super.initState();
    _controllerA = TextEditingController();
    _controllerB = TextEditingController();
    _focusA = FocusNode();
    _focusB = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ScoreInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scoreA != widget.scoreA && widget.scoreA != null && widget.scoreA! > 0) {
      _controllerA.text = widget.scoreA.toString();
    }
    if (oldWidget.scoreB != widget.scoreB && widget.scoreB != null && widget.scoreB! > 0) {
      _controllerB.text = widget.scoreB.toString();
    }
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _focusA.dispose();
    _focusB.dispose();
    super.dispose();
  }

  void _onChanged() {
    final a = int.tryParse(_controllerA.text) ?? 0;
    final b = int.tryParse(_controllerB.text) ?? 0;
    widget.onScoreChanged?.call(a, b);
  }

  bool get _aWinning {
    final a = widget.scoreA ?? 0;
    final b = widget.scoreB ?? 0;
    return a > b && a > 0;
  }

  bool get _bWinning {
    final a = widget.scoreA ?? 0;
    final b = widget.scoreB ?? 0;
    return b > a && b > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppLocalizations.of(context)!.challengeSetLabel(widget.setIndex + 1),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.isEditable && widget.setIndex > 0)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Team A row
          _buildTeamRow(
            players: widget.teamA,
            isWinning: _aWinning,
            controller: _controllerA,
            focusNode: _focusA,
            nextFocus: _focusB,
            score: widget.scoreA,
          ),
          const SizedBox(height: 8),
          // Team B row
          _buildTeamRow(
            players: widget.teamB,
            isWinning: _bWinning,
            controller: _controllerB,
            focusNode: _focusB,
            nextFocus: null,
            score: widget.scoreB,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    required List<ChallengePlayer> players,
    required bool isWinning,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    int? score,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isWinning
            ? AppTheme.accent.withAlpha(15)
            : Colors.white.withAlpha(7),
        borderRadius: BorderRadius.circular(12),
        border: isWinning
            ? Border.all(color: AppTheme.accent.withAlpha(38), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Players with avatars
          Expanded(
            child: Column(
              children: List.generate(players.length, (i) {
                final player = players[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: i < players.length - 1 ? 8 : 0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: player.avatar != null
                            ? Image.network(
                                player.avatar!,
                                fit: BoxFit.cover,
                                width: 32,
                                height: 32,
                                errorBuilder: (_, __, ___) => Text(
                                  player.initials,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : Text(
                                player.initials,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // Name
                      Expanded(
                        child: Text(
                          player.fullName,
                          style: TextStyle(
                            color: isWinning ? Colors.white : Colors.white.withAlpha(178),
                            fontSize: 13,
                            fontWeight: isWinning ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          // Score
          widget.isEditable
              ? _buildScoreInput(controller, focusNode, nextFocus)
              : _buildScoreDisplay(score ?? 0, isWinning),
        ],
      ),
    );
  }

  Widget _buildScoreInput(
    TextEditingController controller,
    FocusNode currentFocus,
    FocusNode? nextFocus,
  ) {
    return SizedBox(
      width: 44,
      height: 44,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 2,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          hintText: '0',
          hintStyle: TextStyle(
            color: AppTheme.textPrimary.withAlpha(77),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: AppTheme.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.accent,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (_) => _onChanged(),
        onSubmitted: (_) {
          if (nextFocus != null) {
            nextFocus.requestFocus();
          } else {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }

  Widget _buildScoreDisplay(int score, bool isWinning) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinning ? AppTheme.accent.withAlpha(77) : const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: TextStyle(
          color: isWinning ? AppTheme.accent : Colors.white.withAlpha(128),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
