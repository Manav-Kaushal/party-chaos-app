import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/player.dart';
import '../../models/game_session.dart';
import '../lobby/game_setup_screen.dart';
import '../../widgets/player_avatar.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildActionButtons(context),
                const SizedBox(height: AppSpacing.xxl),
                _buildQuickPlay(context),
                const SizedBox(height: AppSpacing.xl),
                _buildGamesSection(context),
                const SizedBox(height: AppSpacing.xl),
                _buildLeaderboardPreview(context),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Ready for Chaos?',
                      style: TextStyle(
                        fontSize: 32,
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
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Chaos Level: Maximum',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, _) {
                final player = playerProvider.currentPlayer;
                if (player == null) return const SizedBox.shrink();
                return PlayerAvatar(
                  player: player,
                  size: 64,
                  showGlow: true,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(2);
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        NeonButton(
          label: 'Quick Play',
          icon: Icons.bolt_rounded,
          fullWidth: true,
          height: 64,
          onPressed: () => _showGameModeDialog(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SecondaryNeonButton(
                label: 'Join Friends',
                icon: Icons.group_add_rounded,
                onPressed: () => _navigateToSetup(context, GameMode.online),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AccentNeonButton(
                label: 'Random Game',
                icon: Icons.shuffle_rounded,
                onPressed: () {
                  final randomType = GameType.values[
                      DateTime.now().millisecondsSinceEpoch %
                          GameType.values.length];
                  _navigateToSetup(context, GameMode.local,
                      gameType: randomType);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPlay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Play',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Jump right into the chaos!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showGameModeDialog(context,
                  preselectedGame: _getRandomGameType()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded),
                  SizedBox(width: 8),
                  Text(
                    'Start Playing',
                    style: TextStyle(
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

  void _showGameModeDialog(BuildContext context, {GameType? preselectedGame}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
                Navigator.pop(sheetContext);
                _navigateToSetup(context, GameMode.local,
                    gameType: preselectedGame);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _GameModeOption(
              icon: Icons.wifi,
              title: 'Online Multiplayer',
              subtitle: 'Play with friends remotely',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(sheetContext);
                _navigateToSetup(context, GameMode.online,
                    gameType: preselectedGame);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _navigateToSetup(BuildContext context, GameMode mode,
      {GameType? gameType}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSetupScreen(
          mode: mode,
          onGameSelected: (type) {},
          preselectedGame: gameType,
        ),
      ),
    );
  }

  GameType _getRandomGameType() {
    return GameType.values[DateTime.now().millisecond % GameType.values.length];
  }

  Widget _buildGamesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.casino_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Party Games',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.95,
          children: GameType.values.map((type) {
            return _GameCard(
              type: type,
              onTap: () => _showGameModeDialog(context, preselectedGame: type),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        final leaderboard = playerProvider.leaderboard;
        return NeonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (leaderboard.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: const Column(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 48)),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'No scores yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Play a game to get on the board!',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(leaderboard.take(3).length, (index) {
                  final player = leaderboard.take(3).toList()[index];
                  final isTop = index == 0;
                  return _LeaderboardItem(
                    player: player,
                    rank: index + 1,
                    isTop: isTop,
                  );
                }),
            ],
          ),
        );
      },
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

class _GameCard extends StatelessWidget {
  final GameType type;
  final VoidCallback onTap;

  const _GameCard({required this.type, required this.onTap});

  Color get _cardColor {
    switch (type) {
      case GameType.truthOrDare:
        return AppColors.success;
      case GameType.wouldYouRather:
        return AppColors.secondary;
      case GameType.neverHaveIEver:
        return AppColors.primary;
      case GameType.quickFireTrivia:
        return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      onTap: onTap,
      glowColor: _cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _cardColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              type.icon,
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            type.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final Player player;
  final int rank;
  final bool isTop;

  const _LeaderboardItem({
    required this.player,
    required this.rank,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isTop
            ? AppColors.tertiary.withValues(alpha: 0.1)
            : AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isTop
            ? Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isTop ? AppColors.tertiary : AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isTop ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          MiniAvatar(player: player, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: isTop ? AppColors.secondaryGradient : null,
              color: isTop ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${player.totalScore}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTop ? Colors.white : AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
