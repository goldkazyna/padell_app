import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/admin_matches.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/verified_badge.dart';

/// Экран-превью красивой таблицы турнира для выгрузки в соцсети (Вариант 1,
/// Americano Flex). Рендерит карточку в PNG и открывает «Поделиться».
class TournamentStandingsShareScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;
  final String type; // americano_flex / round_robin / americano / mexicano / ...
  final String typeName;
  final DateTime? startDate;
  final String? clubName;
  final String? clubLogo;
  final List<AdminLeaderboardRow> rows;

  const TournamentStandingsShareScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.type,
    required this.typeName,
    required this.startDate,
    required this.clubName,
    this.clubLogo,
    required this.rows,
  });

  @override
  State<TournamentStandingsShareScreen> createState() =>
      _TournamentStandingsShareScreenState();
}

class _TournamentStandingsShareScreenState
    extends State<TournamentStandingsShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Прогреваем аватары, чтобы к рендеру PNG они уже были загружены.
    if (!_precached) {
      _precached = true;
      for (final r in widget.rows) {
        if (r.avatarUrl != null && r.avatarUrl!.isNotEmpty) {
          precacheImage(NetworkImage(r.avatarUrl!), context).catchError((_) {});
        }
      }
      if (widget.clubLogo != null && widget.clubLogo!.isNotEmpty) {
        precacheImage(NetworkImage(widget.clubLogo!), context)
            .catchError((_) {});
      }
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      // Небольшая пауза, чтобы гарантированно отрисовалось.
      await Future.delayed(const Duration(milliseconds: 120));
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      // Плотность 2: при 3 картинка выходила избыточно тяжёлой.
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/standings_${widget.tournamentId}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.tournamentName,
      );
    } catch (e) {
      if (mounted) {
        showAppAlert(context, 'Не удалось сформировать картинку', isError: true);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 58,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: const Text('Таблица турнира',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Center(
                // Картинка не должна зависеть от системного размера шрифта:
                // при крупном шрифте текст распирал карточку и выгрузка
                // получалась огромной и разъехавшейся. Внутри карточки
                // масштабирование выключено, снаружи интерфейс живёт как жил.
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _StandingsCard(
                      tournamentName: widget.tournamentName,
                      type: widget.type,
                      typeName: widget.typeName,
                      startDate: widget.startDate,
                      clubName: widget.clubName,
                      clubLogo: widget.clubLogo,
                      rows: widget.rows,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
            child: AppPrimaryButton(
              label: 'Поделиться',
              icon: Icons.ios_share,
              loading: _sharing,
              onPressed: _share,
            ),
          ),
        ],
      ),
    );
  }
}

/// Сама карточка (Вариант 1: полная таблица Flex, короткие заголовки).
class _StandingsCard extends StatelessWidget {
  final String tournamentName;
  final String type;
  final String typeName;
  final DateTime? startDate;
  final String? clubName;
  final String? clubLogo;
  final List<AdminLeaderboardRow> rows;

