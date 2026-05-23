import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_club_user.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';
import '../../widgets/verified_badge.dart';

/// Экран управления игроками клуба (только для club_admin клуба
/// с включённой feature 'users').
class AdminUsersScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const AdminUsersScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _searchDebounce;

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  List<AdminClubUser> _users = [];
  AdminClubUsersStats? _stats;
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;

  String? _activeLevel; // '1' '2' '3' '4' '5' или null
  String? _verifiedFilter; // 'verified' | 'unverified' | null

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _page < _totalPages) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
    });
    try {
      final r = await context.read<AdminService>().getClubUsers(
            widget.clubId,
            search: _searchCtrl.text.trim(),
            level: _activeLevel,
            verified: _verifiedFilter,
            page: 1,
          );
      if (!mounted) return;
      setState(() {
        _users = r.users;
        _stats = r.stats;
        _page = r.page;
        _totalPages = r.totalPages;
        _total = r.total;
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

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final r = await context.read<AdminService>().getClubUsers(
            widget.clubId,
            search: _searchCtrl.text.trim(),
            level: _activeLevel,
            verified: _verifiedFilter,
            page: next,
          );
      if (!mounted) return;
      setState(() {
        _users = [..._users, ...r.users];
        _page = r.page;
        _totalPages = r.totalPages;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _load);
  }

  Future<void> _openEditSheet(AdminClubUser user) async {
    final updated = await showModalBottomSheet<AdminClubUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditUserSheet(
        clubId: widget.clubId,
        initial: user,
      ),
    );
    if (updated != null && mounted) {
      // Заменяем строку в списке
      final idx = _users.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        setState(() => _users[idx] = updated);
      } else {
        _load();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: const MainTabBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildLevelChips(),
            _buildVerifiedChips(),
            const SizedBox(height: 4),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Пользователи',
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_total > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '$_total',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Имя или ID',
          hintStyle: const TextStyle(color: AppTheme.textDim),
          prefixIcon:
              const Icon(Icons.search, color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.card,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelChips() {
    final stats = _stats;
    final entries = <(String key, String label, int count)>[
      ('all', 'Все', _total),
      ('1', 'L1', stats?.l1 ?? 0),
      ('2', 'L2', stats?.l2 ?? 0),
      ('3', 'L3', stats?.l3 ?? 0),
      ('4', 'L4', stats?.l4 ?? 0),
      ('5', 'L5', stats?.l5 ?? 0),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final e in entries) ...[
            _Chip(
              label: '${e.$2} · ${e.$3}',
              isActive:
                  (e.$1 == 'all' && _activeLevel == null) ||
                      _activeLevel == e.$1,
              onTap: () {
                setState(() => _activeLevel = e.$1 == 'all' ? null : e.$1);
                _load();
              },
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifiedChips() {
    final entries = <(String?, String)>[
      (null, 'Все'),
      ('verified', 'Верифицированные'),
      ('unverified', 'Без верификации'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final e in entries) ...[
              _Chip(
                label: e.$2,
                isActive: _verifiedFilter == e.$1,
                onTap: () {
                  setState(() => _verifiedFilter = e.$1);
                  _load();
                },
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }
    if (_error != null && _users.isEmpty) {
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
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _load,
                child: const Text('Повторить',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(
        child: Text('Никого не нашли',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _users.length + (_loadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent),
                ),
              ),
            );
          }
          return _buildUserTile(_users[i]);
        },
      ),
    );
  }

  Widget _buildUserTile(AdminClubUser u) {
    final initials = _initials(u.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _openEditSheet(u),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _avatar(u.avatarUrl, initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(u.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (u.levelVerified) ...[
                            const SizedBox(width: 5),
                            const VerifiedBadge(size: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          'ID ${u.id}',
                          if (u.level != null) 'L${_fmtLevel(u.level!)}',
                          'Рейтинг ${u.rating}',
                        ].join(' · '),
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textDim, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url, String initials) {
    final fallback = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700)),
    );
    if ((url ?? '').isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  String _fmtLevel(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? v.toInt().toString() : s;
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accent.withOpacity(0.15)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppTheme.accent : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Bottom sheet редактирования
// =============================================================================

class _EditUserSheet extends StatefulWidget {
  final int clubId;
  final AdminClubUser initial;

  const _EditUserSheet({
    required this.clubId,
    required this.initial,
  });

  @override
  State<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<_EditUserSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial.name);
  late double? _level = widget.initial.level;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Имя не может быть пустым');
      return;
    }
    if (_level != null && (_level! < 1.0 || _level! > 5.75)) {
      setState(() => _error = 'Уровень от 1.0 до 5.75');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await context.read<AdminService>().updateClubUser(
            widget.clubId,
            widget.initial.id,
            name: name,
            level: _level,
          );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  void _stepLevel(double delta) {
    final cur = _level ?? 1.0;
    var next = cur + delta;
    next = (next * 4).round() / 4; // шаг 0.25
    if (next < 1.0) next = 1.0;
    if (next > 5.75) next = 5.75;
    setState(() => _level = next);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardRaised,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Редактировать игрока',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID ${widget.initial.id}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Имя',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              TextField(
                controller: _name,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.card,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('Уровень',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _stepLevel(-0.25),
                      icon: const Icon(Icons.remove,
                          color: AppTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        _level != null
                            ? _level!.toStringAsFixed(2)
                            : '—',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _stepLevel(0.25),
                      icon: const Icon(Icons.add,
                          color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Рейтинг пересчитается автоматически (level × 1000 + 125).',
                style: const TextStyle(
                    color: AppTheme.textDim, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (_) {
                  final hasAvatar =
                      (widget.initial.avatarUrl ?? '').isNotEmpty;
                  final color =
                      hasAvatar ? AppTheme.accent : AppTheme.amber;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            hasAvatar
                                ? Icons.verified_outlined
                                : Icons.warning_amber_rounded,
                            color: color,
                            size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasAvatar
                                ? 'Уровень будет автоматически отмечен как верифицированный'
                                : 'У игрока нет фото — уровень НЕ будет верифицирован',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: AppTheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.cardRaised),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Отмена',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppTheme.accent.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _saving ? 'Сохранение...' : 'Сохранить',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
