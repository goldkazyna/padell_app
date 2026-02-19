import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final user = profile.user;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withAlpha(40),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.accent, width: 2),
                    ),
                    child: user?.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              user!.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitials(user),
                            ),
                          )
                        : _buildInitials(user),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Пользователь',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                color: AppTheme.textSecondary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              user?.formattedPhone ?? '',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const _EditProfilePlaceholder(),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Builder(builder: (_) {
                final level = double.tryParse(user?.level ?? '0') ?? 0;
                final rating = user?.rating ?? 0;
                final currentLevelRating = (level * 1000).round();
                final nextLevel = level >= 5.0 ? 5.0 : level + 0.25;
                final nextLevelRating = (nextLevel * 1000).round();
                final step = nextLevelRating - currentLevelRating;
                final progress = step > 0
                    ? ((rating - currentLevelRating) / step).clamp(0.0, 1.0)
                    : 1.0;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Уровень ${user?.level ?? '-'}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$rating / $nextLevelRating XP',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF2A2A2A),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitials(dynamic user) {
    return Center(
      child: Text(
        user?.initials ?? '??',
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EditProfilePlaceholder extends StatelessWidget {
  const _EditProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Редактировать профиль',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
        ),
      ),
      body: const Center(
        child: Text(
          'Скоро здесь будет редактирование профиля',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
        ),
      ),
    );
  }
}
