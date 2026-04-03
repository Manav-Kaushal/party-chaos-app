import 'package:flutter/material.dart';
import '../models/player.dart';
import '../core/constants/app_theme.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final bool showBorder;
  final bool showGlow;
  final VoidCallback? onTap;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 48,
    this.showBorder = false,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: showBorder || showGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: showBorder
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: player.avatar.color.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              )
            : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                player.avatar.color,
                player.avatar.color.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: player.avatar.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              AvatarPresets.getAvatarEmoji(player.avatar),
              style: TextStyle(fontSize: size * 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class MiniAvatar extends StatelessWidget {
  final Player player;
  final double size;

  const MiniAvatar({
    super.key,
    required this.player,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: player.avatar.color,
        border: Border.all(
          color: AppColors.surface,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          AvatarPresets.getAvatarEmoji(player.avatar),
          style: TextStyle(fontSize: size * 0.4),
        ),
      ),
    );
  }
}

class AvatarGroup extends StatelessWidget {
  final List<Player> players;
  final double avatarSize;
  final int maxDisplay;
  final double overlap;

  const AvatarGroup({
    super.key,
    required this.players,
    this.avatarSize = 40,
    this.maxDisplay = 4,
    this.overlap = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final displayPlayers = players.take(maxDisplay).toList();
    final remaining = players.length - maxDisplay;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (displayPlayers.length - 1) * (avatarSize * overlap),
      child: Stack(
        children: [
          ...displayPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Positioned(
              left: index * (avatarSize * overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: MiniAvatar(player: player, size: avatarSize),
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: displayPlayers.length * (avatarSize * overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(
                    color: AppColors.background,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarSize * 0.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
