import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/tournament.dart';
import '../providers/tournament_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/tournaments/team_list_section.dart';
import '../widgets/tournaments/team_info_card.dart';
import '../widgets/tournaments/team_registration_sheet.dart';

class TournamentDetailScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadTournamentDetails(widget.tournamentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<TournamentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail && provider.selectedTournament == null) {
            return const SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            );
          }

          final tournament = provider.selectedTournament;
          if (tournament == null) {
            return SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Не удалось загрузить турнир',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final userId = context.read<HomeProvider>().user?.id;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<TournamentProvider>()
                        .loadTournamentDetails(widget.tournamentId),
                    color: AppTheme.accent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildAppBar(context),
                          const SizedBox(height: 20),
                          _buildTags(tournament),
                          const SizedBox(height: 12),
                          _buildTitle(tournament),
                          const SizedBox(height: 8),
                          _buildLocation(tournament),
                          const SizedBox(height: 16),
                          _buildDateTimeRow(tournament),
                          const SizedBox(height: 8),
                          _buildLevelPriceRow(tournament),
                          const SizedBox(height: 28),
                          if (tournament.isTeamTournament) ...[
                            TeamListSection(
                              tournament: tournament,
                              currentUserId: userId,
                            ),
                          ] else
                            _buildParticipantsSection(tournament, userId),
                          const SizedBox(height: 28),
                          _buildOrganizerSection(tournament),
                          const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_shouldShowBottomButton(tournament, provider))
                  tournament.isTeamTournament
                      ? _buildTeamBottomButton(tournament, provider)
                      : _buildBottomButton(tournament, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // === AppBar ===
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.of(context).pop(),
          ),
          _buildCircleButton(
            icon: Icons.ios_share,
            onTap: () => _shareTournament(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.card,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }

  void _shareTournament() {
    final tournament = context.read<TournamentProvider>().selectedTournament;
    if (tournament == null) return;

    final levelText = '${tournament.minLevel} – ${tournament.maxLevel}';
    final spotsText = tournament.spotsLeft > 0
        ? 'Свободных мест: ${tournament.spotsLeft}'
        : 'Мест нет';

    final text = '${tournament.name}\n\n'
        '${tournament.typeName} · ${tournament.levelCategoryText}\n'
        '${tournament.dateFormatted}, ${tournament.dayOfWeek}\n'
        '${tournament.time}\n'
        '${tournament.club.name}\n'
        'Уровень: $levelText\n'
        'Стоимость: ${tournament.priceText}\n'
        '$spotsText\n\n'
        'Padel KZ — скачай приложение и записывайся на турниры!';

    Share.share(text);
  }

  // === Теги ===
  Widget _buildTags(Tournament t) {
    final statusColor = t.isFull ? AppTheme.error : AppTheme.accent;
    final statusText = t.isFull ? 'МЕСТ НЕТ' : t.statusName.toUpperCase();

    return Row(
      children: [
        _buildTag(t.typeName.toUpperCase(), t.typeColor),
        const SizedBox(width: 8),
        _buildTag(statusText, statusColor),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // === Название ===
  Widget _buildTitle(Tournament t) {
    return Text(
      t.name,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // === Локация ===
  Widget _buildLocation(Tournament t) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            t.club.fullAddress,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // === Дата и Время ===
  Widget _buildDateTimeRow(Tournament t) {
    return IntrinsicHeight(child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          label: 'ДАТА',
          icon: Icons.calendar_today_outlined,
          value: t.dateFormatted,
          subtitle: t.dayOfWeek,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          label: 'ВРЕМЯ',
          icon: Icons.access_time_outlined,
          value: t.time,
          subtitle: '',
        ),
      ],
    ));
  }

  // === Уровень и Стоимость ===
  Widget _buildLevelPriceRow(Tournament t) {
    return IntrinsicHeight(child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          label: 'УРОВЕНЬ',
          icon: Icons.signal_cellular_alt,
          value: '${t.minLevel} – ${t.maxLevel}',
          subtitle: t.levelCategoryText,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          label: 'СТОИМОСТЬ',
          value: t.priceText,
          valueColor: AppTheme.accent,
          subtitle: 'за человека',
        ),
      ],
    ));
  }

  Widget _buildInfoCard({
    required String label,
    IconData? icon,
    required String value,
    required String subtitle,
    Color valueColor = AppTheme.textPrimary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // === Цвета для pending ===
  static const Color _pendingColor = Color(0xFFF59E0B); // amber/orange

  // === Участники ===
  Widget _buildParticipantsSection(Tournament t, int? currentUserId) {
    final pending = t.participants.where((p) => p.status == 'pending').toList();
    final registered = t.participants.where((p) => p.status != 'pending').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === На модерации ===
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'На модерации',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(pending.length, _pendingColor),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((p) {
            final isMe = currentUserId != null && p.id == currentUserId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildPendingRow(participant: p, isMe: isMe),
            );
          }),
          const SizedBox(height: 24),
        ],

        // === Участники ===
        Row(
          children: [
            const Text(
              'Участники',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (registered.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildCountBadge(registered.length, AppTheme.accent),
            ],
            const Spacer(),
            Text(
              '${t.participantsCount} из ${t.maxParticipants}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (registered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
            ),
            child: const Center(
              child: Text(
                'Пока нет участников',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          ...List.generate(registered.length, (index) {
            final p = registered[index];
            final isMe = currentUserId != null && p.id == currentUserId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildParticipantRow(
                index: index + 1,
                participant: p,
                isMe: isMe,
              ),
            );
          }),

        // Свободные места
        if (t.spotsLeft > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.textSecondary, width: 1),
                    ),
                    child: const Icon(Icons.add, color: AppTheme.textSecondary, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ещё ${t.spotsLeft} свободных мест',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // === Строка pending (оранжевая) ===
  Widget _buildPendingRow({
    required TournamentParticipant participant,
    required bool isMe,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _pendingColor.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pendingColor.withAlpha(60), width: 0.5),
      ),
      child: Row(
        children: [
          // Тире вместо номера
          const SizedBox(
            width: 24,
            child: Text(
              '–',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _pendingColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Аватар (оранжевый)
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _pendingColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Имя + уровень
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  participant.levelText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Бейдж "Ожидание"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _pendingColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _pendingColor.withAlpha(60), width: 0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: _pendingColor, size: 14),
                SizedBox(width: 4),
                Text(
                  'Ожидание',
                  style: TextStyle(
                    color: _pendingColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Строка registered ===
  Widget _buildParticipantRow({
    required int index,
    required TournamentParticipant participant,
    required bool isMe,
  }) {
    final Color primaryColor = isMe ? AppTheme.accent : AppTheme.textPrimary;
    final Color secondaryColor = isMe ? AppTheme.accent.withAlpha(180) : AppTheme.textSecondary;
    final Color avatarBg = isMe ? AppTheme.accent : const Color(0xFF2A2A2A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(15) : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppTheme.accent.withAlpha(60) : const Color(0xFF2A2A2A),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Номер
          SizedBox(
            width: 24,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Аватар
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Имя + уровень
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  participant.levelText,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Рейтинг
          Text(
            '${participant.rating}',
            style: TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // === Организатор ===
  Widget _buildOrganizerSection(Tournament t) {
    final orgName = t.club.name;
    final orgPhone = t.club.phone ?? '';
    final orgInitials = _getInitials(orgName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 0.5, color: const Color(0xFF2A2A2A)),
        const SizedBox(height: 20),
        const Text(
          'Организатор',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
          ),
          child: Row(
            children: [
              // Аватар
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    orgInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Имя + телефон
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (orgPhone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        orgPhone,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Кнопка чат
              _buildOrganizerAction(
                icon: Icons.chat_bubble_outline,
                color: AppTheme.textSecondary,
                bgColor: const Color(0xFF2A2A2A),
                onTap: () {},
              ),
              const SizedBox(width: 8),

              // Кнопка звонок
              _buildOrganizerAction(
                icon: Icons.phone,
                color: Colors.white,
                bgColor: AppTheme.accent,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerAction({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // === Показывать ли нижнюю кнопку ===
  bool _shouldShowBottomButton(Tournament t, TournamentProvider provider) {
    if (provider.isActionLoading) return true;
    if (t.canRegister && !t.isRegistered) return true;
    if (t.registrationStatus == 'pending') return true;
    if (t.isRegistered) return true;
    if (t.blockReason != null) return true;
    // Мест нет — не показываем панель
    return false;
  }

  // === Нижняя кнопка ===
  Widget _buildBottomButton(Tournament t, TournamentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: _buildActionButton(t, provider),
        ),
      ),
    );
  }

  Widget _buildActionButton(Tournament t, TournamentProvider provider) {
    // Загрузка
    if (provider.isActionLoading) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2.5),
          ),
        ),
      );
    }

    // Логика по документации API:
    // can_register === true → "Записаться"
    // is_registered === true и status === "open" → "Отменить запись"
    // is_registered === true и status !== "open" → "Вы участвуете"
    // spots_left === 0 → "Мест нет"
    // block_reason != null → показать причину

    if (t.canRegister && !t.isRegistered) {
      return ElevatedButton(
        onPressed: () => _onRegister(t.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 6),
            Text('Записаться', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // Заявка на модерации (pending)
    if (t.registrationStatus == 'pending') {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: _pendingColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Заявка на модерации',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (t.isRegistered && t.status == 'open') {
      return OutlinedButton(
        onPressed: () => _onCancel(t.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close, size: 20),
            SizedBox(width: 6),
            Text('Отменить запись', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (t.isRegistered) {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.accent.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withAlpha(60)),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
                SizedBox(width: 6),
                Text(
                  'Вы участвуете',
                  style: TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (t.blockReason != null) {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.blockReason!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    // Мест нет — нажатие обновляет данные
    return GestureDetector(
      onTap: () => _onRefresh(t.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 6),
              Text(
                'Мест нет',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRegister(int id) async {
    final provider = context.read<TournamentProvider>();
    final result = await provider.registerForTournament(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppTheme.accent : AppTheme.error,
        ),
      );
    }
  }

  void _onCancel(int id) async {
    final provider = context.read<TournamentProvider>();
    final result = await provider.cancelRegistration(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppTheme.accent : AppTheme.error,
        ),
      );
    }
  }

  void _onRefresh(int id) {
    context.read<TournamentProvider>().loadTournamentDetails(id);
  }

  // === My team card ===
  Widget _buildMyTeamCard(Tournament t, int? userId) {
    if (userId == null) return const SizedBox.shrink();
    final myTeam = t.teams.cast<TournamentTeam?>().firstWhere(
      (team) => team!.player1.id == userId || (team.player2 != null && team.player2!.id == userId),
      orElse: () => null,
    );
    if (myTeam == null) return const SizedBox.shrink();
    return TeamInfoCard(team: myTeam);
  }

  // === Team bottom button ===
  Widget _buildTeamBottomButton(Tournament t, TournamentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: _buildTeamActionButton(t, provider),
        ),
      ),
    );
  }

  Widget _buildTeamActionButton(Tournament t, TournamentProvider provider) {
    // Loading
    if (provider.isActionLoading) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2.5),
          ),
        ),
      );
    }

    // Can register — open partner search sheet
    if (t.canRegister && !t.isRegistered) {
      return ElevatedButton(
        onPressed: () => _openTeamRegistrationSheet(t.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, size: 20),
            SizedBox(width: 6),
            Text('Выбрать партнёра', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // Pending moderation
    if (t.registrationStatus == 'pending') {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: _pendingColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'Заявка на модерации',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Registered & open — can cancel
    if (t.isRegistered && t.status == 'open') {
      return OutlinedButton(
        onPressed: () => _onCancelTeam(t.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: const BorderSide(color: AppTheme.error, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close, size: 20),
            SizedBox(width: 6),
            Text('Отменить запись', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // Registered (tournament started/closed)
    if (t.isRegistered) {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.accent.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withAlpha(60)),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
                SizedBox(width: 6),
                Text(
                  'Вы участвуете',
                  style: TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Block reason
    if (t.blockReason != null) {
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.blockReason!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    // No spots
    return GestureDetector(
      onTap: () => _onRefresh(t.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 6),
              Text(
                'Мест нет',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTeamRegistrationSheet(int tournamentId) {
    final provider = context.read<TournamentProvider>();
    provider.clearPartnerSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: TeamRegistrationSheet(tournamentId: tournamentId),
      ),
    );
  }

  void _onCancelTeam(int id) async {
    final provider = context.read<TournamentProvider>();
    final result = await provider.cancelTeamRegistration(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppTheme.accent : AppTheme.error,
        ),
      );
    }
  }
}
