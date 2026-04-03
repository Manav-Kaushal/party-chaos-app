import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _defaultColors = [
    AppColors.background,
    Color(0xFF1A1A2E),
    AppColors.surface,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
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
        final colors = widget.colors ?? _defaultColors;
        final t = _controller.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(colors[0], colors[1], t) ?? colors[0],
                Color.lerp(colors[1], colors[2], t) ?? colors[1],
                Color.lerp(colors[2], colors[0], t) ?? colors[2],
              ].toList(),
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class NeonGradientBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const NeonGradientBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.verticalGradient,
        ),
        child: child,
      );
    }

    return AnimatedGradientBackground(
      colors: const [
        AppColors.background,
        Color(0xFF16162A),
        AppColors.surface,
      ],
      child: child,
    );
  }
}
