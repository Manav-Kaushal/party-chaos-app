import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final bool pulse;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulsingWidget({
    super.key,
    required this.child,
    this.pulse = true,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.9,
    this.maxScale = 1.0,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.pulse ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class AnimatedCountdown extends StatelessWidget {
  final int seconds;
  final TextStyle? style;
  final Color? pulseColor;

  const AnimatedCountdown({
    super.key,
    required this.seconds,
    this.style,
    this.pulseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = seconds <= 5;
    final color =
        pulseColor ?? (isUrgent ? AppColors.error : AppColors.tertiary);

    return PulsingWidget(
      pulse: true,
      duration: Duration(milliseconds: isUrgent ? 500 : 1000),
      minScale: isUrgent ? 0.85 : 0.95,
      maxScale: 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isUrgent
                ? AppColors.error.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isUrgent
              ? [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              '${seconds}s',
              style: (style ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
