import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_primary_button.dart';
import '../utils/tournament_type_l10n.dart';
import '../utils/app_alert.dart';
import '../utils/rating_formatter.dart';
import '../models/tournament.dart';
import '../providers/settings_provider.dart';
import '../providers/tournament_provider.dart';
import '../providers/home_provider.dart';
import '../services/chat_service.dart';
import '../widgets/app_back_button.dart';
import '../widgets/moderation_countdown.dart';
import '../widgets/tournaments/team_list_section.dart';
import '../widgets/tournaments/team_info_card.dart';
import '../widgets/tournaments/team_registration_sheet.dart';
import '../widgets/tournaments/friend_registration_sheet.dart';
import '../widgets/verified_badge.dart';
import 'player_profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'tournament_chat_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  Timer? _chatUnreadTimer;
  int? _chatUnread; // живой счётчик непрочитанного (перекрывает значение из модели)
  Timer? _paymentTimer; // прячет кнопку оплаты в момент истечения дедлайна
  DateTime? _scheduledDeadline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().loadTournamentDetails(widget.tournamentId);
    });
    // Каждые 5 сек обновляем бейдж чата, пока экран открыт.
    _chatUnreadTimer = Timer.periodic(
        const Duration(seconds: 5), (_) => _pollChatUnread());
  }

  @override
  void dispose() {
    _chatUnreadTimer?.cancel();
    _paymentTimer?.cancel();
    super.dispose();
  }

  /// Дедлайн оплаты прошёл (кнопку оплаты показывать нельзя).
  bool _paymentDeadlinePassed(Tournament t) =>
      t.moderationDeadline != null &&
      !t.moderationDeadline!.isAfter(DateTime.now());

  /// Одноразовый таймер: перестроить экран ровно в момент истечения дедлайна,
  /// чтобы кнопка оплаты исчезла без ручного обновления.
  void _maybeSchedulePaymentExpiry(Tournament t) {
    final deadline =
        t.registrationStatus == 'pending' ? t.moderationDeadline : null;
    if (deadline == _scheduledDeadline) return; // уже запланировано
    _paymentTimer?.cancel();
    _scheduledDeadline = deadline;
    if (deadline != null && deadline.isAfter(DateTime.now())) {
      _paymentTimer = Timer(
        deadline.difference(DateTime.now()) + const Duration(seconds: 1),
        () {
          if (mounted) setState(() {});
        },
      );
    }
  }

  Future<void> _pollChatUnread() async {
    final t = context.read<TournamentProvider>().selectedTournament;
    if (t == null || t.id != widget.tournamentId || t.chat?.canRead != true) {
      return;
    }
    try {
      final count =
          await context.read<ChatService>().getUnreadCount(widget.tournamentId);
      if (mounted) setState(() => _chatUnread = count);
    } catch (_) {
      // молча ретраим на следующем тике
    }
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
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.failedToLoadTournament,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Запланировать скрытие кнопки оплаты в момент истечения дедлайна.
          _maybeSchedulePaymentExpiry(tournament);

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
                          if ((tournament.description ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _DescriptionBlock(text: tournament.description!),
                          ],
                          if (tournament.hasPrizes &&
                              (tournament.prizes?.trim().isNotEmpty ?? false)) ...[
                            const SizedBox(height: 12),
                            _PrizesBlock(text: tournament.prizes!.trim()),
                          ],
                          if (tournament.registrationStatus == 'pending' &&
                              tournament.club.paymentUrl != null &&
                              !_paymentDeadlinePassed(tournament))
                            _buildPaymentButton(tournament),
                          const SizedBox(height: 28),
                          if (!tournament.usesSoloRegistration) ...[
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
                  !tournament.usesSoloRegistration
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
    final tournament = context.read<TournamentProvider>().selectedTournament;
    // Живой счётчик из опроса перекрывает значение из модели турнира.
    final chatUnread = _chatUnread ?? (tournament?.chat?.unreadCount ?? 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppBackButton(),
          Row(
            children: [
              if (tournament?.chat?.canRead == true)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildCircleButton(
                        icon: CupertinoIcons.chat_bubble,
                        onTap: () => _openChat(context, tournament!),
                      ),
                      if (chatUnread > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 20, minHeight: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(10),
                              // Тёмное кольцо-отбивка от кнопки (как на макете).
                              border: Border.all(
                                  color: AppTheme.background, width: 2),
                            ),
                            child: Text(
                              '$chatUnread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCircleButton(
                  icon: CupertinoIcons.calendar_badge_plus,
                  onTap: () => _addToCalendar(),
                ),
              ),
              _buildCircleButton(
                icon: Icons.ios_share,
                onTap: () => _shareTournament(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context, Tournament t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TournamentChatScreen(
          tournamentId: t.id,
          tournamentName: t.name,
          chat: t.chat!,
        ),
      ),
    );
    // Вернулись из чата (кнопка «назад») — гасим бейдж сразу (сообщения уже
    // отмечены прочитанными) и перечитываем детали турнира.
    if (mounted) {
      setState(() => _chatUnread = 0);
      context.read<TournamentProvider>().loadTournamentDetails(t.id);
    }
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
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }

  Future<void> _shareTournament() async {
    final tournament = context.read<TournamentProvider>().selectedTournament;
    if (tournament == null) return;

    final shareUrl = 'https://padel-p.kz/t/${tournament.id}';
    // Короткий текст — основная инфа уйдёт в OG-превью карточку,
    // которую WhatsApp / Telegram отрендерят сами.
    final text = '🎾 «${tournament.name}»\n$shareUrl';

    // На iOS / iPad share-sheet требует положение для якоря —
    // без него на iPad он не открывается, на iOS-iPhone иногда тоже
    // ведёт себя неконсистентно. Берём позицию текущего контекста.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await Share.share(
        text,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      showAppAlert(
        context,
        '$e',
        title: 'Не удалось открыть «Поделиться»',
        isError: true,
      );
    }
  }

  Future<void> _addToCalendar() async {
    final tournament = context.read<TournamentProvider>().selectedTournament;
    if (tournament == null) return;

    // Длительность турнира: если задана — берём её, иначе спрашиваем у пользователя.
    var hours = tournament.durationHours;
    if (hours == null) {
      hours = await _askTournamentDuration();
      if (hours == null || !mounted) return; // отменили выбор
    }

    // datetime приходит как UTC-обёртка над местным (клубным) временем Алматы
    // (start_date->toIso8601String() отдаёт +00:00, хотя часы — местные).
    // Dart при парсинге сдвигает это в локальное время устройства, поэтому берём
    // .toUtc() (возвращает исходные 20:00) и эти стеночные часы кладём как локальные —
    // тогда календарь покажет ровно то время, что у турнира, без сдвига.
    final dt = tournament.datetime.toUtc();
    final start = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);

    final event = Event(
      title: tournament.name,
      description: 'https://padel-p.kz/t/${tournament.id}',
      location: tournament.club.fullAddress,
      startDate: start,
      endDate: start.add(Duration(hours: hours)),
    );

    try {
      final ok = await Add2Calendar.addEvent2Cal(event);
      if (!ok && mounted) {
        showAppAlert(context, AppLocalizations.of(context)!.error, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showAppAlert(context, '$e',
          title: AppLocalizations.of(context)!.error, isError: true);
    }
  }

  /// Диалог выбора длительности турнира (когда она не задана). Возвращает часы или null.
  Future<int?> _askTournamentDuration() {
    final l10n = AppLocalizations.of(context)!;
    const options = [1, 2, 3, 4];
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.tournamentDurationTitle,
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tournamentDurationSubtitle,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options
                  .map((h) => GestureDetector(
                        onTap: () => Navigator.pop(ctx, h),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            '$h ${l10n.hoursShort}',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // === Теги ===
  Widget _buildTags(Tournament t) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = t.isFull ? AppTheme.error : AppTheme.accent;
    final statusText = t.isFull
        ? l10n.noSpotsLeftUpper
        : _localizeStatus(l10n, t.status).toUpperCase();
    final typeLabel = localizeTournamentType(context, t.type, fallback: t.typeName)
        .toUpperCase();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildTag(typeLabel, t.typeColor),
        _buildTag(statusText, statusColor),
        if (!t.isRated) _buildTag(l10n.tournamentUnrated, AppTheme.orange),
        if (t.verifiedOnly)
          _buildTag(l10n.tournamentVerifiedOnly, AppTheme.accent),
      ],
    );
  }

  String _localizeStatus(AppLocalizations l, String status) {
    switch (status) {
      case 'open':
        return l.tournamentStatusOpen;
      case 'closed':
        return l.tournamentStatusClosed;
      case 'in_progress':
        return l.tournamentStatusInProgress;
      case 'completed':
        return l.tournamentStatusCompleted;
      case 'cancelled':
        return l.tournamentStatusCancelled;
      case 'draft':
        return l.tournamentStatusDraft;
      default:
        return status;
    }
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
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // === Локация ===
  Widget _buildLocation(Tournament t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                t.club.fullAddress,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        // Клуб-площадка (где играют) — если задан, показываем отдельной строкой.
        if (t.venueClubName != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.place_outlined,
                  color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  t.venueClubCity != null && t.venueClubCity!.isNotEmpty
                      ? 'Площадка: ${t.venueClubName}, ${t.venueClubCity}'
                      : 'Площадка: ${t.venueClubName}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // === Дата и Время ===
  Widget _buildDateTimeRow(Tournament t) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('d MMMM', locale).format(t.datetime);
    final dowText = toBeginningOfSentenceCase(
        DateFormat.EEEE(locale).format(t.datetime)) ?? '';
    return IntrinsicHeight(child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          label: l10n.dateLabel,
          icon: Icons.calendar_today_outlined,
          value: dateText,
          subtitle: dowText,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          label: l10n.timeLabel,
          icon: Icons.access_time_outlined,
          value: t.time,
          subtitle: '',
        ),
      ],
    ));
  }

  // === Уровень и Стоимость ===
  Widget _buildLevelPriceRow(Tournament t) {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicHeight(child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(
          label: l10n.levelLabel,
          icon: Icons.signal_cellular_alt,
          value: '${t.minLevel} – ${t.maxLevel}',
          subtitle: t.levelCategoryText,
        ),
        const SizedBox(width: 8),
        _buildInfoCard(
          label: l10n.costLabel,
          value: t.priceText,
          valueColor: AppTheme.accent,
          subtitle: l10n.perPerson,
        ),
      ],
    ));
  }

  // === Кнопка оплаты ===
  Widget _buildPaymentButton(Tournament t) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () async {
            final url = Uri.parse(t.club.paymentUrl!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.payment, size: 20),
          label: Text(
            AppLocalizations.of(context)!.pay,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    IconData? icon,
    required String value,
    required String subtitle,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
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
                      color: valueColor ?? AppTheme.textPrimary,
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
                style: TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final pending = t.participants.where((p) => p.status == 'pending').toList();
    final registered = t.participants.where((p) => p.status != 'pending').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === На модерации ===
        if (pending.isNotEmpty) ...[
          Row(
            children: [
              Text(
                l10n.pendingModeration,
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
            Text(
              l10n.participants,
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
              l10n.countOfMax(t.participantsCount, t.maxParticipants),
              style: TextStyle(
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
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            child: Center(
              child: Text(
                l10n.noParticipantsYet,
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
                    child: Icon(Icons.add, color: AppTheme.textSecondary, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.spotsLeftCount(t.spotsLeft),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // === Лист ожидания ===
        if (t.waitlistParticipants.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Лист ожидания',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(t.waitlistParticipants.length, AppTheme.blue),
              const Spacer(),
              if (t.waitlistSize > 0)
                Text(
                  '${t.waitlistParticipants.length} / ${t.waitlistSize}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(t.waitlistParticipants.length, (index) {
            final p = t.waitlistParticipants[index];
            final isMe = currentUserId != null && p.id == currentUserId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildWaitlistRow(index: index + 1, participant: p, isMe: isMe),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildWaitlistRow({
    required int index,
    required TournamentParticipant participant,
    required bool isMe,
  }) {
    final Color primaryColor = isMe ? AppTheme.blue : AppTheme.textPrimary;
    final Color secondaryColor = isMe ? AppTheme.blue.withAlpha(180) : AppTheme.textSecondary;
    final Color avatarBg = isMe ? AppTheme.blue : const Color(0xFF2A3330);

    return GestureDetector(
      onTap: () => _openPlayerProfile(participant.id, participant.name),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.blue.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.blue.withAlpha(60), width: 0.5),
        ),
        child: Row(
          children: [
            // Номер в очереди
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
            _buildAvatar(
              avatarUrl: participant.avatar,
              initials: participant.initials,
              fallbackBg: avatarBg,
            ),
            const SizedBox(width: 10),

            // Имя + статус «В очереди»
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          participant.name,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (participant.levelVerified) ...[
                        const SizedBox(width: 5),
                        const VerifiedBadge(size: 11),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.hourglass_bottom, color: AppTheme.blue.withAlpha(200), size: 11),
                      const SizedBox(width: 4),
                      Text(
                        'В очереди',
                        style: TextStyle(
                          color: AppTheme.blue.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Рейтинг
            Builder(builder: (ctx) {
              final precise = ctx.watch<SettingsProvider>().preciseRating;
              return Text(
                RatingFormatter.formatRating(participant.rating, precise),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      ),
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

  /// Универсальный аватар: фото если есть avatarUrl и оно грузится,
  /// иначе fallback — инициалы на цветном фоне.
  Widget _buildAvatar({
    required String? avatarUrl,
    required String initials,
    required Color fallbackBg,
    double size = 36,
  }) {
    final initialsWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fallbackBg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final hasUrl = (avatarUrl ?? '').isNotEmpty;
    if (!hasUrl) return initialsWidget;

    return ClipOval(
      child: Image.network(
        avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => initialsWidget,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return initialsWidget;
        },
      ),
    );
  }

  void _openPlayerProfile(int playerId, String playerName) {
    if (playerId <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(
          playerId: playerId,
          playerName: playerName,
        ),
      ),
    );
  }

  // === Строка pending (оранжевая) ===
  Widget _buildPendingRow({
    required TournamentParticipant participant,
    required bool isMe,
  }) {
    return GestureDetector(
      onTap: () => _openPlayerProfile(participant.id, participant.name),
      behavior: HitTestBehavior.opaque,
      child: Container(
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

          // Аватар (оранжевый fallback)
          _buildAvatar(
            avatarUrl: participant.avatar,
            initials: participant.initials,
            fallbackBg: _pendingColor,
          ),
          const SizedBox(width: 10),

          // Имя + уровень
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (participant.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 11),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Builder(builder: (ctx) {
                  final precise = ctx.watch<SettingsProvider>().preciseRating;
                  return Text(
                    RatingFormatter.formatLevelLabel(
                      bucketedLevel: participant.level,
                      rating: participant.rating,
                      precise: precise,
                    ),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  );
                }),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: _pendingColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.pendingStatus,
                  style: const TextStyle(
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
    final Color avatarBg = isMe ? AppTheme.accent : const Color(0xFF2A3330);

    return GestureDetector(
      onTap: () => _openPlayerProfile(participant.id, participant.name),
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(15) : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppTheme.accent.withAlpha(60) : const Color(0xFF2A3330),
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
          _buildAvatar(
            avatarUrl: participant.avatar,
            initials: participant.initials,
            fallbackBg: avatarBg,
          ),
          const SizedBox(width: 10),

          // Имя + уровень
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (participant.levelVerified) ...[
                      const SizedBox(width: 5),
                      const VerifiedBadge(size: 11),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Builder(builder: (ctx) {
                  final precise = ctx.watch<SettingsProvider>().preciseRating;
                  return Text(
                    RatingFormatter.formatLevelLabel(
                      bucketedLevel: participant.level,
                      rating: participant.rating,
                      precise: precise,
                    ),
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Рейтинг
          Builder(builder: (ctx) {
            final precise = ctx.watch<SettingsProvider>().preciseRating;
            return Text(
              RatingFormatter.formatRating(participant.rating, precise),
              style: TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ],
      ),
      ),
    );
  }

  // === Организатор ===
  Widget _buildOrganizerSection(Tournament t) {
    final orgName = t.club.name;
    final orgPhone = t.club.phone ?? '';
    final orgInitials = _getInitials(orgName);
    final orgLogo = t.club.logo;
    final orgTelegramUrl = t.club.telegramUrl ?? '';

    // Виджет с инициалами (используется как основной или fallback)
    final initialsAvatar = Container(
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
    );

    // Аватар: логотип клуба или инициалы
    final avatarWidget = (orgLogo != null && orgLogo.isNotEmpty)
        ? ClipOval(
            child: Image.network(
              orgLogo,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => initialsAvatar,
            ),
          )
        : initialsAvatar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 0.5, color: const Color(0xFF2A3330)),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.organizer,
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
            border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Аватар
                  avatarWidget,
                  const SizedBox(width: 12),

                  // Имя + телефон
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orgName,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (orgPhone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            orgPhone,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Кнопка звонок
                  if (orgPhone.isNotEmpty)
                    _buildOrganizerAction(
                      icon: Icons.phone,
                      color: Colors.white,
                      bgColor: AppTheme.accent,
                      onTap: () {
                        final phone = orgPhone.replaceAll(RegExp(r'[^\d+]'), '');
                        launchUrl(Uri.parse('tel:$phone'));
                      },
                    ),
                ],
              ),

              // Кнопка Telegram-канала
              if (orgTelegramUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final uri = Uri.parse(t.club.telegramUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.telegram, color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Канал · $orgName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    // Мест нет, но турнир открыт — показываем кнопку подписки
    if (t.spotsLeft <= 0 && t.status == 'open' && !t.isRegistered) return true;
    return false;
  }

  // === Нижняя кнопка ===
  Widget _buildBottomButton(Tournament t, TournamentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _buildActionButton(t, provider),
      ),
    );
  }

  Widget _buildActionButton(Tournament t, TournamentProvider provider) {
    // Загрузка
    if (provider.isActionLoading) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A3330),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2.5),
            ),
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
      // Если у турнира задана ссылка на Telegram-чат — записываемся через него,
      // а не через нашу систему.
      final tgUrl = t.telegramRegistrationUrl;
      if (tgUrl != null && tgUrl.isNotEmpty) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(tgUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF229ED9), // Telegram blue
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 20),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.registerViaChat,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPrimaryButton(
            label: AppLocalizations.of(context)!.registerButton,
            onPressed: () => _onRegister(t.id),
            icon: Icons.add,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openFriendRegistrationSheet(t.id),
              icon: const Icon(Icons.group_add_outlined, size: 18),
              label: const Text(
                'Записаться с другом',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accent,
                side: const BorderSide(color: AppTheme.accent, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    }

    // В листе ожидания — можно отменить
    if (t.registrationStatus == 'waiting') {
      final pos = t.waitlistPosition;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top, color: Color(0xFFFFB020), size: 16),
              const SizedBox(width: 6),
              Text(
                pos != null
                    ? 'В листе ожидания · позиция $pos'
                    : 'В листе ожидания',
                style: const TextStyle(
                    color: Color(0xFFFFB020), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _onCancel(t.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: BorderSide(color: AppTheme.error, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20),
                  SizedBox(width: 6),
                  Text('Выйти из листа ожидания',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Заявка на модерации (pending) — можно отменить
    if (t.registrationStatus == 'pending') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: _pendingColor, size: 16),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.applicationPending,
                style: TextStyle(color: _pendingColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (t.moderationDeadline != null) ...[
            const SizedBox(height: 10),
            ModerationCountdown(deadline: t.moderationDeadline!),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _onCancel(t.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: BorderSide(color: AppTheme.error, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, size: 20),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.cancelApplication, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (t.isRegistered && t.status == 'open') {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () => _onCancel(t.id),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.error,
            side: BorderSide(color: AppTheme.error, width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.close, size: 20),
              const SizedBox(width: 6),
              Text(AppLocalizations.of(context)!.cancelRegistration, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    if (t.isRegistered) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.accent.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withAlpha(60)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.youAreParticipating,
                  style: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Мест нет, но турнир открыт — кнопка подписки
    if (t.spotsLeft <= 0 && t.status == 'open' && !t.isRegistered) {
      return _buildSubscribeButton(t);
    }

    if (t.blockReason != null) {
      final bool verifiedBlock = t.verifiedOnly && !t.isRegistered;
      final Color c = verifiedBlock ? AppTheme.accent : AppTheme.orange;
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.45)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(verifiedBlock ? Icons.verified_user : Icons.info_outline,
                      color: c, size: 19),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      t.blockReason!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: c, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
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
          color: const Color(0xFF2A3330),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.noSpotsLeft,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(bool success, String message, {bool offerPayment = false}) {
    // Оплату предлагаем ТОЛЬКО при успешной записи (offerPayment) — не при отмене.
    // И только если у клуба задана ссылка оплаты и дедлайн оплаты не прошёл.
    final t = context.read<TournamentProvider>().selectedTournament;
    final payUrl = (offerPayment &&
            success &&
            t != null &&
            t.club.paymentUrl != null &&
            t.club.paymentUrl!.isNotEmpty &&
            !_paymentDeadlinePassed(t))
        ? t.club.paymentUrl!
        : null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? AppTheme.accent : AppTheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (payUrl != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Вам нужно оплатить участие в турнире.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final url = Uri.parse(payUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('Оплатить',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ОК — приглушённая, но нажимаемая (закрыть без оплаты).
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardRaised,
                      foregroundColor: AppTheme.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.ok,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: success ? AppTheme.accent : AppTheme.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.ok,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onRegister(int id) async {
    final provider = context.read<TournamentProvider>();
    var result = await provider.registerForTournament(id);

    if (result.isWaitlistConfirm && mounted) {
      final confirmed = await _askWaitlistConfirmation(result);
      if (confirmed != true || !mounted) return;
      result = await provider.registerForTournament(id, confirmWaitlist: true);
    }

    if (mounted) {
      _showResultDialog(result.isSuccess, result.message, offerPayment: true);
    }
  }

  /// Спрашивает у пользователя согласие встать в лист ожидания.
  Future<bool?> _askWaitlistConfirmation(RegisterOutcome outcome) {
    final pos = outcome.result?.waitlistPosition;
    final size = outcome.result?.waitlistSize ?? 0;
    final posText = pos != null && size > 0 ? '\nВаша позиция: $pos из $size' : '';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Все места заняты', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Встать в лист ожидания? Если кто-то отменит запись — вас автоматически переведут на турнир.$posText',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Нет', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Встать в очередь', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  void _onCancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Отменить заявку?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Вы уверены, что хотите отозвать заявку на турнир?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Нет', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Да, отменить', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<TournamentProvider>();
    final result = await provider.cancelRegistration(id);
    if (mounted) {
      _showResultDialog(result.success, result.message);
    }
  }

  void _onRefresh(int id) {
    context.read<TournamentProvider>().loadTournamentDetails(id);
  }

  Widget _buildSubscribeButton(Tournament t) {
    if (t.isSubscribed) {
      return OutlinedButton(
        onPressed: () => _onUnsubscribe(t.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accent,
          side: const BorderSide(color: AppTheme.accent, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 20),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context)!.subscriptionActive, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _onSubscribe(t.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 20),
          const SizedBox(width: 6),
          Text(AppLocalizations.of(context)!.notifyOnFreeSpot, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _onSubscribe(int id) async {
    final provider = context.read<TournamentProvider>();
    final result = await provider.subscribeToTournament(id);
    if (mounted) {
      showAppAlert(context, result.message, isError: !result.success);
    }
  }

  void _onUnsubscribe(int id) async {
    final provider = context.read<TournamentProvider>();
    final result = await provider.unsubscribeFromTournament(id);
    if (mounted) {
      showAppAlert(context, result.message, isError: !result.success);
    }
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
      decoration: BoxDecoration(
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
          color: const Color(0xFF2A3330),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_add, size: 20),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context)!.choosePartner, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.applicationPending,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
          side: BorderSide(color: AppTheme.error, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, size: 20),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context)!.cancelRegistration, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accent, size: 20),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.youAreParticipating,
                  style: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No spots, but tournament is open — subscribe button
    if (t.spotsLeft <= 0 && t.status == 'open' && !t.isRegistered) {
      return _buildSubscribeButton(t);
    }

    // Block reason — делаем заметным (иконка + цветная подложка + жирный текст)
    if (t.blockReason != null) {
      final bool verifiedBlock = t.verifiedOnly && !t.isRegistered;
      final Color c = verifiedBlock ? AppTheme.accent : AppTheme.orange;
      return GestureDetector(
        onTap: () => _onRefresh(t.id),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.45)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(verifiedBlock ? Icons.verified_user : Icons.info_outline,
                      color: c, size: 19),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      t.blockReason!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: c, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
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
          color: const Color(0xFF2A3330),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.noSpotsLeft,
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

  void _openFriendRegistrationSheet(int tournamentId) {
    final provider = context.read<TournamentProvider>();
    provider.clearPartnerSearch();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: FriendRegistrationSheet(tournamentId: tournamentId),
      ),
    );
  }

  void _onCancelTeam(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Отменить заявку?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Вы уверены, что хотите отозвать заявку команды на турнир?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Нет', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Да, отменить', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<TournamentProvider>();
    final result = await provider.cancelTeamRegistration(id);
    if (mounted) {
      _showResultDialog(result.success, result.message);
    }
  }
}

/// Блок «Призы» — золотой, показывается для призовых турниров с описанием призов.
class _PrizesBlock extends StatelessWidget {
  final String text;
  const _PrizesBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, size: 15, color: AppTheme.amber),
              const SizedBox(width: 6),
              Text(
                l.prizesLabel,
                style: TextStyle(
                  color: AppTheme.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Блок «Описание турнира» — свёрнут до пяти строк, по тапу разворачивается.
/// Рядом кнопка копирования: в описании часто оставляют номер телефона
/// для предоплаты, и выделить его из свёрнутого текста нельзя.
class _DescriptionBlock extends StatefulWidget {
  final String text;
  const _DescriptionBlock({required this.text});

  @override
  State<_DescriptionBlock> createState() => _DescriptionBlockState();
}

class _DescriptionBlockState extends State<_DescriptionBlock> {
  bool _expanded = false;
  bool _isOverflowing = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Описание скопировано'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const collapsedLines = 5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.tournamentDescription,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copy,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 14, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Скопировать',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isOverflowing
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tp = TextPainter(
                  text: TextSpan(
                    text: widget.text,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  maxLines: collapsedLines,
                  textDirection: TextDirection.ltr,
                  // Без масштаба система с крупным шрифтом переносит текст
                  // на большее число строк, чем насчитал замер: текст
                  // обрезается, а ссылка «показать всё» не появляется.
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout(maxWidth: constraints.maxWidth);

                final overflowing = tp.didExceedMaxLines;
                if (overflowing != _isOverflowing) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _isOverflowing = overflowing);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      maxLines: _expanded ? null : collapsedLines,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (overflowing) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _expanded
                                ? AppLocalizations.of(context)!.showLess
                                : AppLocalizations.of(context)!.showMore,
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppTheme.accent,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
