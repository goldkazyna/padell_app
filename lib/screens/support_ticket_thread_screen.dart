import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/support_ticket.dart';
import '../services/support_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/support/attachment_picker.dart';

class SupportTicketThreadScreen extends StatefulWidget {
  final int ticketId;
  const SupportTicketThreadScreen({super.key, required this.ticketId});

  @override
  State<SupportTicketThreadScreen> createState() =>
      _SupportTicketThreadScreenState();
}

class _SupportTicketThreadScreenState extends State<SupportTicketThreadScreen> {
  bool _loading = true;
  String? _error;
  SupportTicket? _ticket;

  final _reply = TextEditingController();
  final List<File> _photos = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _ticket == null;
      _error = null;
    });
    try {
      final t = await context.read<SupportService>().getTicket(widget.ticketId);
      if (!mounted) return;
      setState(() {
        _ticket = t;
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

  Future<void> _addAttachment() async {
    if (_photos.length >= 5) return;
    final file = await pickSupportAttachment(context);
    if (file == null || !mounted) return;
    setState(() => _photos.add(file));
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty && _photos.isEmpty) return;
    setState(() => _sending = true);
    try {
      final t = await context.read<SupportService>().addMessage(
            ticketId: widget.ticketId,
            body: body.isEmpty ? '(вложение)' : body,
            photoPaths: _photos.map((f) => f.path).toList(),
          );
      if (!mounted) return;
      setState(() {
        _ticket = t;
        _reply.clear();
        _photos.clear();
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить: $e')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final t = _ticket;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(t),
            Expanded(child: _buildBody()),
            if (t != null) _composer(),
          ],
        ),
      ),
    );
  }

  Widget _header(SupportTicket? t) {
    final meta = t == null
        ? ''
        : '${t.category ?? 'Обращение'} · #${t.id}';
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A33))),
      ),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t?.subject ?? 'Обращение',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
                if (meta.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(meta,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ),
              ],
            ),
          ),
          if (t != null) ...[
            const SizedBox(width: 8),
            Builder(builder: (_) {
              final (label, color) = _status(t.status);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              );
            }),
          ],
        ],
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
            Text(_error!, style: TextStyle(color: AppTheme.textDim)),
            TextButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }
    final messages = _ticket?.messages ?? [];
    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        children: _threadItems(messages),
      ),
    );
  }

  List<Widget> _threadItems(List<SupportMessage> messages) {
    final items = <Widget>[];
    String? lastDay;
    for (final m in messages) {
      final day = _dayLabel(m.createdAt);
      if (day != lastDay) {
        items.add(_daySeparator(day));
        lastDay = day;
      }
      items.add(_MessageBubble(message: m, onOpenUrl: _openUrl, onOpenImage: _openImage));
    }
    return items;
  }

  Widget _daySeparator(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _composer() {
    final closed = _ticket?.status == 'closed';
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2A33))),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (closed)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Тикет закрыт. Новое сообщение откроет его снова.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 12),
              ),
            ),
          if (_photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (int i = 0; i < _photos.length; i++)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (isPdfPath(_photos[i].path))
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppTheme.cardRaised,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.picture_as_pdf,
                                  color: AppTheme.error, size: 24),
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_photos[i],
                                  width: 54, height: 54, fit: BoxFit.cover),
                            ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(i)),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle),
                                padding: const EdgeInsets.all(1),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _sending ? null : _addAttachment,
                child: SizedBox(
                  width: 42,
                  height: 44,
                  child: Icon(Icons.attach_file, color: AppTheme.textSecondary),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF2A2A33)),
                  ),
                  child: TextField(
                    controller: _reply,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Сообщение…',
                      hintStyle: TextStyle(color: AppTheme.textDim),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF06251A)),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Color(0xFF06251A), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _dayLabel(DateTime? d) {
    if (d == null) return '';
    final dl = d.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dl.year, dl.month, dl.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dl.day)}.${two(dl.month)}.${dl.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage message;
  final void Function(BuildContext, String) onOpenImage;
  final Future<void> Function(String) onOpenUrl;

  const _MessageBubble({
    required this.message,
    required this.onOpenImage,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isSupport = message.isSupport;
    return Align(
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isSupport ? AppTheme.card : const Color(0xFF15412E),
          border: Border.all(
              color: isSupport
                  ? const Color(0xFF2A2A33)
                  : const Color(0xFF1E5A3F)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSupport ? 5 : 16),
            bottomRight: Radius.circular(isSupport ? 16 : 5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSupport ? 'Поддержка' : 'Вы',
              style: TextStyle(
                color: isSupport ? AppTheme.blue : AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.body,
              style: TextStyle(
                  color: isSupport ? AppTheme.textPrimary : const Color(0xFFEAFBF2),
                  fontSize: 14,
                  height: 1.35),
            ),
            if (message.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in message.attachments)
                    if (a.isPdf)
                      GestureDetector(
                        onTap: () => onOpenUrl(a.url),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppTheme.cardRaised,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: AppTheme.error, size: 22),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    child: Text(
                                      a.name.isEmpty ? 'Документ.pdf' : a.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 12.5),
                                    ),
                                  ),
                                  if (a.sizeLabel.isNotEmpty)
                                    Text(a.sizeLabel,
                                        style: TextStyle(
                                            color: AppTheme.textDim,
                                            fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => onOpenImage(context, a.url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(a.url,
                              width: 120, height: 120, fit: BoxFit.cover),
                        ),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _fmt(message.createdAt),
              style: TextStyle(color: AppTheme.textDim, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime? d) {
    if (d == null) return '';
    final dl = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dl.hour)}:${two(dl.minute)}';
  }
}
