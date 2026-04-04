import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../providers/player_provider.dart';
import '../../models/player.dart';
import '../../widgets/common_widgets.dart';
import '../../components/animated_gradient_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        final player = playerProvider.currentPlayer;

        if (player == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return NeonGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showSettings(context, playerProvider),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildProfileHeader(context, player),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStats(context, player),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAchievements(context, player),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(context, playerProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Player player) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: player.avatar.color.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  player.avatar.color,
                  player.avatar.color.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: Text(
                AvatarPresets.getAvatarEmoji(player.avatar),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            player.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Playing since ${_formatDate(player.createdAt)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, Player player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.secondary, size: 24),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatBadge(
                icon: Icons.games_rounded,
                value: '${player.totalGamesPlayed}',
                label: 'Games Played',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatBadge(
                icon: Icons.emoji_events_rounded,
                value: '${player.totalWins}',
                label: 'Wins',
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StatBadge(
          icon: Icons.star_rounded,
          value: '${player.totalScore}',
          label: 'Total Score',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context, Player player) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium,
                      color: AppColors.tertiary, size: 24),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${player.achievements.length}/10',
                  style: const TextStyle(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (player.achievements.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Column(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 48)),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'No achievements yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Play games to unlock achievements!',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.start,
              children: player.achievements.map((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    achievement,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, PlayerProvider playerProvider) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.tertiary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Change your name and avatar',
            color: AppColors.primary,
            onTap: () => _showEditProfile(context, playerProvider),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionItem(
            icon: Icons.palette_outlined,
            title: 'Customize Avatar',
            subtitle: 'Pick a new look',
            color: AppColors.secondary,
            onTap: () => _showAvatarPicker(context, playerProvider),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionItem(
            icon: Icons.info_outline,
            title: 'About Party Chaos',
            subtitle: 'Learn more about the app',
            color: AppColors.tertiary,
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, PlayerProvider playerProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Change your name and avatar',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                _showEditProfile(context, playerProvider);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionItem(
              icon: Icons.palette_outlined,
              title: 'Customize Avatar',
              subtitle: 'Pick a new look',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                _showAvatarPicker(context, playerProvider);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App info and credits',
              color: AppColors.tertiary,
              onTap: () {
                Navigator.pop(context);
                _showAbout(context);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, PlayerProvider playerProvider) {
    final controller = TextEditingController(
      text: playerProvider.currentPlayer?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                playerProvider.updatePlayer(name: controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, PlayerProvider playerProvider) {
    int selectedFaceIndex = playerProvider.currentPlayer?.avatar.index ?? 0;
    int selectedColorIndex = AvatarPresets.colors.indexWhere(
      (c) => c == playerProvider.currentPlayer?.avatar.color,
    );
    if (selectedColorIndex < 0) selectedColorIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AvatarPresets.colors[selectedColorIndex],
                  boxShadow: [
                    BoxShadow(
                      color: AvatarPresets.colors[selectedColorIndex]
                          .withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    AvatarPresets.faces[selectedFaceIndex],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.start,
                children: List.generate(AvatarPresets.faces.length, (index) {
                  final isSelected = selectedFaceIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFaceIndex = index),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AvatarPresets.colors[selectedColorIndex]
                                .withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isSelected
                              ? AvatarPresets.colors[selectedColorIndex]
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AvatarPresets.faces[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Choose Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.start,
                children: List.generate(AvatarPresets.colors.length, (index) {
                  final isSelected = selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColorIndex = index),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AvatarPresets.colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AvatarPresets.colors[index]
                                      .withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final currentPlayer = playerProvider.currentPlayer;
                    if (currentPlayer != null) {
                      playerProvider.updatePlayer(
                        avatar: AvatarData(
                          type: AvatarType.face,
                          index: selectedFaceIndex,
                          color: AvatarPresets.colors[selectedColorIndex],
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text('🎮', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('Party Chaos'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: AppSpacing.md),
            Text(
              'A fun party games app to play with friends and family!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Made with Flutter',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
