import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../widgets/challenges/court_widget.dart';
import '../widgets/challenges/score_input_widget.dart';
import '../l10n/app_localizations.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  List<Map<String, int>> _sets = [{'team_a': 0, 'team_b': 0}];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ChallengeProvider>()
          .loadChallengeDetails(widget.challengeId);
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        content: Text(message, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinChallenge(Challenge challenge) async {
    final positions = challenge.availablePositions;
    if (positions.isEmpty) return;

    if (positions.length == 1) {
      final result = await context
          .read<ChallengeProvider>()
          .joinChallenge(challenge.id, positions.first);
      _showSnackBar(result.message);
      return;
    }

    // Show position picker
    if (!mounted) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.challengeChoosePosition,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.challengePositionHint,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ...positions.map(
                (pos) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, pos),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$pos',
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pos <= 2 ? AppLocalizations.of(context)!.challengeTeamA : AppLocalizations.of(context)!.challengeTeamB,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    final result = await context
        .read<ChallengeProvider>()
        .joinChallenge(challenge.id, selected);
    _showSnackBar(result.message);
  }

  Future<void> _startChallenge(int id) async {
    final result =
        await context.read<ChallengeProvider>().startChallenge(id);
    _showSnackBar(result.message);
  }

  Future<void> _confirmScore(int id) async {
    final result =
        await context.read<ChallengeProvider>().confirmScore(id);
    if (mounted) _showSnackBar(result.message);
  }

  Future<void> _cancelChallenge(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(AppLocalizations.of(context)!.challengeCancelTitle, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(AppLocalizations.of(context)!.challengeCancelConfirm, style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.challengeYesCancel, style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await context.read<ChallengeProvider>().cancelChallenge(id);
    if (result.success && mounted) {
      Navigator.pop(context);
      return;
    }
    if (mounted) _showSnackBar(result.message);
  }

  Future<void> _leaveChallenge(int id) async {
    final result =
        await context.read<ChallengeProvider>().leaveChallenge(id);
    if (result.success && mounted) {
      Navigator.pop(context);
    }
    _showSnackBar(result.message);
  }

  Future<void> _acceptChallenge(int id) async {
    final result =
        await context.read<ChallengeProvider>().acceptChallenge(id);
    _showSnackBar(result.message);
  }

  Future<void> _declineChallenge(int id) async {
    final result =
        await context.read<ChallengeProvider>().declineChallenge(id);
    if (result.success && mounted) {
      Navigator.pop(context);
      return;
    }
    if (mounted) _showSnackBar(result.message);
  }

  Future<void> _submitScore(int id) async {
    // Проверяем что хотя бы в одном сете счёт не 0:0
    final allZero = _sets.every((s) => (s['team_a'] ?? 0) == 0 && (s['team_b'] ?? 0) == 0);
    if (allZero) {
      if (mounted) _showSnackBar(AppLocalizations.of(context)!.challengeEnterScore);
      return;
    }

    final result = await context
        .read<ChallengeProvider>()
        .submitScore(id, _sets);
    if (mounted) _showSnackBar(result.message);
  }

  void _addSet() {
    setState(() {
      _sets = [..._sets, {'team_a': 0, 'team_b': 0}];
    });
  }

  void _removeSet(int index) {
    if (_sets.length <= 1) return;
    setState(() {
      _sets = List.from(_sets)..removeAt(index);
    });
  }

  void _updateSet(int index, int scoreA, int scoreB) {
    setState(() {
      _sets = List.from(_sets);
      _sets[index] = {'team_a': scoreA, 'team_b': scoreB};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<ChallengeProvider>(
          builder: (_, provider, __) {
            if (provider.isLoadingDetail) {
              return Column(
                children: [
                  _buildHeader(),
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.accent),
                    ),
                  ),
                ],
              );
            }

            if (provider.error != null && provider.currentChallenge == null) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => provider
                                .loadChallengeDetails(widget.challengeId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.retry,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final challenge = provider.currentChallenge;
            if (challenge == null) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.challengeNotFound,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider
                        .loadChallengeDetails(widget.challengeId),
                    color: AppTheme.accent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          // Status badge
                          _buildStatusBadge(challenge),
                          const SizedBox(height: 16),
                          // Info card
                          _buildInfoCard(challenge),
                          const SizedBox(height: 16),
                          // Court
                          CourtWidget(
                            players: challenge.players,
                            status: challenge.status,
                            myUserId: null,
                            isEditing: false,
                            onPositionTap: challenge.isOpen &&
                                    !challenge.isParticipant &&
                                    challenge.availablePositions.isNotEmpty
                                ? (_) => _joinChallenge(challenge)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // Score section for in_progress
                          if (challenge.status == 'in_progress')
                            _buildScoreInput(challenge),
                          // Pending confirmation section
                          if (challenge.isPendingConfirmation)
                            _buildPendingConfirmation(challenge),
                          // Result section for completed
                          if (challenge.isCompleted)
                            _buildResultCard(challenge),
                          // Action buttons
                          _buildActionButtons(challenge, provider),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.challenge,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Challenge challenge) {
    Color badgeColor;
    switch (challenge.status) {
      case 'open':
      case 'waiting':
        badgeColor = const Color(0xFFEAB308); // yellow
        break;
      case 'ready':
      case 'in_progress':
        badgeColor = AppTheme.accent;
        break;
      case 'completed':
        badgeColor = const Color(0xFF3B82F6); // blue
        break;
      case 'cancelled':
        badgeColor = AppTheme.error;
        break;
      default:
        badgeColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        challenge.statusName,
        style: TextStyle(
          color: badgeColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildInfoCard(Challenge challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & time
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${challenge.dayOfWeek}, ${challenge.dateFormatted} в ${challenge.timeFormatted}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Club
          if (challenge.club != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.club!.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          // Level
          Row(
            children: [
              const Icon(Icons.trending_up,
                  color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.challengeLevel(challenge.levelText),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Type badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: challenge.typeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  challenge.typeName,
                  style: TextStyle(
                    color: challenge.typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInput(Challenge challenge) {
    final teamA = challenge.teamAPlayers;
    final teamB = challenge.teamBPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.challengeScore,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_sets.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ScoreInputWidget(
              setIndex: i,
              teamA: teamA,
              teamB: teamB,
              scoreA: _sets[i]['team_a'],
              scoreB: _sets[i]['team_b'],
              isEditable: challenge.isCreator,
              onScoreChanged: challenge.isCreator ? (a, b) => _updateSet(i, a, b) : null,
              onDelete: challenge.isCreator && i > 0 ? () => _removeSet(i) : null,
            ),
          );
        }),
        const SizedBox(height: 8),
        if (challenge.isCreator) ...[
          // Add set button
          GestureDetector(
            onTap: _addSet,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.challengeAddSet,
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Submit score button
          GestureDetector(
            onTap: () => _submitScore(challenge.id),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withAlpha(76),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.challengeFinish,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ] else ...[
          // Info for non-creator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.challengeScoreCreatorHint,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPendingConfirmation(Challenge challenge) {
    final score = challenge.score;
    final myPlayer = challenge.players.where((p) => p.isMe).firstOrNull;
    final alreadyConfirmed = myPlayer?.scoreConfirmed ?? false;
    final isLoading = context.watch<ChallengeProvider>().isActionLoading;

    // Подсчёт счёта
    int teamAWins = 0, teamBWins = 0;
    if (score != null) {
      for (final s in score) {
        if (s.teamA > s.teamB) teamAWins++;
        else if (s.teamB > s.teamA) teamBWins++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.challengeResult,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Score summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
          ),
          child: Column(
            children: [
              // Total score
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$teamAWins', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(':', style: TextStyle(color: AppTheme.textSecondary, fontSize: 36, fontWeight: FontWeight.w700)),
                  ),
                  Text('$teamBWins', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              // Sets
              if (score != null)
                ...score.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    AppLocalizations.of(context)!.challengeSetScore(entry.key + 1, entry.value.teamA, entry.value.teamB),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                )),
              const SizedBox(height: 16),
              // Confirmation status
              ...challenge.players.map((player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: player.scoreConfirmed ? AppTheme.accent : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: player.avatar != null
                          ? Image.network(player.avatar!, fit: BoxFit.cover, width: 28, height: 28,
                              errorBuilder: (_, __, ___) => Text(player.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))
                          : Text(player.initials, style: TextStyle(color: player.scoreConfirmed ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        player.fullName,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      player.scoreConfirmed ? Icons.check_circle : Icons.schedule,
                      color: player.scoreConfirmed ? AppTheme.accent : AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.scoreConfirmed ? AppLocalizations.of(context)!.challengeConfirmed : AppLocalizations.of(context)!.challengeWaiting,
                      style: TextStyle(
                        color: player.scoreConfirmed ? AppTheme.accent : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Confirm button
        if (!alreadyConfirmed)
          GestureDetector(
            onTap: isLoading ? null : () => _confirmScore(challenge.id),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withAlpha(76),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(AppLocalizations.of(context)!.challengeConfirmScore, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.challengeScoreConfirmed, style: const TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultCard(Challenge challenge) {
    final score = challenge.score;
    if (score == null || score.isEmpty) return const SizedBox.shrink();

    int totalA = 0;
    int totalB = 0;
    for (final s in score) {
      if (s.teamA > s.teamB) {
        totalA++;
      } else if (s.teamB > s.teamA) {
        totalB++;
      }
    }

    String resultText;
    Color resultColor;
    final l10n = AppLocalizations.of(context)!;
    if (totalA > totalB) {
      resultText = l10n.challengeTeamAWin;
      resultColor = AppTheme.accent;
    } else if (totalB > totalA) {
      resultText = l10n.challengeTeamBWin;
      resultColor = AppTheme.accent;
    } else {
      resultText = l10n.challengeDraw;
      resultColor = const Color(0xFFEAB308);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.challengeResult,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Total score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$totalA',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$totalB',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Winner text
          Text(
            resultText,
            style: TextStyle(
              color: resultColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Individual set scores
          ...List.generate(score.length, (i) {
            final s = score[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.challengeSetLabel(i + 1),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${s.teamA} : ${s.teamB}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          // ELO change
          if (challenge.myRatingChange != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: challenge.myRatingChange! >= 0
                    ? AppTheme.accent.withAlpha(25)
                    : AppTheme.error.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${challenge.myRatingChange! >= 0 ? '+' : ''}${challenge.myRatingChange} ELO',
                style: TextStyle(
                  color: challenge.myRatingChange! >= 0
                      ? AppTheme.accent
                      : AppTheme.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(Challenge challenge, ChallengeProvider provider) {
    final isLoading = provider.isActionLoading;
    final List<Widget> buttons = [];

    // Invited state
    if (challenge.myStatus == 'invited') {
      buttons.addAll([
        _buildPrimaryButton(
          label: AppLocalizations.of(context)!.challengeAccept,
          onTap: isLoading ? null : () => _acceptChallenge(challenge.id),
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        _buildOutlineButton(
          label: AppLocalizations.of(context)!.challengeDecline,
          color: AppTheme.error,
          onTap: isLoading ? null : () => _declineChallenge(challenge.id),
        ),
      ]);
    }

    // Open + not participant => join
    if (challenge.isOpen &&
        !challenge.isParticipant &&
        challenge.availablePositions.isNotEmpty) {
      buttons.add(
        _buildPrimaryButton(
          label: AppLocalizations.of(context)!.challengeJoinSlot,
          onTap: isLoading ? null : () => _joinChallenge(challenge),
          isLoading: isLoading,
        ),
      );
    }

    // Open or Ready + participant + creator
    if ((challenge.isOpen || challenge.isReady) && challenge.isParticipant && challenge.isCreator) {
      final canStart = challenge.confirmedCount >= 4 || challenge.isReady;

      // Подсказка
      if (!canStart) {
        final remaining = 4 - challenge.confirmedCount;
        final hasInvited = challenge.players.any((p) => p.isInvited);
        String hint;
        if (hasInvited) {
          hint = AppLocalizations.of(context)!.challengeWaitingInvites;
        } else {
          hint = AppLocalizations.of(context)!.challengeNeedMorePlayers(remaining);
        }
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        );
      }

      // Кнопка «Начать» — всегда видна, активна только когда все на месте
      buttons.add(
        _buildPrimaryButton(
          label: AppLocalizations.of(context)!.challengeStart,
          onTap: canStart && !isLoading ? () => _startChallenge(challenge.id) : null,
          isLoading: isLoading && canStart,
        ),
      );
      buttons.add(const SizedBox(height: 10));
      buttons.add(
        _buildOutlineButton(
          label: AppLocalizations.of(context)!.challengeCancelButton,
          color: AppTheme.error,
          onTap: isLoading ? null : () => _cancelChallenge(challenge.id),
        ),
      );
    }

    // Open + participant + NOT creator + NOT invited => leave
    if (challenge.isOpen && challenge.isParticipant && !challenge.isCreator && challenge.myStatus != 'invited') {
      buttons.add(
        _buildOutlineButton(
          label: AppLocalizations.of(context)!.challengeLeave,
          color: AppTheme.error,
          onTap: isLoading ? null : () => _leaveChallenge(challenge.id),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(children: buttons),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.accent : AppTheme.accent.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          boxShadow: onTap != null ? [
            BoxShadow(
              color: AppTheme.accent.withAlpha(76),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ] : [],
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
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