  const _StandingsCard({
    required this.tournamentName,
    required this.type,
    required this.typeName,
    required this.startDate,
    required this.clubName,
    required this.clubLogo,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = startDate != null
        ? DateFormat('d MMMM y', 'ru').format(startDate!)
        : null;
    final def = _colsFor(type);
    final cols = def.$1;
    final legend = def.$2;

    // Ширина колонки — по самому длинному значению в ней, а не константой:
    // иначе столбец с «5» занимает столько же, сколько с «136:105».
    final widths = <double>[
      for (final c in cols) _measure(c, rows),
    ];

    return Container(
      width: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16241D), Color(0xFF0E1512), Color(0xFF0B120F)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(6, 20, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Бренд
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Лого клуба слева (со-брендинг).
              if ((clubLogo ?? '').isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: const Color(0xFF2A3330)),
                  ),
                  child: Image.network(
                    clubLogo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                )
              else
                const SizedBox(width: 40),
              // Наш логотип справа.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset('assets/app_icon.png',
                        width: 34, height: 34, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 9),
                  const Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'PADEL',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    TextSpan(
                        text: '·KZ',
                        style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                  ])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tournamentName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                height: 1.12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              if (typeName.isNotEmpty) _chip(typeName, accent: true),
              if (dateText != null) _chip(dateText),
              if ((clubName ?? '').isNotEmpty) _chip(clubName!),
            ],
          ),
          const SizedBox(height: 16),
          _headerRow(cols, widths),
          const SizedBox(height: 2),
          for (int i = 0; i < rows.length; i++) _playerRow(rows[i], cols, widths),
          const SizedBox(height: 8),
          Text(
            legend,
            style: const TextStyle(color: Color(0xFF5C665F), fontSize: 8.5),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF2A3330)),
          const SizedBox(height: 10),
          const Text('Сформировано в приложении Padel KZ',
              style: TextStyle(
                  color: Color(0xFF5C665F),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0x2622C55E)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: accent ? const Color(0x4D22C55E) : const Color(0xFF2A3330)),
      ),
      child: Text(text,
          style: TextStyle(
              color: accent ? const Color(0xFF22C55E) : const Color(0xFF8A968F),
              fontSize: 10.5,
              fontWeight: FontWeight.w700)),
    );
  }

  /// Сколько места нужно колонке: самое длинное значение плюс небольшой
  /// запас. Цифра при 11.5 px занимает примерно 7 px.
  double _measure(_Col c, List<AdminLeaderboardRow> rows) {
    var longest = c.header.length;
    for (final r in rows) {
      final len = c.value(r).length;
      if (len > longest) longest = len;
    }

    return (longest * 7.0 + 8).clamp(20.0, 64.0);
  }

  Widget _headerRow(List<_Col> cols, List<double> widths) {
    const st = TextStyle(
        color: Color(0xFF5C665F),
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Row(
        children: [
          const Expanded(child: Text('#  Игрок', style: st)),
          for (var i = 0; i < cols.length; i++)
            SizedBox(
              width: widths[i],
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child:
                    Text(cols[i].header, maxLines: 1, softWrap: false, style: st),
              ),
            ),
        ],
      ),
    );
  }

  /// Имя игрока/пары в строке таблицы. Для пар — оба игрока на двух строках.
  Widget _shareIdentity(AdminLeaderboardRow p) {
    final pair = (p.players != null && p.players!.length == 2) ? p.players! : null;
    Widget line({
      required String? url,
      required String name,
      required bool verified,
      required int id,
      double avatarSize = 22,
    }) {
      return Row(
        children: [
          _CardAvatar(url: url, name: name, size: avatarSize),
          const SizedBox(width: 7),
          Flexible(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          if (verified) ...[
            const SizedBox(width: 4),
            // На 20% меньше: в картинке галочка спорила с именем.
            VerifiedBadge(size: 8.8, userId: id, playerName: name),
          ],
        ],
      );
    }

    if (pair == null) {
      return line(
          url: p.avatarUrl, name: p.name, verified: p.verified, id: p.id);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          line(
            url: pair[i].avatarUrl,
            name: pair[i].name,
            verified: pair[i].verified,
            id: pair[i].id,
            avatarSize: 22,
          ),
        ],
      ],
    );
  }

  Widget _playerRow(
      AdminLeaderboardRow p, List<_Col> cols, List<double> widths) {
    final isTop = p.position <= 3;

    Color rankBg = const Color(0xFF2A332E);
    Color rankFg = const Color(0xFF8A968F);
    if (p.position == 1) {
      rankBg = const Color(0xFFFACC15);
      rankFg = const Color(0xFF0B120F);
    } else if (p.position == 2) {
      rankBg = const Color(0xFFC0C0C0);
      rankFg = const Color(0xFF0B120F);
    } else if (p.position == 3) {
      rankBg = const Color(0xFFCD7F32);
      rankFg = const Color(0xFF0B120F);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      decoration: BoxDecoration(
        color: isTop
            ? const Color(0x1022C55E)
            : Colors.white.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(10),
        border: isTop ? Border.all(color: const Color(0x2922C55E)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration:
                      BoxDecoration(color: rankBg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${p.position}',
                      style: TextStyle(
                          color: rankFg,
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                Expanded(child: _shareIdentity(p)),
              ],
            ),
          ),
          for (var i = 0; i < cols.length; i++)
            SizedBox(
              width: widths[i],
              // Значение всегда в одну строку: «136:105» переносилось на две
              // и читалось как мусор. Не влезает — ужимаем, а не ломаем.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(cols[i].value(p),
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        color: cols[i].color(p),
                        fontSize: 11.5,
                        fontWeight: cols[i].weight)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Колонка таблицы: заголовок + значение/цвет по строке.
class _Col {
  final String header;
  final String Function(AdminLeaderboardRow) value;
  final Color Function(AdminLeaderboardRow) color;
  final FontWeight weight;

  // Ширины у колонки нет: её считает карточка по самому длинному значению.
  const _Col(this.header, this.value, this.color,
      {this.weight = FontWeight.w700});
}

const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _dim = Color(0xFF8A968F);

Color _diffColor(int d) => d > 0 ? _green : (d < 0 ? _red : _dim);

/// Набор колонок + легенда по типу турнира (совпадает с админ-таблицей).
(List<_Col>, String) _colsFor(String type) {
  switch (type) {
    case 'americano_flex':
      return (
        [
          _Col('Заб', (p) => '${p.pointsFor}', (_) => _green),
          _Col('Проп', (p) => '${p.pointsAgainst}', (_) => _red),
          _Col('Разн', (p) {
            final d = p.pointsFor - p.pointsAgainst;
            return d > 0 ? '+$d' : '$d';
          }, (p) => _diffColor(p.pointsFor - p.pointsAgainst)),
          _Col('Матч', (p) => '${p.matchesPlayed ?? 0}', (_) => _dim),

          _Col('Сред', (p) {
            final m = p.matchesPlayed ?? 0;
            final a = p.avgPoints ?? (m > 0 ? p.pointsFor / m : 0.0);
            return a.toStringAsFixed(2);
          }, (_) => _green, weight: FontWeight.w900),
        ],
        'Заб — забито · Проп — пропущено · Разн — разница · Матч — матчей · Сред — среднее'
      );
    case 'round_robin':
      return (
        [
          _Col('В', (p) => '${p.wins}', (_) => _green),
          _Col('П', (p) => '${p.losses}', (_) => _red),
          _Col('З', (p) => '${p.pointsFor}', (_) => Colors.white),
          _Col('Пр', (p) => '${p.pointsAgainst}', (_) => _dim),
          _Col('±', (p) {
            final d = p.pointDiff;
            return d > 0 ? '+$d' : '$d';
          }, (p) => _diffColor(p.pointDiff)),
        ],
        'В — победы · П — поражения · З — забито · Пр — пропущено · ± — разница'
      );
    default: // americano / mexicano / king_of_court / just_padel_it / bali_koc
      return (
        [
          _Col('В', (p) => '${p.wins}', (_) => _green),
          _Col('П', (p) => '${p.losses}', (_) => _red),
          _Col('Р', (p) => '${p.pointsFor}:${p.pointsAgainst}', (_) => _dim),
          _Col('Очки', (p) => '${p.totalPoints}', (_) => _green,
              weight: FontWeight.w900),
        ],
        'В — победы · П — поражения · Р — счёт мячей · Очки — сумма очков'
      );
  }
}

class _CardAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  const _CardAvatar({this.url, required this.name, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
    final fallback = Center(
      child: Text(initials,
          style: const TextStyle(
              color: Color(0xFF8A968F),
              fontSize: 10,
              fontWeight: FontWeight.w800)),
    );
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF27302B)),
      child: url != null && url!.isNotEmpty
          ? Image.network(url!,
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
          : fallback,
    );
  }
}
