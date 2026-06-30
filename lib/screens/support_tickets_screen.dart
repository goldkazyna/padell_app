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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Новое обращение',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: const [
                  AppBackButton(),
                  SizedBox(width: 4),
                  Text(
                    'Служба поддержки',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
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
    if (_tickets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.support_agent, size: 56, color: AppTheme.textDim),
              SizedBox(height: 12),
              Text(
                'Обращений пока нет.\nНажмите «Новое обращение», чтобы написать нам.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textDim),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _TicketCard(
          ticket: _tickets[i],
          onTap: () => _open(_tickets[i]),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  Color get _statusColor {
    switch (ticket.status) {
      case 'answered':
        return const Color(0xFF3B82F6);
      case 'closed':
        return AppTheme.textDim;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (ticket.lastMessageAt != null)
                    Text(
                      _fmt(ticket.lastMessageAt!),
                      style: const TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (ticket.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${ticket.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ticket.subject,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(DateTime d) {
    final dl = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dl.day)}.${two(dl.month)}.${dl.year} ${two(dl.hour)}:${two(dl.minute)}';
  }
}
