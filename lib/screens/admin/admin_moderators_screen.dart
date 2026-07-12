import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_club_moderator.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/main_tab_bar.dart';

/// Экран управления модераторами клуба (только club_admin, feature 'moderators').
class AdminModeratorsScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const AdminModeratorsScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<AdminModeratorsScreen> createState() => _AdminModeratorsScreenState();
}

class _AdminModeratorsScreenState extends State<AdminModeratorsScreen> {
  bool _loading = true;
  String? _error;
  List<AdminClubModerator> _moderators = [];

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
      final mods =
          await context.read<AdminService>().getClubModerators(widget.clubId);
      if (!mounted) return;
      setState(() {
        _moderators = mods;
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

  Future<void> _openAddSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddModeratorSheet(clubId: widget.clubId),
    );
    if (added == true) _load();
  }

  Future<void> _openEditSheet(AdminClubModerator mod) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPermsSheet(clubId: widget.clubId, moderator: mod),
    );
    if (changed == true) _load();
  }

  Future<void> _confirmDelete(AdminClubModerator mod) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Удалить модератора?',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        content: Text('${mod.name} больше не будет модератором клуба.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Удалить',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context
          .read<AdminService>()
          .removeModerator(widget.clubId, mod.id);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: const MainTabBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildAddButton(),
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
                Text('Модераторы',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                Text(widget.clubName,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _openAddSheet,
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          label: const Text('Добавить модератора',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
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
        child: Text(_error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary)),
      ));
    }
    if (_moderators.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined,
                  color: AppTheme.textSecondary, size: 40),
              SizedBox(height: 12),
              Text('Модераторов пока нет',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _moderators.length,
      itemBuilder: (_, i) => _buildTile(_moderators[i]),
    );
  }

  Widget _buildTile(AdminClubModerator m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _avatar(m.avatarUrl, _initials(m.name)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _badge(
                        m.tournamentsFullAccess
                            ? 'Полный доступ'
                            : 'Только модерация',
                        m.tournamentsFullAccess
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                      ),
                      if (m.canViewActivityLog)
                        _badge('Журнал', AppTheme.amber),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openEditSheet(m),
              icon: Icon(Icons.tune,
                  color: AppTheme.textSecondary, size: 20),
              tooltip: 'Права',
            ),
            IconButton(
              onPressed: () => _confirmDelete(m),
              icon: Icon(Icons.delete_outline,
                  color: AppTheme.error, size: 20),
              tooltip: 'Удалить',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _avatar(String? url, String initials) {
    final fallback = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: AppTheme.cardRaised, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700)),
    );
    if ((url ?? '').isEmpty) return fallback;
    return ClipOval(
      child: Image.network(url!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Лист добавления модератора: поиск по телефону → выбор → права → добавить
// ---------------------------------------------------------------------------

class _AddModeratorSheet extends StatefulWidget {
  final int clubId;
  const _AddModeratorSheet({required this.clubId});

  @override
  State<_AddModeratorSheet> createState() => _AddModeratorSheetState();
}

class _AddModeratorSheetState extends State<_AddModeratorSheet> {
  final _phone = TextEditingController();
  bool _searching = false;
  bool _saving = false;
  String? _error;
  List<ModeratorCandidate> _results = [];
  ModeratorCandidate? _selected;
  bool _fullAccess = false;
  bool _activityLog = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _error = null;
      _results = [];
      _selected = null;
    });
    try {
      final users = await context
          .read<AdminService>()
          .searchModeratorCandidates(widget.clubId, _phone.text.trim());
      if (!mounted) return;
      setState(() {
        _results = users;
        _searching = false;
        if (users.isEmpty) _error = 'Пользователи не найдены';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _searching = false;
      });
    }
  }

  Future<void> _add() async {
    if (_selected == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AdminService>().addModerator(
            widget.clubId,
            userId: _selected!.id,
            tournamentsFullAccess: _fullAccess,
            canViewActivityLog: _activityLog,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Добавить модератора',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Найдите пользователя по номеру телефона',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Телефон',
                        hintStyle: TextStyle(color: AppTheme.textDim),
                        filled: true,
                        fillColor: AppTheme.card,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _searching ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.card,
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.accent))
                        : const Text('Найти'),
                  ),
                ],
              ),
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final u = _results[i];
                      final selected = _selected?.id == u.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = u),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.accent
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(u.name,
                                        style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        if ((u.phone ?? '').isNotEmpty)
                                          u.phone!,
                                        if (u.level != null)
                                          'L${u.level!.toStringAsFixed(2)}',
                                      ].join(' · '),
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle,
                                    color: AppTheme.accent, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (_selected != null) ...[
                const SizedBox(height: 8),
                _PermSwitch(
                  title: 'Полный доступ к турнирам',
                  subtitle: 'Иначе — только модерация',
                  value: _fullAccess,
                  onChanged: (v) => setState(() => _fullAccess = v),
                ),
                _PermSwitch(
                  title: 'Доступ к журналу активности',
                  subtitle: 'Видит лог действий клуба',
                  value: _activityLog,
                  onChanged: (v) => setState(() => _activityLog = v),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: TextStyle(
                        color: AppTheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selected == null || _saving) ? null : _add,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppTheme.cardRaised,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('Добавить модератором',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Лист изменения прав модератора
// ---------------------------------------------------------------------------

class _EditPermsSheet extends StatefulWidget {
  final int clubId;
  final AdminClubModerator moderator;
  const _EditPermsSheet({required this.clubId, required this.moderator});

  @override
  State<_EditPermsSheet> createState() => _EditPermsSheetState();
}

class _EditPermsSheetState extends State<_EditPermsSheet> {
  late bool _fullAccess = widget.moderator.tournamentsFullAccess;
  late bool _activityLog = widget.moderator.canViewActivityLog;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AdminService>().updateModeratorPermissions(
            widget.clubId,
            widget.moderator.id,
            tournamentsFullAccess: _fullAccess,
            canViewActivityLog: _activityLog,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Права модератора',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(widget.moderator.name,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              _PermSwitch(
                title: 'Полный доступ к турнирам',
                subtitle: 'Иначе — только модерация',
                value: _fullAccess,
                onChanged: (v) => setState(() => _fullAccess = v),
              ),
              _PermSwitch(
                title: 'Доступ к журналу активности',
                subtitle: 'Видит лог действий клуба',
                value: _activityLog,
                onChanged: (v) => setState(() => _activityLog = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: TextStyle(
                        color: AppTheme.error, fontSize: 12)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('Сохранить',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }
}
