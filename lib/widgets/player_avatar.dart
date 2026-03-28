import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;
  final bool showBorder;

  const PlayerAvatar({
    super.key,
    required this.player,
    this.size = 48,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: player.avatar.color,
                width: 3,
              ),
            )
          : null,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: player.avatar.color,
        child: Text(
          AvatarPresets.getAvatarEmoji(player.avatar),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
