import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/support_ticket.dart';
import '../services/support_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'support_create_ticket_screen.dart';
import 'support_ticket_thread_screen.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  bool _loading = true;
  String? _error;
  List<SupportTicket> _tickets = [];
  String _tab = 'active'; // active / closed

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
      final tickets = await context.read<SupportService>().getTickets();
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
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

  Future<void> _create() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SupportCreateTicketScreen()),
    );
    if (created == true) _load();
  }

  Future<void> _open(SupportTicket t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupportTicketThreadScreen(ticketId: t.id),
      ),
    );
    _load();
  }

  List<SupportTicket> get _active =>
      _tickets.where((t) => !t.isClosed).toList();
  List<SupportTicket> get _closed =>
      _tickets.where((t) => t.isClosed).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: const [
                  AppBackButton(),
                  SizedBox(width: 4),
                  Text(
                    'Поддержка',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.textDim)),
            TextButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }

    final list = _tab == 'active' ? _active : _closed;

    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _tabs(),
          const SizedBox(height: 4),
          if (list.isEmpty)
            _empty()
          else
            ...list.map((t) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _TicketCard(ticket: t, onTap: () => _open(t)),
                )),
        ],
      ),
    );
  }

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/support_hero.png',
                fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xE0131317), Color(0x80131317), Color(0x33131317)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Чем помочь?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const SizedBox(
                  width: 220,
                  child: Text(
                    'Опишите проблему — ответим в течение дня.',
                    style: TextStyle(color: Color(0xFFD6D6DE), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _create,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Color(0xFF06251A), size: 20),
                        SizedBox(width: 6),
                        Text('Создать обращение',
                            style: TextStyle(
                                color: Color(0xFF06251A),
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget seg(String key, String label, int n) {
      final on = _tab == key;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = key),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppTheme.cardRaised : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: on ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: '  $n',
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 14),
              ),
            ])),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        seg('active', 'Активные', _active.length),
        seg('closed', 'Закрытые', _closed.length),
      ]),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(
            _tab == 'active'
                ? Icons.support_agent
                : Icons.check_circle_outline,
            size: 52,
            color: AppTheme.textDim,
          ),
          const SizedBox(height: 12),
          Text(
            _tab == 'active'
                ? 'Активных обращений нет.\nНажмите «Создать обращение».'
                : 'Закрытых обращений нет.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textDim),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  static (String, Color) _status(String s) {
    switch (s) {
      case 'answered':
        return ('Ждём ответа', AppTheme.blue);
      case 'closed':
        return ('Закрыт', AppTheme.textSecondary);
      default:
        return ('Открыт', AppTheme.amber);
    }
  }

  static IconData _catIcon(String? c) {
    switch (c) {
      case 'Аккаунт':
        return Icons.person_outline;
      case 'Оплата':
        return Icons.credit_card;
      case 'Турнир':
        return Icons.emoji_events_outlined;
      case 'Бронь':
        return Icons.calendar_today_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _status(ticket.status);
    final stripe = ticket.isUrgent ? AppTheme.error : color;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: stripe),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.cardRaised,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(_catIcon(ticket.category),
                              color: const Color(0xFFC9C9D2), size: 21),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text.rich(TextSpan(children: [
                                if (ticket.isUrgent)
                                  const TextSpan(
                                    text: 'Срочный',
                                    style: TextStyle(
                                        color: AppTheme.error,
                                        fontWeight: FontWeight.w700),
                                  ),
                                if (ticket.isUrgent && ticket.category != null)
                                  const TextSpan(text: ' · '),
                                if (ticket.category != null)
                                  TextSpan(text: ticket.category!),
                                if (!ticket.isUrgent && ticket.category == null)
                                  const TextSpan(text: 'Обращение'),
                              ], style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12.5))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withAlpha(40),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(label,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fmt(ticket.lastMessageAt),
                                  style: const TextStyle(
                                      color: AppTheme.textDim, fontSize: 12),
                                ),
                                if (ticket.unreadCount > 0) ...[
                                  const SizedBox(width: 7),
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '';
    final dl = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dl.day)}.${two(dl.month)} ${two(dl.hour)}:${two(dl.minute)}';
  }
}
