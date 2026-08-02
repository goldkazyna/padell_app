import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/certificate.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';

/// Экран сертификата — рендер по дизайну конструктора клуба (картинка-фон или
/// классический документ). Тап — полноэкранный просмотр, «Поделиться» — PDF.
class CertificateDetailScreen extends StatefulWidget {
  final Certificate certificate;
  const CertificateDetailScreen({super.key, required this.certificate});

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  static const _serif = ['Georgia', 'Times New Roman', 'serif'];
  final GlobalKey _docKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = widget.certificate;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    l.certDetailTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  _shareButton(l),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  GestureDetector(
                    onTap: () => _openFullscreen(c, l),
                    child: RepaintBoundary(
                      key: _docKey,
                      child: _document(c, l),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _status(c, l),
                  const SizedBox(height: 12),
                  _hint(c, l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _document(Certificate c, AppLocalizations l) {
    final d = c.design;
    final grayscale = c.used;

    // Режим v2 — картинка-фон + поля поверх.
    if (d.hasImage) {
      final doc = _imageDocument(c, l);
      if (!grayscale) return doc;
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.5, 0.35, 0.15, 0, 0,
          0.5, 0.35, 0.15, 0, 0,
          0.5, 0.35, 0.15, 0, 0,
          0, 0, 0, 0.85, 0,
        ]),
        child: doc,
      );
    }

    final doc = AspectRatio(
      aspectRatio: 0.74,
      child: Container(
        decoration: BoxDecoration(
          color: d.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Двойная рамка
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: d.borderColor, width: 2.5),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: d.accentColor, width: 1),
                  ),
                ),
              ),
            ),
            // Контент
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _logo(c),
                  const SizedBox(height: 12),
                  Text(
                    c.club.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: d.borderColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.heading.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: d.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      height: 1.1,
                      fontFamilyFallback: _serif,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(width: 56, height: 3, color: d.accentColor),
                  const SizedBox(height: 14),
                  Text(
                    c.isNamed ? d.subtitleNamed : d.subtitleGeneric,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF6B6157), fontSize: 11.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: d.accentColor, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 6),
                    child: Text(
                      c.isNamed
                          ? (c.recipientName ?? '')
                          : l.certBearer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.isNamed
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF78716C),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: _serif,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    c.valueLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: d.borderColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontFamilyFallback: _serif,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.bodyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF4A4038), fontSize: 11.5, height: 1.4),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _footCol('№', c.number, d.borderColor, mono: true),
                      const Spacer(),
                      _footCol(l.certIssued, _fmtDate(c.createdAt),
                          const Color(0xFF57534E)),
                    ],
                  ),
                ],
              ),
            ),
            // Печать «ПОГАШЕН»
            if (grayscale)
              Positioned.fill(
                child: Center(
                  child: Transform.rotate(
                    angle: -0.24,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFB23B3B), width: 3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l.certStamp,
                        style: const TextStyle(
                          color: Color(0xFFB23B3B),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!grayscale) return doc;
    // Приглушаем использованный сертификат.
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.5, 0.35, 0.15, 0, 0,
        0.5, 0.35, 0.15, 0, 0,
        0.5, 0.35, 0.15, 0, 0,
        0, 0, 0, 0.85, 0,
      ]),
      child: doc,
    );
  }

  /// Рендер по картинке-фону: картинка + поля name/value/number поверх.
  Widget _imageDocument(Certificate c, AppLocalizations l) {
    final d = c.design;
    final texts = <String, String?>{
      'name': c.isNamed ? c.recipientName : null,
      'value': (c.title != null && c.title!.isNotEmpty) ? c.title : c.valueLabel,
      'number': c.number,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.network(
            d.backgroundImage!,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => AspectRatio(
              aspectRatio: 1.4,
              child: Container(color: const Color(0xFF1C252B)),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (ctx, cons) {
                final w = cons.maxWidth;
                final h = cons.maxHeight;
                if (!w.isFinite || !h.isFinite || h == 0) {
                  return const SizedBox.shrink();
                }
                final fields = <Widget>[];
                d.layout!.forEach((key, f) {
                  final text = texts[key];
                  if (text == null || text.isEmpty) return;
                  final dx = f.align == 'center'
                      ? -0.5
                      : f.align == 'right'
                          ? -1.0
                          : 0.0;
                  fields.add(Positioned(
                    left: f.x / 100 * w,
                    top: f.y / 100 * h,
                    child: FractionalTranslation(
                      translation: Offset(dx, -0.5),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: (f.size * w / 1000).clamp(6.0, 200.0),
                          color: f.color,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ));
                });
                return Stack(children: fields);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo(Certificate c) {
    final d = c.design;
    if (d.logoUrl != null && d.logoUrl!.isNotEmpty) {
      return Image.network(
        d.logoUrl!,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _logoFallback(c),
      );
    }
    return _logoFallback(c);
  }

  Widget _logoFallback(Certificate c) {
    final initials = c.club.name.trim().isEmpty
        ? '?'
        : c.club.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.design.accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _footCol(String label, String value, Color valueColor,
      {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              color: Color(0xFFA49A8E),
              fontSize: 8,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: mono ? 10 : 11,
            fontWeight: FontWeight.w700,
            fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      ],
    );
  }

  Widget _status(Certificate c, AppLocalizations l) {
    final active = !c.used;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(active ? Icons.circle : Icons.check_circle,
            size: 12,
            color: active ? AppTheme.accent : AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          active ? l.certActiveUsable : '${l.certRedeemed} ${_fmtDate(c.usedAt)}',
          style: TextStyle(
            color: active ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _hint(Certificate c, AppLocalizations l) {
    final active = !c.used;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 13, 11),
      decoration: BoxDecoration(
        color: active ? AppTheme.accentSoft : const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              active ? AppTheme.accent.withValues(alpha: 0.3) : AppTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(active ? Icons.info_outline : Icons.check_circle_outline,
              size: 15,
              color: active ? AppTheme.accent : AppTheme.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              active ? l.certActiveHint : l.certUsedHint,
              style: TextStyle(
                color: active
                    ? const Color(0xFFB9E9C9)
                    : AppTheme.textSecondary,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareButton(AppLocalizations l) {
    return GestureDetector(
      onTap: _sharing ? null : _share,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _sharing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF06210F)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.ios_share, size: 15, color: Color(0xFF06210F)),
                  const SizedBox(width: 5),
                  Text(
                    l.certShare,
                    style: const TextStyle(
                        color: Color(0xFF06210F),
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  /// Захват сертификата → PDF → системный шэринг (WhatsApp/Telegram/…).
  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary =
          _docKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('capture failed');
      final bytes = byteData.buffer.asUint8List();

      final pdf = pw.Document();
      final img = pw.MemoryImage(bytes);
      const pageW = 800.0;
      final pageH = pageW * image.height / image.width;
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(pageW, pageH),
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(img, fit: pw.BoxFit.fill),
      ));

      final dir = await getTemporaryDirectory();
      final safe = widget.certificate.number
          .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
      final file = File('${dir.path}/certificate_$safe.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Сертификат · ${widget.certificate.club.name}',
      );
    } catch (_) {
      if (mounted) {
        showAppAlert(context, AppLocalizations.of(context)!.loadError);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// Полноэкранный просмотр сертификата с зумом.
  void _openFullscreen(Certificate c, AppLocalizations l) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _document(c, l),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }
}
