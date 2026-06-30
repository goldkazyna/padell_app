import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/support_service.dart';
import '../../screens/support_tickets_screen.dart';

/// Кнопка «Служба поддержки» в профиле с бейджем непрочитанных ответов.
class SupportButton extends StatefulWidget {
  const SupportButton({super.key});

  @override
  State<SupportButton> createState() => _SupportButtonState();
}

class _SupportButtonState extends State<SupportButton> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await context.read<SupportService>().getUnreadCount();
      if (!mounted) return;
      setState(() => _count = count);
    } catch (_) {
      // тихо игнорируем
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportTicketsScreen()),
    );
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _open,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0EA5A4), Color(0xFF0F766E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5A4).withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (_count > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF0F766E), width: 2),
                          ),
                          child: Text(
                            '$_count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Служба поддержки',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Задать вопрос или сообщить о проблеме',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
