import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class ReactionBar extends StatefulWidget {
  final Function(String)? onReaction;
  final List<String> customEmojis;

  const ReactionBar({
    super.key,
    this.onReaction,
    this.customEmojis = const ['🔥', '❤️', '😂', '🎉', '👏', '💯', '😎', '🤔'],
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerReaction(String emoji) {
    _controller.forward(from: 0);
    widget.onReaction?.call(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.customEmojis.map((emoji) {
          return _ReactionButton(
            emoji: emoji,
            onTap: () => _triggerReaction(emoji),
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class FloatingReactions extends StatefulWidget {
  final bool show;
  final List<String> emojis;

  const FloatingReactions({
    super.key,
    this.show = false,
    this.emojis = const ['🔥', '❤️', '😂', '🎉', '👏', '💯'],
  });

  @override
  State<FloatingReactions> createState() => _FloatingReactionsState();
}

class _FloatingReactionsState extends State<FloatingReactions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingEmoji> _activeEmojis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloatingReactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _triggerEmojis();
    }
  }

  void _triggerEmojis() {
    _activeEmojis.clear();
    for (int i = 0; i < 6; i++) {
      _activeEmojis.add(_FloatingEmoji(
        emoji: widget.emojis[_random.nextInt(widget.emojis.length)],
        startX: _random.nextDouble() * 0.6 + 0.2,
        delay: _random.nextInt(200),
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && _activeEmojis.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _activeEmojis.map((e) {
            final progress = (_controller.value * 2000 - e.delay) / 2000;
            if (progress <= 0 || progress > 1) {
              return const SizedBox.shrink();
            }

            final y = -progress * e.speed * 250;
            final opacity = (1 - progress).clamp(0.0, 1.0);
            final scale = 0.5 + (progress * 0.5).clamp(0.0, 1.0);

            return Positioned(
              left: MediaQuery.of(context).size.width * e.startX,
              top: y + 150,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Text(
                    e.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _FloatingEmoji {
  final String emoji;
  final double startX;
  final int delay;
  final double speed;

  _FloatingEmoji({
    required this.emoji,
    required this.startX,
    required this.delay,
    required this.speed,
  });
}
