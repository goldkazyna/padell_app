import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/amigo.dart';
import '../providers/amigo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/amigos/amigo_open_sheet.dart';
import '../widgets/amigos/amigo_row.dart';
import '../widgets/app_back_button.dart';
import '../widgets/player_avatar.dart';
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
  bool _searchOpen = false;
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

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (!_searchOpen) {
      _searchController.clear();
      context.read<AmigoProvider>().clearSearch();
    }
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
        MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: status.gameId!)),
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
            child: Text(l10n.cancel, style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.amigosRemove,
              style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700),
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
                      const Spacer(),
                      // Поиск по всей базе: добавлять хочется не только тех,
                      // с кем уже играл.
                      GestureDetector(
                        onTap: _toggleSearch,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _searchOpen
                                ? AppTheme.accent.withValues(alpha: 0.16)
                                : AppTheme.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Icon(
                            _searchOpen ? Icons.close : Icons.search,
                            size: 18,
                            color: _searchOpen
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_searchOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.amigosSearchPlaceholder,
                        hintStyle: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: AppTheme.textDim,
                        ),
                        filled: true,
                        fillColor: AppTheme.cardRaised,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.accent),
                        ),
                      ),
                    ),
                  ),
                if (!_searchOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Tabs(
                    labels: [l10n.amigosMine, l10n.amigosFollowers, l10n.amigosFeed],
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
                  child: _searchOpen
                      ? _searchBody(provider, l10n)
                      : RefreshIndicator(
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

  /// Выдача поиска: те же строки кандидатов, но найденные по имени.
  Widget _searchBody(AmigoProvider provider, AppLocalizations l10n) {
    if (provider.isSearching && provider.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (provider.searchQuery.trim().length < 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Text(
          l10n.amigosSearchTitle,
          style: TextStyle(color: AppTheme.textDim, fontSize: 13),
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: _EmptyCard(text: l10n.amigosSearchNothing),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      children: [
        _ListCard(
          children: provider.searchResults
              .map((candidate) => _CandidateRow(
                    candidate: candidate,
                    onTap: () => _openPlayer(candidate.id, candidate.name),
                    onAdd: candidate.added
                        ? null
                        : () => context.read<AmigoProvider>().follow(candidate.id),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _body(AmigoProvider provider, AppLocalizations l10n) {
    if (provider.isLoading && provider.amigos.isEmpty && _tab == 0) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
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
    return [
      if (provider.amigos.isEmpty)
        _EmptyCard(text: l10n.amigosEmpty)
      else
        _ListCard(
          onLongPress: _remove,
          items: provider.amigos,
          children: provider.amigos
              .map((amigo) => AmigoRow(
                    amigo: amigo,
                    onTap: () => _openAmigo(amigo),
                    onStatusTap: () => _openAmigo(amigo),
                  ))
              .toList(),
        ),

      // Кандидаты показываем, пока список маленький: пустой экран на старте —
      // главная беда таких разделов.
      if (provider.candidates.isNotEmpty && provider.amigos.length < 5) ...[
        const SizedBox(height: 20),
        _SectionTitle(l10n.amigosCandidatesTitle),
        const SizedBox(height: 8),
        _ListCard(
          children: provider.candidates
              .map((candidate) => _CandidateRow(
                    candidate: candidate,
                    onTap: () => _openPlayer(candidate.id, candidate.name),
                    onAdd: candidate.added
                        ? null
                        : () => context.read<AmigoProvider>().follow(candidate.id),
                  ))
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
          child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        ),
      ];
    }

    if (provider.feed.isEmpty) {
      return [_EmptyCard(text: l10n.amigosEmptyFeed)];
    }

    return [
      _ListCard(
        children: provider.feed
            .map((event) => _FeedRow(
                  event: event,
                  onTap: () => _openPlayer(event.userId, event.playerName),
                  onTargetTap: () => _openStatus(AmigoStatus(
                    kind: event.kind,
                    title: event.title,
                    subtitle: event.subtitle,
                    tournamentId: event.tournamentId,
                    gameId: event.gameId,
                  )),
                ))
            .toList(),
      ),
    ];
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
                        color: active ? AppTheme.accent : const Color(0xFF52525B),
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
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.55),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _SmallButton({required this.label, required this.filled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: const Color(0xFF2A3330)),
        ),
        child: Text(
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
                  Text(
                    candidate.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // У найденных поиском совместных матчей нет — показываем
                    // уровень и рейтинг, иначе строка врала бы «0 матчей».
                    candidate.gamesTogether > 0
                        ? l10n.amigosGamesTogether(candidate.gamesTogether)
                        : [
                            if (candidate.level != null)
                              'ур. ${candidate.level!.toStringAsFixed(2)}',
                            if (candidate.rating > 0) '${candidate.rating}',
                          ].join(' · '),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _SmallButton(
              label: candidate.added ? l10n.amigosAdded : l10n.amigosAdd,
              filled: !candidate.added,
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка ленты: одна фраза, а не карточка — лента читается за секунду.
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            PlayerAvatar(
              name: event.playerName,
              avatarUrl: event.playerAvatar,
              size: 38,
              circle: true,
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
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (event.isPlaying)
              GestureDetector(
                onTap: onTargetTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
              Text(
                time,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
