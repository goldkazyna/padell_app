import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_tournament_summary.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import 'admin_tournament_detail_screen.dart';

class AdminTournamentsScreen extends StatefulWidget {
  final int? clubId; // null = личные турниры игрока
  final String clubName;

  const AdminTournamentsScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends State<AdminTournamentsScreen> {
  bool _loading = true;
  String? _error;
  List<AdminTournamentSummary> _all = [];
  String _activeStatus = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final admin = context.read<AdminService>();
      final list = widget.clubId == null
          ? await admin.getPersonalTournaments()
          : await admin.getClubTournaments(widget.clubId!);
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<AdminTournamentSummary> get _filtered {
    if (_activeStatus == 'all') return _all;
    return _all.where((t) => t.status == _activeStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: const MainTabBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildStatusTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Мои турниры',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  widget.clubName,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    final tabs = <Map<String, String>>[
      {'key': 'all', 'label': 'Все'},
      {'key': 'draft', 'label': 'Черновики'},
      {'key': 'open', 'label': 'Открытые'},
      {'key': 'in_progress', 'label': 'Идут'},
      {'key': 'completed', 'label': 'Завершены'},
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab = tabs[i];
          final key = tab['key']!;
          final label = tab['label']!;
          final count = key == 'all'
              ? _all.length
              : _all.where((t) => t.status == key).length;
          final isActive = _activeStatus == key;
          return GestureDetector(
            onTap: () => setState(() => _activeStatus = key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.accent.withAlpha(40)
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive
                      ? AppTheme.accent.withAlpha(120)
                      : const Color(0xFF2A2A2A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accent.withAlpha(80)
                          : const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.accent
                            : AppTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events_outlined,
                  color: AppTheme.textDim, size: 48),
              SizedBox(height: 12),
              Text(
                'Нет турниров',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'В этой вкладке пока ничего нет',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _TournamentCard(
          summary: list[i],
          onTap: () => _openDetail(list[i]),
        ),
      ),
    );
  }

  Future<void> _openDetail(AdminTournamentSummary t) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTournamentDetailScreen(
          tournamentId: t.id,
          tournamentName: t.name,
        ),
      ),
    );
    if (changed == true && mounted) {
      _load();
    }
  }
}

class _TournamentCard extends StatelessWidget {
  final AdminTournamentSummary summary;
  final VoidCallback onTap;

  const _TournamentCard({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);
    final hasPending = summary.pendingCount > 0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Тип
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        summary.typeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Статус
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      summary.statusName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Дата + время
                  Text(
                    '${summary.date} · ${summary.time}',
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                summary.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_outline,
                      color: AppTheme.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${summary.participantsCount} / ${summary.maxParticipants}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.bar_chart,
                      color: AppTheme.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'L${_fmtLevel(summary.minLevel)}–${_fmtLevel(summary.maxLevel)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasPending) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.amber.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              color: AppTheme.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${summary.pendingCount} на модерации',
                            style: const TextStyle(
                              color: AppTheme.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return AppTheme.accent;
      case 'in_progress':
        return const Color(0xFF38BDF8);
      case 'completed':
        return const Color(0xFFA78BFA);
      case 'cancelled':
        return AppTheme.error;
      case 'closed':
        return AppTheme.amber;
      case 'draft':
      default:
        return AppTheme.textDim;
    }
  }

  String _fmtLevel(double level) {
    if (level == level.roundToDouble()) {
      return level.toStringAsFixed(2);
    }
    return level.toString();
  }
}

