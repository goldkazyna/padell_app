import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/club.dart';
import '../providers/tournament_provider.dart';
import '../services/club_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import 'tournaments_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final int clubId;
  final Club? initialClub;

  const ClubDetailScreen({
    super.key,
    required this.clubId,
    this.initialClub,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  Club? _club;
  bool _isLoading = false;
  bool _isToggling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _club = widget.initialClub;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final club = await context.read<ClubService>().getClub(widget.clubId);
      if (!mounted) return;
      setState(() {
        _club = club;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleHide() async {
    final club = _club;
    if (club == null || _isToggling) return;
    setState(() => _isToggling = true);
    try {
      final isHidden = await context.read<ClubService>().toggleHide(club.id);
      if (!mounted) return;
      setState(() {
        _club = club.copyWith(isHidden: isHidden);
        _isToggling = false;
      });
      context.read<TournamentProvider>().loadOpenTournaments();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isToggling = false);
      showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  Future<void> _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openTelegram(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInstagram(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _share() {
    final c = _club;
    if (c == null) return;
    final parts = <String>[c.name];
    final link = (c.telegramUrl?.isNotEmpty ?? false)
        ? c.telegramUrl!
        : ((c.instagramUrl?.isNotEmpty ?? false) ? c.instagramUrl! : null);
    if (link != null) parts.add(link);
    Share.share(parts.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_club == null && _isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_club == null && _error != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Не удалось загрузить клуб',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final club = _club!;
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildCoverHeader(club)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSocialRow(club),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildTournamentsCard(club),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildInfoCard(club),
            ),
          ),
          if (club.description != null && club.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _buildDescription(club.description!),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _buildHideToggle(club),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Cover header ────────────────────────────────────────────────────

  Widget _buildCoverHeader(Club club) {
    final coverHeight = MediaQuery.of(context).size.height * 0.32;
    return SizedBox(
      height: coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image or colour
          if (club.cover != null)
            Image.network(
              club.cover!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: coverHeight,
              errorBuilder: (ctx, err, stack) =>
                  Container(color: AppTheme.card),
            )
          else
            Container(color: AppTheme.card),

          // Bottom dark gradient — cinematic three-stop fade
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Back + Share buttons
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 12,
                  child: _CircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: _CircleButton(
                    icon: Icons.ios_share,
                    onTap: _share,
                  ),
                ),
              ],
            ),
          ),

          // Logo + badge + name overlay near bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Circular logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: AppTheme.card,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipOval(
                    child: club.logo != null
                        ? Image.network(
                            club.logo!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                _buildInitials(club.name),
                          )
                        : _buildInitials(club.name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF166534)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          club.isCommunity ? 'КОМЬЮНИТИ' : 'КЛУБ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Club name
                      Text(
                        club.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Social action row ───────────────────────────────────────────────

  Widget _buildSocialRow(Club club) {
    final actions = <_SocialAction>[];
    if ((club.phone ?? '').isNotEmpty) {
      actions.add(_SocialAction(
        icon: const Icon(Icons.call, color: AppTheme.accent, size: 20),
        label: 'Звонок',
        onTap: () => _callPhone(club.phone!),
      ));
    }
    if ((club.telegramUrl ?? '').isNotEmpty) {
      actions.add(_SocialAction(
        icon: const FaIcon(FontAwesomeIcons.telegram,
            color: AppTheme.accent, size: 20),
        label: 'Telegram',
        onTap: () => _openTelegram(club.telegramUrl!),
      ));
    }
    if ((club.instagramUrl ?? '').isNotEmpty) {
      actions.add(_SocialAction(
        icon: const FaIcon(FontAwesomeIcons.instagram,
            color: AppTheme.accent, size: 20),
        label: 'Instagram',
        onTap: () => _openInstagram(club.instagramUrl!),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _buildActionCard(actions[i])),
        ],
      ],
    );
  }

  Widget _buildActionCard(_SocialAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: action.icon),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Open tournaments card ──────────────────────────────────────────

  Widget _buildTournamentsCard(Club club) {
    if (club.openTournamentsCount <= 0) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: AppTheme.background,
              appBar: AppBar(
                backgroundColor: AppTheme.background,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                leading: const BackButton(),
              ),
              body: TournamentsScreen(initialClubId: club.id),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF166534)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Calendar icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Открытые турниры',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Count pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${club.openTournamentsCount}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Step 4: Info card ──────────────────────────────────────────────────────

  Widget _buildInfoCard(Club club) {
    final rows = <Widget>[];

    if (club.address != null && club.address!.isNotEmpty) {
      rows.add(_buildInfoRow(
        icon: Icons.location_on_outlined,
        label: 'Адрес',
        value: club.address!,
        onTap: () => _openMaps(club.address!),
      ));
    }
    if (club.city != null && club.city!.isNotEmpty) {
      rows.add(_buildInfoRow(
        icon: Icons.location_city_outlined,
        label: 'Город',
        value: club.city!,
      ));
    }
    if (club.phone != null && club.phone!.isNotEmpty) {
      rows.add(_buildInfoRow(
        icon: Icons.phone_outlined,
        label: 'Телефон',
        value: club.phone!,
        onTap: () => _callPhone(club.phone!),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 0,
                thickness: 0.5,
                color: Color(0xFF2A2A2A),
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildHideToggle(Club club) {
    return GestureDetector(
      onTap: _toggleHide,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Не показывать турниры этого клуба',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Скроет их во вкладке «Открытые турниры»',
                    style: TextStyle(
                      color: AppTheme.textPrimary.withAlpha(140),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _isToggling
                ? const SizedBox(
                    width: 40,
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  )
                : Switch(
                    value: club.isHidden,
                    onChanged: (_) => _toggleHide(),
                    activeThumbColor: AppTheme.accent,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase());
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(25),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppTheme.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О КЛУБЕ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _SocialAction {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
