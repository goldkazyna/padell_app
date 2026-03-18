import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge.dart';
import '../widgets/challenges/court_widget.dart';
import '../widgets/challenges/score_input_widget.dart';

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
              const Text(
                'Выберите позицию',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Позиции 1-2 — Команда A, 3-4 — Команда B',
                style: TextStyle(
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
                              pos <= 2 ? 'Команда A' : 'Команда B',
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

  Future<void> _cancelChallenge(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Отменить поединок?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Вы уверены, что хотите отменить поединок?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Да, отменить', style: TextStyle(color: AppTheme.error)),
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
    }
    _showSnackBar(result.message);
  }

  Future<void> _submitScore(int id) async {
    final result = await context
        .read<ChallengeProvider>()
        .submitScore(id, _sets);
    _showSnackBar(result.message);
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
                              child: const Text(
                                'Повторить',
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Поединок не найден',
                        style: TextStyle(color: AppTheme.textSecondary),
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
                          if (challenge.status == 'in_progress' &&
                              challenge.isCreator)
                            _buildScoreInput(challenge),
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
          const Expanded(
            child: Text(
              'Поединок',
              style: TextStyle(
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
                  'Уровень ${challenge.levelText}',
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
        const Text(
          'СЧЁТ',
          style: TextStyle(
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
              isEditable: true,
              onScoreChanged: (a, b) => _updateSet(i, a, b),
              onDelete: i > 0 ? () => _removeSet(i) : null,
            ),
          );
        }),
        const SizedBox(height: 8),
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppTheme.accent, size: 20),
                SizedBox(width: 6),
                Text(
                  'Добавить сет',
                  style: TextStyle(
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
            child: const Text(
              'Сохранить результат',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
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
    if (totalA > totalB) {
      resultText = 'Победа команды A';
      resultColor = AppTheme.accent;
    } else if (totalB > totalA) {
      resultText = 'Победа команды B';
      resultColor = AppTheme.accent;
    } else {
      resultText = 'Ничья';
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
          const Text(
            'РЕЗУЛЬТАТ',
            style: TextStyle(
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
                    'Сет ${i + 1}',
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
          label: 'Принять',
          onTap: isLoading ? null : () => _acceptChallenge(challenge.id),
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        _buildOutlineButton(
          label: 'Отклонить',
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
          label: 'Занять место',
          onTap: isLoading ? null : () => _joinChallenge(challenge),
          isLoading: isLoading,
        ),
      );
    }

    // Open + participant + creator
    if (challenge.isOpen && challenge.isParticipant && challenge.isCreator && challenge.confirmedCount < 4) {
      // Если все места заняты но есть invited — показать ожидание
      if (challenge.isFull && challenge.confirmedCount < 4) {
        buttons.add(
          _buildOutlineButton(
            label: 'Ожидание подтверждения игроков',
            color: AppTheme.textSecondary,
            onTap: null,
          ),
        );
        buttons.add(const SizedBox(height: 10));
      }
      buttons.add(
        _buildOutlineButton(
          label: 'Отменить поединок',
          color: AppTheme.error,
          onTap: isLoading ? null : () => _cancelChallenge(challenge.id),
        ),
      );
    }

    // Open + participant + NOT creator => leave
    if (challenge.isOpen && challenge.isParticipant && !challenge.isCreator) {
      buttons.add(
        _buildOutlineButton(
          label: 'Покинуть',
          color: AppTheme.error,
          onTap: isLoading ? null : () => _leaveChallenge(challenge.id),
        ),
      );
    }

    // Ready (or all 4 confirmed) + creator => start + cancel
    if ((challenge.isReady || (challenge.isOpen && challenge.confirmedCount >= 4)) && challenge.isCreator) {
      buttons.addAll([
        _buildPrimaryButton(
          label: 'Начать поединок',
          onTap: isLoading ? null : () => _startChallenge(challenge.id),
          isLoading: isLoading,
        ),
        const SizedBox(height: 10),
        _buildOutlineButton(
          label: 'Отменить',
          color: AppTheme.error,
          onTap: isLoading ? null : () => _cancelChallenge(challenge.id),
        ),
      ]);
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
          color: onTap != null ? AppTheme.accent : AppTheme.accent.withAlpha(128),
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
