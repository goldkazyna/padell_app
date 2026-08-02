import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import 'certificate_detail_screen.dart';

/// Список сертификатов клиента: сегмент Активные/Использованные, группировка
/// по клубам. По тапу — сам сертификат с дизайном клуба.
class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _loading = true;
  String? _error;
  CertificatesResult _data = CertificatesResult.empty();
  bool _showUsed = false;

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
      final data = await context.read<CertificateService>().getCertificates();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    l.certificatesTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(l)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    if (_data.certificates.isEmpty) {
      return _empty(l);
    }

    final list =
        _data.certificates.where((c) => c.used == _showUsed).toList();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        children: [
          _segment(l),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  _showUsed ? l.certUsed : l.certActive,
                  style: TextStyle(color: AppTheme.textDim, fontSize: 13),
                ),
              ),
            )
          else
            ..._groupedByClub(list, l),
        ],
      ),
    );
  }

  Widget _segment(AppLocalizations l) {
    Widget tab(String text, bool used) {
      final on = _showUsed == used;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _showUsed = used),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppTheme.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: on ? const Color(0xFF06210F) : AppTheme.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          tab('${l.certActive} · ${_data.activeCount}', false),
          tab('${l.certUsed} · ${_data.usedCount}', true),
        ],
      ),
    );
  }

  List<Widget> _groupedByClub(List<Certificate> list, AppLocalizations l) {
    // Порядок клубов — по появлению.
    final order = <int>[];
    final byClub = <int, List<Certificate>>{};
    for (final c in list) {
      final k = c.club.id ?? 0;
      if (!byClub.containsKey(k)) {
        byClub[k] = [];
        order.add(k);
      }
      byClub[k]!.add(c);
    }

    final widgets = <Widget>[];
    for (final k in order) {
      final certs = byClub[k]!;
      final club = certs.first.club;
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(2, 6, 2, 9),
        child: Row(
          children: [
            _ClubLogo(url: club.logo, name: club.name),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                club.name,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              (club.city == null || club.city!.isEmpty)
                  ? '${certs.length}'
                  : '${club.city} · ${certs.length}',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ],
        ),
      ));
      for (final c in certs) {
        widgets.add(_certRow(c, l));
      }
      widgets.add(const SizedBox(height: 10));
    }
    return widgets;
  }

  Widget _certRow(Certificate c, AppLocalizations l) {
    final subtitle = c.used
        ? '${l.certStatusUsed} ${_fmtDate(c.usedAt)}'
        : c.number;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CertificateDetailScreen(certificate: c)),
      ),
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: c.used ? 0.62 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  c.used
                      ? Icons.check_circle_outline
                      : Icons.workspace_premium_outlined,
                  size: 16,
                  color: c.used ? AppTheme.textSecondary : AppTheme.accent,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.valueLabel,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 11,
                        fontFeatures: c.used
                            ? null
                            : const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusBadge(c, l),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: AppTheme.textDim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(Certificate c, AppLocalizations l) {
    final active = !c.used;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.accentSoft : const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppTheme.accent.withValues(alpha: 0.35) : AppTheme.border,
        ),
      ),
      child: Text(
        active ? l.certStatusActive : l.certStatusUsed,
        style: TextStyle(
          color: active ? AppTheme.accent : AppTheme.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined,
                size: 46, color: AppTheme.textDim),
            const SizedBox(height: 14),
            Text(
              l.certEmptyTitle,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.certEmptyText,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const m = [
      '', 'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }
}

class _ClubLogo extends StatelessWidget {
  final String? url;
  final String name;
  const _ClubLogo({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      width: 30,
      height: 30,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppTheme.border),
      ),
      child: (url != null && url!.isNotEmpty)
          ? Image.network(url!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(initials))
          : _fallback(initials),
    );
  }

  Widget _fallback(String t) => Center(
        child: Text(t,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}
