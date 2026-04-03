import 'dart:math';
import 'package:flutter/material.dart';

class FloatingEmojiReaction extends StatefulWidget {
  final bool show;
  final List<String> emojis;
  final Duration duration;

  const FloatingEmojiReaction({
    super.key,
    this.show = false,
    this.emojis = const ['🔥', '❤️', '😂', '🎉', '👏', '💯'],
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<FloatingEmojiReaction> createState() => _FloatingEmojiReactionState();
}

class _FloatingEmojiReactionState extends State<FloatingEmojiReaction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingEmoji> _activeEmojis = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(FloatingEmojiReaction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _triggerEmojis();
    }
  }

  void _triggerEmojis() {
    _activeEmojis.clear();
    for (int i = 0; i < 8; i++) {
      _activeEmojis.add(_FloatingEmoji(
        emoji: widget.emojis[_random.nextInt(widget.emojis.length)],
        startX: _random.nextDouble() * 0.6 + 0.2,
        delay: _random.nextInt(300),
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            final progress = (_controller.value * 1000 - e.delay) / 1000;
            if (progress <= 0 || progress > 1) {
              return const SizedBox.shrink();
            }

            final y = -progress * e.speed * 300;
            final opacity = (1 - progress).clamp(0.0, 1.0);
            final scale = 0.5 + (progress * 0.5).clamp(0.0, 1.0);

            return Positioned(
              left: MediaQuery.of(context).size.width * e.startX,
              top: y + 100,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Text(
                    e.emoji,
                    style: const TextStyle(fontSize: 32),
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

class RoundTransition extends StatefulWidget {
  final int roundNumber;
  final Widget child;
  final Duration duration;

  const RoundTransition({
    super.key,
    required this.roundNumber,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<RoundTransition> createState() => _RoundTransitionState();
}

class _RoundTransitionState extends State<RoundTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RoundTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roundNumber != oldWidget.roundNumber) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
