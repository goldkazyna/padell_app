import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club_card.dart';
import '../services/club_card_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/floating_tab_bar.dart';
import '../widgets/refreshable_message.dart';
import 'club_cards_list_screen.dart';

/// Экран 1 — клубы, где у пользователя есть клубные карты.
class ClubCardsScreen extends StatefulWidget {
  const ClubCardsScreen({super.key});

  @override
  State<ClubCardsScreen> createState() => _ClubCardsScreenState();
}

class _ClubCardsScreenState extends State<ClubCardsScreen> {
  bool _loading = true;
  String? _error;
  List<ClubCardsGroup> _groups = const [];
  bool _redirected = false;

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
      final groups = await context.read<ClubCardService>().getClubCards();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
      // Один клуб — сразу проваливаем на его карты.
      if (groups.length == 1 && !_redirected) {
        _redirected = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ClubCardsListScreen(group: groups.first),
            ),
          );
        });
      }
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        leadingWidth: 58,
        title: Text(
          l.clubCardsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(children: [_buildBody(l), const FloatingTabBar()]),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return RefreshableMessage(
        onRefresh: _load,
        child: _ErrorState(message: _error!, onRetry: _load),
      );
    }
    if (_groups.isEmpty) {
      return RefreshableMessage(
        onRefresh: _load,
        child: _EmptyState(
          title: l.clubCardsEmptyTitle,
          hint: l.clubCardsEmptyHint,
        ),
      );
    }
    // Один клуб — показываем спиннер, пока не сработал redirect.
    if (_groups.length == 1) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ClubRow(
          group: _groups[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClubCardsListScreen(group: _groups[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubRow extends StatelessWidget {
  final ClubCardsGroup group;
  final VoidCallback onTap;
  const _ClubRow({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final club = group.club;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Row(
          children: [
            ClubCardLogo(name: club.name, logo: club.logo, size: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((club.address ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Color(0xFF7A857E)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            club.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.credit_card,
                            size: 12, color: AppTheme.accent),
                        const SizedBox(width: 5),
                        Text(
                          l.clubCardsCountShort(group.totalCount),
                          style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF5C665F), size: 22),
          ],
        ),
      ),
    );
  }
}

/// Палитра для лого-плиток клубов без картинки (цвет стабилен по имени).
const List<Color> _kLogoPalette = [
  Color(0xFFEF4444), // red
  Color(0xFF22C55E), // green
  Color(0xFF3B82F6), // blue
  Color(0xFF8B5CF6), // purple
  Color(0xFFF97316), // orange
  Color(0xFF14B8A6), // teal
  Color(0xFFEC4899), // pink
];

/// Лого клуба — скруглённая плитка: картинка или цветной фоллбэк с аббревиатурой.
class ClubCardLogo extends StatelessWidget {
  final String name;
  final String? logo;
  final double size;
  const ClubCardLogo({super.key, required this.name, this.logo, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final base = _kLogoPalette[name.hashCode.abs() % _kLogoPalette.length];
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, Colors.black, 0.28)!],
        ),
      ),
      child: logo != null && logo!.isNotEmpty
          ? Image.network(
              logo!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _abbr(),
            )
          : _abbr(),
    );
  }

  Widget _abbr() => Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _shortName(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

  static String _shortName(String name) {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final first = words.first;
    if (first.length <= 6) return first.toUpperCase();
    return words.take(3).map((w) => w[0]).join().toUpperCase();
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String hint;
  const _EmptyState({required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
              ),
              child: const Icon(Icons.credit_card_outlined,
                  color: Color(0xFF5C665F), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(l.retry, style: const TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}
