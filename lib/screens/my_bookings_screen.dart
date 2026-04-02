import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Отменить бронирование?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('Вы уверены?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Да, отменить', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CourtProvider>().cancelBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Бронирование отменено' : 'Ошибка отмены'),
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
        title: const Text('Мои бронирования',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: Consumer<CourtProvider>(
        builder: (context, provider, _) {
          if (provider.isBookingsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
          }

          return Column(
            children: [
              // Табы
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    labelColor: Colors.black,
                    unselectedLabelColor: const Color(0xFF71717A),
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Предстоящие'),
                            if (provider.upcomingBookings.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${provider.upcomingBookings.length}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(text: 'Прошедшие'),
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
              isUpcoming ? 'Нет предстоящих бронирований' : 'Нет прошедших бронирований',
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

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      DateTime d;
      if (date.contains('.')) {
        final parts = date.split('.');
        d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        d = DateTime.parse(date);
      }
      const months = ['', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Expanded(child: _InfoItem(label: 'Дата', value: _formatDate(date))),
                    Expanded(child: _InfoItem(label: 'Время', value: '$startTime — $endTime')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _InfoItem(label: 'Корт', value: court)),
                    Expanded(
                      child: coach != null
                          ? _InfoItem(label: 'Тренер', value: coach, valueColor: const Color(0xFFA78BFA))
                          : const _InfoItem(label: 'Тренер', value: '—'),
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
                              '+ тренер ${_fmtPrice(coachPrice)} ₸',
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
                            child: const Text(
                              'Отменить',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.error),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
    String text;
    Color bg;
    Color fg;

    if (isCancelled) {
      text = 'Отменено';
      bg = const Color(0xFF3F3F46).withAlpha(40);
      fg = const Color(0xFF71717A);
    } else if (isPending) {
      text = 'Новая заявка';
      bg = AppTheme.error;
      fg = Colors.white;
    } else {
      text = 'Подтверждено';
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
