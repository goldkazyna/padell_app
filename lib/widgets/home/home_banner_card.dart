import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/home_banner.dart';
import '../../theme/app_theme.dart';
import '../pressable_card.dart';

class HomeBannerCard extends StatelessWidget {
  final HomeBanner banner;

  const HomeBannerCard({super.key, required this.banner});

  Future<void> _open() async {
    final link = banner.link;
    if (link == null || link.trim().isEmpty) return;
    final uri = Uri.parse(link.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = banner.link != null && banner.link!.trim().isNotEmpty;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        banner.image,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppTheme.card,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: image,
    );

    if (!hasLink) return card;

    return PressableCard(onTap: _open, child: card);
  }
}
