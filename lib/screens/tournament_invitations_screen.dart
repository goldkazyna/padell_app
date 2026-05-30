import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tournament_invitation.dart';
import '../services/invitation_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import 'tournament_detail_screen.dart';

class TournamentInvitationsScreen extends StatefulWidget {
  const TournamentInvitationsScreen({super.key});

  @override
  State<TournamentInvitationsScreen> createState() =>
      _TournamentInvitationsScreenState();
}

class _TournamentInvitationsScreenState
    extends State<TournamentInvitationsScreen> {
  List<TournamentInvitation> _items = [];
  bool _loading = true;
  String? _error;
  int? _busyId;

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
      final items = await context.read<InvitationService>().getInvitations();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _accept(TournamentInvitation inv) async {
    if (_busyId != null) return;
    setState(() => _busyId = inv.id);
    try {
      final res = await context.read<InvitationService>().accept(inv.id);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == inv.id);
        _busyId = null;
      });
      final waitlisted = res['waitlisted'] == true;
      await showAppAlert(
        context,
        waitlisted
            ? 'Мест нет — вы добавлены в лист ожидания.'
            : 'Заявка отправлена на модерацию.',
        title: 'Готово',
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TournamentDetailScreen(tournamentId: inv.tournamentId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyId = null);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _decline(TournamentInvitation inv) async {
    if (_busyId != null) return;
    setState(() => _busyId = inv.id);
    try {
      await context.read<InvitationService>().decline(inv.id);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == inv.id);
        _busyId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyId = null);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year} $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text('Приглашения на турнир',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 44),
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
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.accent,
        backgroundColor: AppTheme.card,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Icon(Icons.mark_email_unread_outlined,
                color: AppTheme.textDim, size: 56),
            SizedBox(height: 14),
            Center(
              child: Text('Приглашений пока нет',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(_items[i]),
      ),
    );
  }

  Widget _buildCard(TournamentInvitation inv) {
    final busy = _busyId == inv.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inv.tournamentName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          if ((inv.clubName ?? '').isNotEmpty)
            _metaRow(Icons.apartment_outlined, inv.clubName!),
          if (inv.startDate != null) ...[
            const SizedBox(height: 4),
            _metaRow(Icons.event_outlined, _formatDate(inv.startDate)),
          ],
          if ((inv.invitedByName ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            _metaRow(Icons.person_outline, 'Пригласил: ${inv.invitedByName}'),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _decline(inv),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: Color(0xFF3A3A3A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Отклонить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: busy ? null : () => _accept(inv),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2.2))
                      : const Text('Принять',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
