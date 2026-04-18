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

  const ClubSectionHeader({
    super.key,
    required this.clubName,
    required this.city,
    required this.logoUrl,
    required this.openCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
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
                    style: const TextStyle(
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
                        const Icon(Icons.location_on_outlined,
                            size: 10, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          city!,
                          style: const TextStyle(
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$openCount',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: ' / $totalCount',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'открыто',
                  style: TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
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

  const ClubSubHeader({
    super.key,
    required this.clubName,
    required this.city,
    required this.logoUrl,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 10),
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
                    style: const TextStyle(
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
                      style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}
