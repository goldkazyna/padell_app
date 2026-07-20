import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/legal_docs.dart';
import '../widgets/app_back_button.dart';
import '../utils/app_alert.dart';

/// Раздел «Документы» — список юридических документов PADEL KZ.
/// Каждая строка открывает соответствующий PDF во внешнем приложении.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<void> _openDoc(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      showAppAlert(context, AppLocalizations.of(context)!.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final docs = <_DocItem>[
      _DocItem(l10n.docTitleOffer, kLegalOfferUrl),
      _DocItem(l10n.docTitlePrivacy, kLegalPrivacyUrl),
      _DocItem(l10n.docTitleGoods, kLegalGoodsUrl),
      _DocItem(l10n.docTitleCard, kLegalCardUrl),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Text(
                    l10n.documentsTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _DocRow(
                  title: docs[i].title,
                  onTap: () => _openDoc(context, docs[i].url),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocItem {
  final String title;
  final String url;
  const _DocItem(this.title, this.url);
}

class _DocRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DocRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.fromBorderSide(BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.picture_as_pdf_outlined,
                    size: 20, color: AppTheme.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
