import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../gradient_card_style.dart';
import '../pressable_card.dart';

class CourtBookingBanner extends StatelessWidget {
  final VoidCallback onTap;

  const CourtBookingBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: GradientCardStyle.decoration(const Color(0xFF22C55E)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bookCourt,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.bookCourtSubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  GradientCardStyle.glassChip(Icons.sports_tennis),
                ],
              ),
            ),
            GradientCardStyle.gloss(),
          ],
        ),
      ),
    );
  }
}
