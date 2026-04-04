import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final bool isActive;
  final bool showScore;
  final VoidCallback? onTap;
  final double size;

  const PlayerCard({
    super.key,
    required this.player,
    this.isActive = false,
    this.showScore = false,
    this.onTap,
    this.size = 80,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = widget.player.avatar.color;
    final avatarFace = widget.player.avatar.index;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      avatarColor,
                      avatarColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: avatarColor.withValues(
                                alpha: _glowAnimation.value),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: avatarColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.2),
                      width: widget.isActive ? 3 : 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AvatarPresets.faces[avatarFace],
                      style: TextStyle(fontSize: widget.size * 0.45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.player.name,
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight:
                      widget.isActive ? FontWeight.bold : FontWeight.w500,
                  color:
                      widget.isActive ? Colors.white : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.showScore) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        widget.isActive ? AppColors.primaryGradient : null,
                    color: widget.isActive ? null : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${widget.player.totalScore}',
                    style: TextStyle(
                      fontSize: widget.size * 0.12,
                      fontWeight: FontWeight.bold,
                      color: widget.isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class MiniPlayerCard extends StatelessWidget {
  final Player player;
  final bool isActive;
  final double size;

  const MiniPlayerCard({
    super.key,
    required this.player,
    this.isActive = false,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = player.avatar.color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColor,
        border: Border.all(
          color: isActive ? Colors.white : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: avatarColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          AvatarPresets.faces[player.avatar.index],
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }
}
