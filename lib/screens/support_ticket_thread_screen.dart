import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/support_ticket.dart';
import '../services/support_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

class SupportTicketThreadScreen extends StatefulWidget {
  final int ticketId;
  const SupportTicketThreadScreen({super.key, required this.ticketId});

  @override
  State<SupportTicketThreadScreen> createState() =>
      _SupportTicketThreadScreenState();
}

class _SupportTicketThreadScreenState
    extends State<SupportTicketThreadScreen> {
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

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/sup_${DateTime.now().millisecondsSinceEpoch}.webp';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        picked.path, target,
        format: CompressFormat.webp, quality: 80,
        minWidth: 1600, minHeight: 1600,
      );
      if (!mounted) return;
      setState(() => _photos.add(File(compressed?.path ?? picked.path)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _photos.add(File(picked.path)));
    }
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty && _photos.isEmpty) return;
    setState(() => _sending = true);
    try {
      final t = await context.read<SupportService>().addMessage(
            ticketId: widget.ticketId,
            body: body.isEmpty ? '(фото)' : body,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _ticket?.subject ?? 'Обращение',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
            if (_ticket != null) _buildComposer(),
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
    final messages = _ticket?.messages ?? [];
    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        itemCount: messages.length,
        itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
      ),
    );
  }

  Widget _buildComposer() {
    final closed = _ticket?.status == 'closed';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (closed)
            const Padding(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_photos[i],
                                width: 54, height: 54, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _photos.removeAt(i)),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
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
            children: [
              IconButton(
                onPressed: _sending ? null : _pickPhoto,
                icon: const Icon(Icons.add_a_photo_outlined,
                    color: AppTheme.textDim),
              ),
              Expanded(
                child: TextField(
                  controller: _reply,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Сообщение…',
                    hintStyle: TextStyle(color: AppTheme.textDim),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.accent),
                      )
                    : const Icon(Icons.send_rounded, color: AppTheme.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSupport = message.isSupport;
    return Align(
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isSupport ? AppTheme.card : AppTheme.accent.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSupport ? const Color(0xFF2A2A2A) : AppTheme.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSupport ? 'Поддержка' : 'Вы',
              style: TextStyle(
                color: isSupport ? const Color(0xFF3B82F6) : AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(message.body,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14)),
            if (message.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final url in message.attachments)
                    GestureDetector(
                      onTap: () => _openImage(context, url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url,
                            width: 92, height: 92, fit: BoxFit.cover),
                      ),
                    ),
                ],
              ),
            ],
            if (message.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _fmt(message.createdAt!),
                style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  static String _fmt(DateTime d) {
    final dl = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dl.day)}.${two(dl.month)} ${two(dl.hour)}:${two(dl.minute)}';
  }
}
