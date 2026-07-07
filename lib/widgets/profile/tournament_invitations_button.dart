import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/invitation_service.dart';
import '../../screens/tournament_invitations_screen.dart';
import 'profile_menu_card.dart';

/// Кнопка «Приглашения на турнир» в профиле (под «Мои турниры»).
/// Показывает бейдж с количеством ожидающих приглашений.
class TournamentInvitationsButton extends StatefulWidget {
  const TournamentInvitationsButton({super.key});

  @override
  State<TournamentInvitationsButton> createState() =>
      _TournamentInvitationsButtonState();
}

class _TournamentInvitationsButtonState
    extends State<TournamentInvitationsButton> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await context.read<InvitationService>().getCount();
      if (!mounted) return;
      setState(() => _count = count);
    } catch (_) {
      // тихо игнорируем — кнопка остаётся без бейджа
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TournamentInvitationsScreen(),
      ),
    );
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      accent: const Color(0xFF9B8CF0),
      icon: Icons.mail_outline,
      title: 'Приглашения на турнир',
      sub: 'Турниры, куда тебя позвали',
      badge: _count,
      onTap: _open,
    );
  }
}
