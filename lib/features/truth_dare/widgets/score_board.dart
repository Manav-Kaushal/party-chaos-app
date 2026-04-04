import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/player.dart';

class ScoreBoard extends StatelessWidget {
  final List<Player> players;
  final bool expanded;
  final VoidCallback? onTap;

  const ScoreBoard({
    super.key,
    required this.players,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.leaderboard_rounded,
                  color: AppColors.tertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (!expanded)
                  Text(
                    'Tap to expand',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...sortedPlayers.take(expanded ? players.length : 3).map((player) {
              final index = sortedPlayers.indexOf(player);
              final isTop = index == 0;
              return _ScoreRow(
                player: player,
                rank: index + 1,
                isTop: isTop,
              );
            }),
            if (expanded && sortedPlayers.length > 3) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '+${sortedPlayers.length - 3} more players',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final Player player;
  final int rank;
  final bool isTop;

  const _ScoreRow({
    required this.player,
    required this.rank,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = AppColors.textSecondary;
      rankIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTop
                  ? rankColor.withValues(alpha: 0.2)
                  : AppColors.surfaceLight,
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, size: 16, color: rankColor)
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.avatar.color,
            ),
            child: Center(
              child: Text(
                AvatarPresets.faces[player.avatar.index],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              gradient: isTop ? AppColors.primaryGradient : null,
              color: isTop ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${player.totalScore}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTop ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreChip extends StatelessWidget {
  final int score;
  final Color color;
  final bool small;

  const ScoreChip({
    super.key,
    required this.score,
    this.color = AppColors.primary,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppSpacing.sm : AppSpacing.md,
        vertical: small ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: small ? 12 : 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+$score',
            style: TextStyle(
              color: Colors.white,
              fontSize: small ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
