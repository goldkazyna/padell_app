import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/court_provider.dart';
import '../theme/app_theme.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProvider>().loadMyBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelBooking(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.cancelBooking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(l10n.areYouSure, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesCancelIt, style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CourtProvider>().cancelBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.bookingCancelled : l10n.cancelError),
            backgroundColor: success ? AppTheme.accent : AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.myBookings,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: Consumer<CourtProvider>(
        builder: (context, provider, _) {
          if (provider.isBookingsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }

          return Column(
            children: [
              // Табы — underline-стиль как в Rating
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: AppTheme.accent, width: 2),
                      insets: EdgeInsets.zero,
                    ),
                    dividerHeight: 0,
                    labelColor: AppTheme.accent,
                    unselectedLabelColor: const Color(0xFF52525B),
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppLocalizations.of(context)!.upcomingBookings),
                            if (provider.upcomingBookings.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${provider.upcomingBookings.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        text: AppLocalizations.of(context)!.pastBookings,
                      ),
                    ],
                  ),
                ),
              ),

              // Контент
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(provider.upcomingBookings, isUpcoming: true),
                    _buildList(provider.pastBookings, isUpcoming: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.calendar_today : Icons.history,
              size: 48,
              color: const Color(0xFF3F3F46),
            ),
            const SizedBox(height: 12),
            Text(
              isUpcoming ? AppLocalizations.of(context)!.noUpcomingBookings : AppLocalizations.of(context)!.noPastBookings,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CourtProvider>().loadMyBookings(),
      color: AppTheme.accent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: bookings.length,
        itemBuilder: (context, index) => _BookingCard(
          booking: bookings[index],
          isUpcoming: isUpcoming,
          onCancel: () => _cancelBooking(bookings[index]['id'] as int),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isUpcoming;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.isUpcoming,
    required this.onCancel,
  });

  String _fmtPrice(num p) {
    return p.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  }

  String _formatDate(String? date, AppLocalizations l10n) {
    if (date == null) return '';
    try {
      DateTime d;
      if (date.contains('.')) {
        final parts = date.split('.');
        d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        d = DateTime.parse(date);
      }
      final months = [
        '', l10n.challengeMonthJan, l10n.challengeMonthFeb, l10n.challengeMonthMar,
        l10n.challengeMonthApr, l10n.challengeMonthMay, l10n.challengeMonthJun,
        l10n.challengeMonthJul, l10n.challengeMonthAug, l10n.challengeMonthSep,
        l10n.challengeMonthOct, l10n.challengeMonthNov, l10n.challengeMonthDec,
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final club = booking['club'] as String? ?? '';
    final court = booking['court'] as String? ?? '';
    final date = booking['date'] as String? ?? '';
    final startTime = booking['start_time'] as String? ?? '';
    final endTime = booking['end_time'] as String? ?? '';
    final price = (booking['price'] as num?) ?? 0;
    final coach = booking['coach'] as String?;
    final coachPrice = (booking['coach_price'] as num?) ?? 0;
    final status = booking['status'] as String? ?? '';
    final canCancel = booking['can_cancel'] == true;
    final cancelMinHours = (booking['cancel_min_hours'] as int?) ?? 12;
    final isProcessed = booking['is_processed'] ?? true;

    final bool isPending = !isProcessed;
    final bool isCancelled = status == 'cancelled';

    Color borderColor;
    if (isCancelled) {
      borderColor = const Color(0xFF3F3F46);
    } else if (isPending) {
      borderColor = const Color(0xFFEF4444).withAlpha(50);
    } else {
      borderColor = AppTheme.accent.withAlpha(40);
    }

    Color gradEnd;
    if (isCancelled) {
      gradEnd = const Color(0xFF1A1A1A);
    } else if (isPending) {
      gradEnd = const Color(0xFF1F1A1A);
    } else {
      gradEnd = const Color(0xFF1A1D1A);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isCancelled || !isUpcoming ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A1A1A), gradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок + статус
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(club,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis),
                    ),
                    _StatusBadge(
                      isCancelled: isCancelled,
                      isPending: isPending,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Детали 2x2
                Row(
                  children: [
                    Expanded(child: _InfoItem(label: l10n.summaryDate, value: _formatDate(date, l10n))),
                    Expanded(child: _InfoItem(label: l10n.summaryTime, value: '$startTime — $endTime')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _InfoItem(label: l10n.summaryCourt, value: court)),
                    Expanded(
                      child: coach != null
                          ? _InfoItem(label: l10n.summaryCoach, value: coach, valueColor: const Color(0xFFA78BFA))
                          : _InfoItem(label: l10n.summaryCoach, value: '—'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Цена + отмена
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmtPrice(price)} ₸',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accent),
                          ),
                          if (coach != null && coachPrice > 0)
                            Text(
                              l10n.coachPlus(_fmtPrice(coachPrice)),
                              style: const TextStyle(fontSize: 11, color: Color(0xFFA78BFA)),
                            ),
                        ],
                      ),
                      if (canCancel && isUpcoming && !isCancelled)
                        GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.error.withAlpha(50), width: 0.5),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.error),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!canCancel && isUpcoming && !isCancelled) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.amber.withAlpha(60), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppTheme.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Отмена менее чем за $cancelMinHours часов через приложение невозможна. Свяжитесь с клубом.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.amber,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCancelled;
  final bool isPending;

  const _StatusBadge({required this.isCancelled, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String text;
    Color bg;
    Color fg;

    if (isCancelled) {
      text = l10n.statusCancelled;
      bg = const Color(0xFF3F3F46).withAlpha(40);
      fg = const Color(0xFF71717A);
    } else if (isPending) {
      text = l10n.statusPending;
      bg = AppTheme.error;
      fg = Colors.white;
    } else {
      text = l10n.statusConfirmed;
      bg = AppTheme.accent.withAlpha(25);
      fg = AppTheme.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF52525B), letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFFD4D4D8)),
        ),
      ],
    );
  }
}
