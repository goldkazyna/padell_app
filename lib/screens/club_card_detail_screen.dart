import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club_card.dart';
import '../services/club_card_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/club_card_visual.dart';
import '../widgets/floating_tab_bar.dart';
import 'club_cards_list_screen.dart' show clubCardKindLabel;
import 'club_card_bookings_screen.dart';

/// Экран 3 — детали карты: крупная «карта-членство», история операций,
/// кнопка «Записи по карте».
class ClubCardDetailScreen extends StatefulWidget {
  final ClubCard card;
  final ClubCardClubBrief club;
  const ClubCardDetailScreen({
    super.key,
    required this.card,
    required this.club,
  });

  @override
  State<ClubCardDetailScreen> createState() => _ClubCardDetailScreenState();
}

class _ClubCardDetailScreenState extends State<ClubCardDetailScreen> {
  bool _loading = true;
  String? _error;
  List<ClubCardTransaction> _transactions = const [];

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
      final detail =
          await context.read<ClubCardService>().getCardDetail(widget.card.id);
      if (!mounted) return;
      setState(() {
        _transactions = detail.transactions;
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final card = widget.card;
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
        title: Text(
          card.typeName ?? l.clubCardsTitle,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: _load,
          color: AppTheme.accent,
          backgroundColor: AppTheme.card,
          child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          children: [
          ClubCardVisual(card: card, club: widget.club),
          const SizedBox(height: 14),
          AppPrimaryButton(
            label: l.clubCardBookingsButton,
            icon: Icons.event_note_outlined,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClubCardBookingsScreen(
                  cardId: card.id,
                  typeName: card.typeName ?? clubCardKindLabel(l, card),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.clubCardHistoryTitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildHistory(l),
        ],
      ),
      ),
      const FloatingTabBar(),
      ]),
    );
  }

  Widget _buildHistory(AppLocalizations l) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: TextButton(
            onPressed: _load,
            child: Text(l.retry, style: const TextStyle(color: AppTheme.accent)),
          ),
        ),
      );
    }
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(l.clubCardHistoryEmpty,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
        ),
      );
    }
    return Column(
      children: [
        for (final t in _transactions) _HistoryRow(tx: t),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ClubCardTransaction tx;
  const _HistoryRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A231E), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.remove, color: Color(0xFFEF6A6A), size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note ??
                      (tx.hasBooking ? l.clubCardChargeBooking : l.clubCardCharge),
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700),
                ),
                if (tx.createdAt != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    _fmtDateTime(tx.createdAt!),
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('−${tx.amount}',
                  style: const TextStyle(
                      color: Color(0xFFEF6A6A),
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              if (tx.balanceAfter != null)
                Text(l.clubCardBalanceAfter(tx.balanceAfter!),
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}

/// ISO8601 → «dd.MM.yyyy · HH:mm».
String _fmtDateTime(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(dt.day)}.${two(dt.month)}.${dt.year} · ${two(dt.hour)}:${two(dt.minute)}';
}
