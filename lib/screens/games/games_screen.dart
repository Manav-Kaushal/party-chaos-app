import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../models/game_session.dart';
import '../../widgets/game_card.dart';
import '../../components/animated_gradient_background.dart';
import '../lobby/game_setup_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  Color _getGameColor(GameType type) {
    switch (type) {
      case GameType.truthOrDare:
        return AppColors.success;
      case GameType.wouldYouRather:
        return AppColors.secondary;
      case GameType.neverHaveIEver:
        return AppColors.primary;
      case GameType.quickFireTrivia:
        return AppColors.tertiary;
      case GameType.oddOneOut:
        return AppColors.tertiary;
    }
  }

  String _getEmojiIcon(GameType type) {
    switch (type) {
      case GameType.truthOrDare:
        return '🎯';
      case GameType.wouldYouRather:
        return '🤔';
      case GameType.neverHaveIEver:
        return '🙈';
      case GameType.quickFireTrivia:
        return '🧠';
      case GameType.oddOneOut:
        return '🔍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeonGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Party Games'),
        ),
        body: Stack(
          children: [
            _buildBackgroundBlur(),
            _buildPageView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundBlur() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: AppColors.surface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(BuildContext context) {
    final games = GameType.values;
    final pageController = PageController(viewportFraction: 0.85);

    return PageView(
      controller: pageController,
      children: games.map((type) {
        final color = _getGameColor(type);
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xl,
          ),
          child: _SwipeableGameCard(
            type: type,
            color: color,
            emojiIcon: _getEmojiIcon(type),
          ),
        );
      }).toList(),
    );
  }
}

class _SwipeableGameCard extends StatelessWidget {
  final GameType type;
  final Color color;
  final String emojiIcon;

  const _SwipeableGameCard({
    required this.type,
    required this.color,
    required this.emojiIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      glowColor: color,
      onTap: () => _showGameModeSheet(context),
      emojiIcon: emojiIcon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                type.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              type.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            type.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.people_outline,
                label: '4+ players',
                color: color,
              ),
              const SizedBox(width: AppSpacing.md),
              _InfoChip(
                icon: Icons.timer_outlined,
                label: '15 min',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: () => _showGameModeSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Play Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            const Text(
              'Choose Game Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _GameModeOption(
              icon: Icons.phone_android,
              title: 'Local Multiplayer',
              subtitle: 'Play together on one device',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameSetupScreen(
                      mode: GameMode.local,
                      onGameSelected: (gameType) {},
                      preselectedGame: type,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _GameModeOption(
              icon: Icons.wifi,
              title: 'Online Multiplayer',
              subtitle: 'Play with friends remotely',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameSetupScreen(
                      mode: GameMode.online,
                      onGameSelected: (gameType) {},
                      preselectedGame: type,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _GameModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _GameModeOption({
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
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
