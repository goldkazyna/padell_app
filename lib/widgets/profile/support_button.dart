import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/support_service.dart';
import '../../screens/support_tickets_screen.dart';
import 'profile_menu_card.dart';

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
    return ProfileCard(
      accent: const Color(0xFF33C9C0),
      icon: Icons.support_agent,
      title: 'Служба поддержки',
      sub: 'Задать вопрос или сообщить о проблеме',
      badge: _count,
      onTap: _open,
    );
  }
}
