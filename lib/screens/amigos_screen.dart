import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/amigo.dart';
import '../providers/amigo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/amigos/amigo_live_block.dart';
import '../widgets/amigos/amigo_open_sheet.dart';
import '../widgets/amigos/amigo_row.dart';
import '../widgets/court_grid_background.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_avatar.dart';
import '../widgets/verified_badge.dart';
import 'game_detail_screen.dart';
import 'player_profile_screen.dart';
import 'tournament_detail_screen.dart';
import 'tournament_live_entry_screen.dart';

/// Амигос: свои, кто добавил тебя, и лента активности.
///
/// Порядок строк приходит с сервера и не алфавитный: сначала те, кто на корте,
/// потом у кого турнир скоро. Полезное всегда сверху.
class AmigosScreen extends StatefulWidget {
  /// С какой вкладки открыть: 0 — мои, 1 — меня добавили, 2 — лента.
  final int initialTab;

  const AmigosScreen({super.key, this.initialTab = 0});

  @override
  State<AmigosScreen> createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  late int _tab = widget.initialTab;

  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Ищем не на каждую букву: иначе на каждый символ уходит запрос.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<AmigoProvider>().search(value);
    });
  }

  /// Тап по амигос: занят игрой — спрашиваем куда идти, иначе профиль.
  void _openAmigo(Amigo amigo) {
    openAmigoTarget(
      context,
      playerId: amigo.id,
      playerName: amigo.name,
      avatar: amigo.avatar,
      status: amigo.status,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<AmigoProvider>();
    await Future.wait([
      provider.loadAmigos(),
      provider.loadFollowers(),
      provider.loadCandidates(),
    ]);
    if (_tab == 2 && mounted) provider.loadFeed();
  }

  void _openPlayer(int id, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerProfileScreen(playerId: id, playerName: name),
      ),
    );
  }

  /// Куда ведёт статус: играет — в трансляцию, турнир — в турнир,
  /// ищет игроков — в игру.
  void _openStatus(AmigoStatus status) {
    if (status.isPlaying && status.tournamentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TournamentLiveEntryScreen(tournamentId: status.tournamentId!),
        ),
      );
      return;
    }
    if (status.tournamentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TournamentDetailScreen(tournamentId: status.tournamentId!),
        ),
      );
      return;
    }
    if (status.gameId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameDetailScreen(gameId: status.gameId!),
        ),
      );
    }
  }

  Future<void> _remove(Amigo amigo) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l10n.amigosRemoveConfirm(amigo.name),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.amigosRemove,
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<AmigoProvider>().unfollow(amigo.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<AmigoProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const SizedBox(width: 12),
                      Text(
                        l10n.amigos,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Tabs(
                    labels: [
                      l10n.amigosMine,
                      l10n.amigosFollowers,
                      l10n.amigosFeed,
                    ],
                    counts: [
                      provider.amigos.length,
                      provider.followers.length,
                      null,
                    ],
                    current: _tab,
                    onChanged: (index) {
                      setState(() => _tab = index);
                      if (index == 2) provider.loadFeed();
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.card,
                    onRefresh: _load,
                    child: _body(provider, l10n),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(AmigoProvider provider, AppLocalizations l10n) {
    if (provider.isLoading && provider.amigos.isEmpty && _tab == 0) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      children: switch (_tab) {
        1 => _followersTab(provider, l10n),
        2 => _feedTab(provider, l10n),
        _ => _mineTab(provider, l10n),
      },
    );
  }

  List<Widget> _mineTab(AmigoProvider provider, AppLocalizations l10n) {
    final playing = provider.amigos
        .where((a) => a.status?.isPlaying == true)
        .toList();
    final rest = provider.amigos
        .where((a) => a.status?.isPlaying != true)
        .toList();

    return [
      // Главный вопрос экрана — «кто сейчас на корте». Пока кто-то играет,
      // он занимает верх блоком с фактурой корта.
      if (playing.isNotEmpty) ...[
        AmigoLiveBlock(
          amigos: playing,
          onOpen: _openAmigo,
          onWatch: (amigo) => _openStatus(amigo.status!),
        ),
        const SizedBox(height: 18),
      ],

      if (provider.amigos.isEmpty)
        _EmptyCard(text: l10n.amigosEmpty)
      else if (rest.isNotEmpty) ...[
        _SectionTitle('${l10n.amigosMyTitle} · ${provider.amigos.length}'),
        const SizedBox(height: 8),
        _ListCard(
          onLongPress: _remove,
          items: rest,
          children: rest
              .map(
                (amigo) => AmigoRow(
                  amigo: amigo,
                  onTap: () => _openAmigo(amigo),
                  onStatusTap: () => _openAmigo(amigo),
                ),
              )
              .toList(),
        ),
      ],

      // Поиск живёт прямо в списке, над кандидатами: добавлять хочется не
      // только тех, с кем уже играл, и прятать это за лупой незачем.
      const SizedBox(height: 20),
      TextField(
        controller: _searchController,
        style: TextStyle(color: AppTheme.textPrimary),
        onChanged: _onSearchChanged,
        onSubmitted: (value) {
          _debounce?.cancel();
          context.read<AmigoProvider>().search(value);
        },
        decoration: InputDecoration(
          hintText: l10n.amigosSearchPlaceholder,
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: provider.searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AmigoProvider>().clearSearch();
                  },
                ),
        ),
      ),
      const SizedBox(height: 14),

      // Пока ищут — показываем найденных; иначе тех, с кем уже играли.
      if (provider.searchQuery.trim().length >= 2) ...[
        if (provider.isSearching && provider.searchResults.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
          )
        else if (provider.searchResults.isEmpty)
          _EmptyCard(text: l10n.amigosSearchNothing)
        else
          _ListCard(
            children: provider.searchResults
                .map(
                  (candidate) => _CandidateRow(
                    candidate: candidate,
                    onTap: () => _openPlayer(candidate.id, candidate.name),
                    onAdd: candidate.added
                        ? null
                        : () => context.read<AmigoProvider>().follow(
                            candidate.id,
                          ),
                  ),
                )
                .toList(),
          ),
      ] else if (provider.candidates.isNotEmpty) ...[
        _SectionTitle(l10n.amigosCandidatesTitle),
        const SizedBox(height: 8),
        _ListCard(
          children: provider.candidates
              .map(
                (candidate) => _CandidateRow(
                  candidate: candidate,
                  onTap: () => _openPlayer(candidate.id, candidate.name),
                  onAdd: candidate.added
                      ? null
                      : () =>
                            context.read<AmigoProvider>().follow(candidate.id),
                ),
              )
              .toList(),
        ),
      ],
    ];
  }

  List<Widget> _followersTab(AmigoProvider provider, AppLocalizations l10n) {
    if (provider.followers.isEmpty) {
      return [_EmptyCard(text: l10n.amigosEmptyFollowers)];
    }

    return [
      _ListCard(
        children: provider.followers.map((amigo) {
          final added = amigo.isAmigo;

          return AmigoRow(
            amigo: amigo,
            onTap: () => _openPlayer(amigo.id, amigo.name),
            trailing: added
                ? _SmallButton(
                    label: l10n.amigosMutual,
                    filled: false,
                    onTap: null,
                  )
                : _SmallButton(
                    label: l10n.amigosAddBack,
                    filled: true,
                    pending: provider.isPending(amigo.id),
                    onTap: () => context.read<AmigoProvider>().follow(amigo.id),
                  ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _feedTab(AmigoProvider provider, AppLocalizations l10n) {
    if (provider.isLoadingFeed && provider.feed.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          ),
        ),
      ];
    }

    if (provider.feed.isEmpty) {
      return [_EmptyCard(text: l10n.amigosEmptyFeed)];
    }

    final live = provider.feed.where((e) => e.isPlaying).toList();
    final rest = provider.feed.where((e) => !e.isPlaying).toList();

    final widgets = <Widget>[];

    // Идущие игры — наверх и крупно: у них есть кнопка, остальное читают.
    for (final event in live) {
      widgets.add(
        _FeedLiveCard(
          event: event,
          onOpen: () => _openFeedEvent(event),
          onWatch: () => _openStatus(_statusOf(event)),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    // Остальное — по дням: без заголовков лента выглядит сломанной, потому
    // что время идёт «21:54, 22:10, 21:57» — это разные дни.
    DateTime? currentDay;
    List<Widget> dayRows = [];

    void flushDay() {
      if (dayRows.isEmpty) return;
      widgets.add(_ListCard(children: List.of(dayRows)));
      dayRows = [];
    }

    for (final event in rest) {
      final day = _dayOf(event.at);
      if (currentDay == null || day != currentDay) {
        flushDay();
        currentDay = day;
        widgets.add(const SizedBox(height: 8));
        widgets.add(_SectionTitle(_dayLabel(day, l10n)));
        widgets.add(const SizedBox(height: 8));
      }

      dayRows.add(
        _FeedRow(
          event: event,
          onTap: () => _openFeedEvent(event),
          onTargetTap: () => _openStatus(_statusOf(event)),
        ),
      );
    }
    flushDay();

    return widgets;
  }

  /// День события без времени — по нему группируем.
  DateTime _dayOf(DateTime? at) {
    final local = (at ?? DateTime.now()).toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  String _dayLabel(DateTime day, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return l10n.messageToday;
    if (day == yesterday) return l10n.messageYesterday;

    return DateFormat(
      'd MMMM',
      Localizations.localeOf(context).languageCode,
    ).format(day);
  }

  AmigoStatus _statusOf(AmigoFeedEvent event) => AmigoStatus(
    kind: event.kind,
    title: event.title,
    subtitle: event.subtitle,
    tournamentId: event.tournamentId,
    gameId: event.gameId,
  );

  /// Тап по событию: у играющего спрашиваем куда идти, у остальных — профиль.
  void _openFeedEvent(AmigoFeedEvent event) {
    openAmigoTarget(
      context,
      playerId: event.userId,
      playerName: event.playerName,
      avatar: event.playerAvatar,
      status: event.isPlaying ? _statusOf(event) : null,
    );
  }
}

/// Вкладки со счётчиками. Отдельно от AppTabs — тут три раздела и счётчик
/// нужен у двух из них.
class _Tabs extends StatelessWidget {
  final List<String> labels;
  final List<int?> counts;
  final int current;
  final ValueChanged<int> onChanged;

  const _Tabs({
    required this.labels,
    required this.counts,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1)),
      ),
      // Три вкладки в узкий экран не влезают — строка едет вбок, а не
      // переносится: правило дизайн-системы.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (index) {
            final active = index == current;
            final count = counts[index];

            return Padding(
              padding: const EdgeInsets.only(right: 22),
              child: GestureDetector(
                onTap: () => onChanged(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? AppTheme.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: active
                              ? AppTheme.accent
                              : const Color(0xFF52525B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (count != null && count > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          '$count',
                          style: TextStyle(
                            color: active ? AppTheme.accent : AppTheme.textDim,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final List<Widget> children;

  /// Долгий тап по строке — убрать из амигос.
  final Future<void> Function(Amigo)? onLongPress;
  final List<Amigo>? items;

  const _ListCard({required this.children, this.onLongPress, this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = onLongPress != null && items != null
          ? GestureDetector(
              onLongPress: () => onLongPress!(items![i]),
              child: children[i],
            )
          : children[i];

      rows.add(child);
      if (i != children.length - 1) {
        rows.add(Divider(height: 1, thickness: 0.5, color: AppTheme.divider));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Column(children: rows),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppTheme.textDim,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool pending;
  final VoidCallback? onTap;

  const _SmallButton({
    required this.label,
    required this.filled,
    this.pending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pending ? null : onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: const Color(0xFF2A3330)),
        ),
        child: pending
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: filled ? Colors.black : AppTheme.textSecondary,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.black : AppTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// Кружок «добавить»: плюс, во время запроса — крутилка, потом галочка.
///
/// Крутилка живёт в самой кнопке, а не одна на экран: сервер отвечает не
/// мгновенно, и без отклика человек не понимает, нажалось или нет, и жмёт
/// второй раз.
class _AddCircle extends StatelessWidget {
  final bool added;
  final bool pending;
  final VoidCallback? onTap;

  const _AddCircle({required this.added, this.pending = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: added || pending ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: added
              ? Colors.white.withValues(alpha: 0.06)
              : AppTheme.accent.withValues(alpha: 0.14),
        ),
        child: pending
            ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accent,
                ),
              )
            : Icon(
                added ? Icons.check : Icons.add,
                size: added ? 16 : 19,
                color: added ? AppTheme.textDim : AppTheme.accent,
              ),
      ),
    );
  }
}

/// Строка кандидата: с кем уже играли, но ещё не добавили.
class _CandidateRow extends StatelessWidget {
  final AmigoCandidate candidate;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const _CandidateRow({required this.candidate, this.onTap, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PlayerAvatar(
              name: candidate.name,
              avatarUrl: candidate.avatar,
              size: 38,
              circle: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          candidate.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (candidate.levelVerified) ...[
                        const SizedBox(width: 5),
                        const VerifiedBadge(size: 10),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Кто он сейчас: уровень и рейтинг. Это решает, звать ли
                  // человека в пару, — важнее, чем сколько вы сыграли.
                  Text(
                    [
                      if (candidate.level != null)
                        'ур. ${candidate.level!.toStringAsFixed(2)}',
                      if (candidate.rating > 0) '${candidate.rating}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  // Совместная история — второй строкой, с процентом побед
                  // вдвоём. У найденных поиском её нет, строку не рисуем.
                  if (candidate.gamesTogether > 0) ...[
                    const SizedBox(height: 2),
                    // Одной строкой с разной раскраской: два отдельных Text
                    // в Row не помещались и упирались в кнопку.
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.amigosGamesTogether(
                              candidate.gamesTogether,
                            ),
                          ),
                          const TextSpan(text: '  ·  '),
                          TextSpan(
                            text: l10n.amigosWinrateTogether(candidate.winrate),
                            style: TextStyle(
                              // Та же шкала, что у винрейта в профиле:
                              // 60+ зелёный, 40+ жёлтый, ниже красный.
                              color: candidate.winrate >= 60
                                  ? AppTheme.accent
                                  : (candidate.winrate >= 40
                                        ? AppTheme.amber
                                        : AppTheme.error),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Круглый плюс вместо надписи «В амигос»: десять зелёных кнопок
            // подряд превращали список в стену акцента.
            _AddCircle(
              added: candidate.added,
              pending: context.watch<AmigoProvider>().isPending(candidate.id),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Крупная карточка «играет прямо сейчас» — верх ленты.
class _FeedLiveCard extends StatelessWidget {
  final AmigoFeedEvent event;
  final VoidCallback onOpen;
  final VoidCallback onWatch;

  const _FeedLiveCard({
    required this.event,
    required this.onOpen,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16281F), Color(0xFF0D1714)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CourtGridBackground(coverage: 0.7)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onOpen,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent, width: 2),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: PlayerAvatar(
                        name: event.playerName,
                        avatarUrl: event.playerAvatar,
                        size: 40,
                        circle: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onOpen,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.playerName.split(' ').first} ${l10n.amigoPlaying}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onWatch,
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        l10n.amigoWatch,
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

/// Строка ленты: кто, что сделал и с каким результатом.
class _FeedRow extends StatelessWidget {
  final AmigoFeedEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onTargetTap;

  const _FeedRow({required this.event, this.onTap, this.onTargetTap});

  String _phrase(AppLocalizations l10n) {
    final firstName = event.playerName.split(' ').first;

    return switch (event.kind) {
      'playing' => '$firstName ${l10n.amigoPlaying}',
      'soon' => '$firstName · ${l10n.amigoTournament}',
      'looking' => '$firstName ${l10n.amigoLooking}',
      'played' => '$firstName ${l10n.amigoPlayed}',
      _ => firstName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = event.at == null
        ? ''
        : DateFormat('HH:mm').format(event.at!.toLocal());
    final change = event.ratingChange ?? 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Кольцо у играющего — то же, что в списке и в профиле.
            Container(
              decoration: event.isPlaying
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent, width: 1.5),
                    )
                  : null,
              padding: event.isPlaying
                  ? const EdgeInsets.all(2)
                  : EdgeInsets.zero,
              child: PlayerAvatar(
                name: event.playerName,
                avatarUrl: event.playerAvatar,
                size: event.isPlaying ? 34 : 38,
                circle: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _phrase(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (event.isPlaying)
              GestureDetector(
                onTap: onTargetTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.amigoWatch.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.55,
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Рост рейтинга акцентом, падение приглушённо: подсвечивать
                  // красным чужой минус незачем.
                  if (change != 0)
                    Text(
                      change > 0 ? '+$change' : '$change',
                      style: TextStyle(
                        color: change > 0 ? AppTheme.accent : AppTheme.textDim,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    event.place != null
                        ? l10n.amigoPlaceShort(event.place!)
                        : time,
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Открыть экран амигос и показать ошибку, если она пришла.
Future<void> openAmigos(BuildContext context, {int initialTab = 0}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AmigosScreen(initialTab: initialTab)),
  );

  if (!context.mounted) return;
  final error = context.read<AmigoProvider>().error;
  if (error != null) {
    showAppAlert(context, error, isError: true);
  }
}
