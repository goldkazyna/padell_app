import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club_card.dart';
import '../providers/court_provider.dart';
import '../services/club_card_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/floating_tab_bar.dart';
import '../widgets/refreshable_message.dart';
import 'club_cards_list_screen.dart' show formatCardDate;

/// Экран 4 — будущие брони, оплаченные этой картой.
class ClubCardBookingsScreen extends StatefulWidget {
  final int cardId;
  final String typeName;
  const ClubCardBookingsScreen({
    super.key,
    required this.cardId,
    required this.typeName,
  });

  @override
  State<ClubCardBookingsScreen> createState() => _ClubCardBookingsScreenState();
}

class _ClubCardBookingsScreenState extends State<ClubCardBookingsScreen> {
  bool _loading = true;
  String? _error;
  List<ClubCardBooking> _bookings = const [];

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
      final list =
          await context.read<ClubCardService>().getCardBookings(widget.cardId);
      if (!mounted) return;
      setState(() {
        _bookings = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.loadError;
        _loading = false;
      });
    }
  }

  Future<void> _cancelBooking(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.cancelBooking,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(l10n.areYouSure,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesCancelIt,
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CourtProvider>().cancelBooking(id);
      if (!mounted) return;
      showAppAlert(
        context,
        success ? l10n.bookingCancelled : l10n.cancelError,
        isError: !success,
      );
      if (success) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 58,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.clubCardBookingsButton,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(widget.typeName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: Stack(children: [_buildBody(l), const FloatingTabBar()]),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return RefreshableMessage(
        onRefresh: _load,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _load,
              child: Text(l.retry, style: const TextStyle(color: AppTheme.accent)),
            ),
          ],
        ),
      );
    }
    if (_bookings.isEmpty) {
      return RefreshableMessage(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_outlined,
                  color: Color(0xFF5C665F), size: 40),
              const SizedBox(height: 14),
              Text(
                l.clubCardBookingsEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 11),
        itemBuilder: (_, i) => _BookingRow(
          b: _bookings[i],
          onCancel: () => _cancelBooking(_bookings[i].id),
        ),
      ),
    );
  }
}

/// Вариант B — крупная карточка: время + длительность, дата/день недели,
/// корт/клуб, обратный отсчёт и кнопка «Отменить».
class _BookingRow extends StatelessWidget {
  final ClubCardBooking b;
  final VoidCallback onCancel;
  const _BookingRow({required this.b, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final time = [b.startTime, b.endTime].where((e) => e != null).join(' – ');
    final dt = b.date != null ? DateTime.tryParse(b.date!) : null;
    final dateStr = dt != null
        ? DateFormat('d MMMM', locale).format(dt)
        : (b.date != null ? formatCardDate(b.date!) : '');
    final weekday = dt != null ? DateFormat.EEEE(locale).format(dt) : '';
    final duration = _duration(l);
    final countdown = _countdown(l, dt);
    final showHint =
        !b.canCancel && b.status == 'confirmed' && b.cancelMinHours > 0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Время + длительность
          Row(
            children: [
              Icon(Icons.schedule, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  time.isEmpty ? '—' : time,
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3),
                ),
              ),
              if (duration != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(duration,
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF2A3330)),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.calendar_today_outlined,
            bold: dateStr,
            dim: weekday.isNotEmpty ? '· $weekday' : null,
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.sports_tennis,
            bold: b.courtName ?? '—',
            dim: b.clubName != null ? '· ${b.clubName}' : null,
          ),
          if (b.canCancel || countdown != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (countdown != null)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_bottom,
                            color: AppTheme.accent, size: 14),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(countdown,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (b.canCancel)
                  GestureDetector(
                    onTap: onCancel,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: AppTheme.error.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, color: AppTheme.error, size: 14),
                          const SizedBox(width: 6),
                          Text(l.cancel,
                              style: TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (showHint) ...[
            const SizedBox(height: 10),
            Text(
              l.clubCardBookingCancelHint(b.cancelMinHours),
              style: TextStyle(color: AppTheme.textDim, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }

  String? _duration(AppLocalizations l) {
    final s = _toMin(b.startTime), e = _toMin(b.endTime);
    if (s == null || e == null || e <= s) return null;
    final mins = e - s;
    final h = mins ~/ 60, m = mins % 60;
    if (m == 0) return '$h ${l.hoursShort}';
    if (h == 0) return '$m ${l.minutesShort}';
    return '$h ${l.hoursShort} $m ${l.minutesShort}';
  }

  static int? _toMin(String? hm) {
    if (hm == null) return null;
    final p = hm.split(':');
    if (p.length < 2) return null;
    final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  String? _countdown(AppLocalizations l, DateTime? dt) {
    if (dt == null) return null;
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = DateTime(dt.year, dt.month, dt.day);
    final diff = d1.difference(d0).inDays;
    if (diff < 0) return null;
    if (diff == 0) return l.bookingToday;
    if (diff == 1) return l.bookingTomorrow;
    return l.bookingInDays(diff);
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String bold;
  final String? dim;
  const _InfoLine({required this.icon, required this.bold, this.dim});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 15),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            bold,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700),
          ),
        ),
        if (dim != null) ...[
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              dim!,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
            ),
          ),
        ],
      ],
    );
  }
}
