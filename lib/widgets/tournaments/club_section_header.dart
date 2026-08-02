import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'club_logo.dart';

/// Большой заголовок группы клубов в «Остальные турниры» /
/// «Мои» / «Архив».
class ClubSectionHeader extends StatelessWidget {
  final String clubName;
  final String? city;
  final String? logoUrl;
  final int openCount;
  final int totalCount;
  final VoidCallback? onTap;
  final bool collapsed;

  const ClubSectionHeader({
    super.key,
    required this.clubName,
    required this.city,
    required this.logoUrl,
    required this.openCount,
    required this.totalCount,
    this.onTap,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
        child: Row(
          children: [
            ClubLogoTile(url: logoUrl, name: clubName, size: 38, radius: 9),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clubName,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (city != null && city!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 10, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          city!,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              collapsed ? Icons.expand_more : Icons.expand_less,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Маленький под-хедер клуба внутри секции «Для вас».
class ClubSubHeader extends StatelessWidget {
  final String clubName;
  final String? city;
  final String? logoUrl;
  final int count;
  final VoidCallback? onTap;
  final bool collapsed;

  const ClubSubHeader({
    super.key,
    required this.clubName,
    required this.city,
    required this.logoUrl,
    required this.count,
    this.onTap,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
        child: Row(
          children: [
            ClubLogoTile(url: logoUrl, name: clubName, size: 30, radius: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clubName,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (city != null && city!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      city!,
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              collapsed ? Icons.expand_more : Icons.expand_less,
              size: 16,
              color: AppTheme.textDim,
            ),
          ],
        ),
      ),
    );
  }
}
