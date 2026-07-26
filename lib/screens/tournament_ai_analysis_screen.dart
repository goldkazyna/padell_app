import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

/// Экран AI-разбора выступления игрока в турнире.
/// Данные генерирует бэкенд (Claude) и кэширует, поэтому повторные заходы
/// мгновенные.
class TournamentAiAnalysisScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;
  final int? playerId;

  const TournamentAiAnalysisScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    this.playerId,
  });

  @override
  State<TournamentAiAnalysisScreen> createState() =>
      _TournamentAiAnalysisScreenState();
}

class _TournamentAiAnalysisScreenState
    extends State<TournamentAiAnalysisScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _result;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Грузим один раз, когда context уже валиден (для Localizations/Provider).
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final result = await context.read<ProfileService>().getTournamentAiAnalysis(
            widget.tournamentId,
            playerId: widget.playerId,
            lang: lang,
          );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      // Показываем реальную ошибку на экране (у юзера консоль не всегда видна).
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: _loading
                  ? _buildLoading(l10n)
                  : _error != null || _result == null
                      ? _buildError(l10n)
                      : _buildContent(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l10n.aiAnalysisTitle,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.tournamentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 3),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.aiAnalysisLoading,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.orange, size: 40),
            const SizedBox(height: 14),
            Text(
              l10n.aiAnalysisErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                ),
                child: Text(
                  l10n.aiAnalysisRetry,
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final a = (_result!['analysis'] as Map?)?.cast<String, dynamic>() ?? {};
    final matches = (_result!['matches'] as List?) ?? [];
    final headline = (a['headline'] as String?)?.trim() ?? '';
    final summary = (a['summary'] as String?)?.trim() ?? '';
    final factors = (a['factors'] as List?) ?? [];
    final bestMatch = a['best_match'] as Map<String, dynamic>?;
    final worstMatch = a['worst_match'] as Map<String, dynamic>?;
    final tips = (a['tips'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headline.isNotEmpty) _buildHeadline(headline),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              summary,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
          if (matches.isNotEmpty) ...[
            const SizedBox(height: 22),
            _sectionTitle(l10n.aiMatchesTitle),
            const SizedBox(height: 10),
            ...matches
                .whereType<Map>()
                .map((m) => _matchBreakdownCard(l10n, m.cast<String, dynamic>())),
          ],
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 22),
            _sectionTitle(l10n.aiAnalysisFactorsTitle),
            const SizedBox(height: 10),
            ...factors.whereType<Map>().map((f) => _factorCard(
                  (f['title'] as String?)?.trim() ?? '',
                  (f['detail'] as String?)?.trim() ?? '',
                )),
          ],
          if (bestMatch != null) ...[
            const SizedBox(height: 12),
            _matchCard(
              icon: Icons.trending_up,
              color: AppTheme.accent,
              label: l10n.aiAnalysisBestMatch,
              match: bestMatch,
            ),
          ],
          if (worstMatch != null) ...[
            const SizedBox(height: 12),
            _matchCard(
              icon: Icons.trending_down,
              color: AppTheme.orange,
              label: l10n.aiAnalysisWorstMatch,
              match: worstMatch,
            ),
          ],
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 22),
            _sectionTitle(l10n.aiAnalysisTipsTitle),
            const SizedBox(height: 10),
            ...tips.whereType<String>().map(_tipRow),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.aiAnalysisFootnote,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(String headline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              headline,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _factorCard(String title, String detail) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (title.isNotEmpty && detail.isNotEmpty) const SizedBox(height: 5),
          if (detail.isNotEmpty)
            Text(
              detail,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _matchCard({
    required IconData icon,
    required Color color,
    required String label,
    required Map<String, dynamic> match,
  }) {
    final matchLabel = (match['label'] as String?)?.trim() ?? '';
    final detail = (match['detail'] as String?)?.trim() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (matchLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              matchLabel,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _explainMatch(
      AppLocalizations l10n, String result, int? myAvg, int? oppAvg, int delta) {
    if (delta == 0) return l10n.aiMatchNoEffect;
    final strongerOpp = myAvg != null && oppAvg != null && oppAvg > myAvg;
    if (result == 'win') {
      return strongerOpp ? l10n.aiMatchWinStrong : l10n.aiMatchWinExpected;
    }
    return strongerOpp ? l10n.aiMatchLossFavorite : l10n.aiMatchLossWeak;
  }

  Widget _pairBlock(String label, int? avg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 2),
        Text(
          avg != null ? '~$avg' : '—',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _matchBreakdownCard(AppLocalizations l10n, Map<String, dynamic> m) {
    final round = (m['round'] as String?)?.trim() ?? '';
    final scoreMy = m['score_my'] ?? 0;
    final scoreOpp = m['score_opponent'] ?? 0;
    final result = (m['result'] as String?) ?? '';
    final myAvg = m['my_avg'] as int?;
    final oppAvg = m['opp_avg'] as int?;
    final winProb = m['win_prob'] as int?;
    final delta = (m['delta'] as int?) ?? 0;

    final isWin = result == 'win';
    final resultColor = isWin ? AppTheme.accent : AppTheme.orange;
    final deltaColor = delta > 0
        ? AppTheme.accent
        : (delta < 0 ? AppTheme.orange : AppTheme.textSecondary);
    final deltaText = delta > 0 ? '+$delta' : '$delta';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  round,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                '$scoreMy : $scoreOpp',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isWin ? l10n.aiResultWin : l10n.aiResultLoss,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _pairBlock(l10n.aiYourPair, myAvg)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('vs',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              Expanded(child: _pairBlock(l10n.aiOpponents, oppAvg)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                winProb != null
                    ? '${l10n.aiWinChance}: $winProb%'
                    : l10n.aiWinChance,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                deltaText,
                style: TextStyle(
                  color: deltaColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _explainMatch(l10n, result, myAvg, oppAvg, delta),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
