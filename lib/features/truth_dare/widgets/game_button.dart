import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class GameButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final bool fullWidth;
  final bool outlined;
  final double height;
  final double? width;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    this.gradient,
    this.color,
    this.onTap,
    this.fullWidth = false,
    this.outlined = false,
    this.height = 56,
    this.width,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final buttonColor = widget.color ?? AppColors.primary;
    final gradient = widget.gradient ??
        LinearGradient(
          colors: [buttonColor, buttonColor.withValues(alpha: 0.8)],
        );

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient:
                    widget.outlined ? null : (isEnabled ? gradient : null),
                color: widget.outlined
                    ? Colors.transparent
                    : (isEnabled ? null : AppColors.surfaceLight),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: widget.outlined
                    ? Border.all(
                        color: isEnabled
                            ? buttonColor
                            : buttonColor.withValues(alpha: 0.4),
                        width: 2,
                      )
                    : null,
                boxShadow: isEnabled && !widget.outlined
                    ? [
                        BoxShadow(
                          color: gradient.colors.first
                              .withValues(alpha: _glowAnimation.value),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: isEnabled ? widget.onTap : null,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.outlined
                                ? (isEnabled
                                    ? buttonColor
                                    : buttonColor.withValues(alpha: 0.4))
                                : Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: widget.outlined
                                ? (isEnabled
                                    ? buttonColor
                                    : buttonColor.withValues(alpha: 0.4))
                                : (isEnabled
                                    ? Colors.white
                                    : AppColors.textMuted),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RatingButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int points;
  final VoidCallback? onTap;
  final bool selected;

  const RatingButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.points,
    this.onTap,
    this.selected = false,
  });

  @override
  State<RatingButton> createState() => _RatingButtonState();
}

class _RatingButtonState extends State<RatingButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.selected ? 1.0 : _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: widget.selected
                ? LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.8)],
                  )
                : null,
            color: widget.selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: widget.selected
                  ? Colors.white
                  : widget.color.withValues(alpha: 0.3),
              width: widget.selected ? 2 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
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
                widget.icon,
                color: widget.selected ? Colors.white : widget.color,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.selected ? Colors.white : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '+${widget.points} pts',
                    style: TextStyle(
                      color: widget.selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : widget.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconGameButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool selected;

  const IconGameButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.selected = false,
  });

  @override
  State<IconGameButton> createState() => _IconGameButtonState();
}

class _IconGameButtonState extends State<IconGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: widget.selected
                ? LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: widget.selected
                  ? Colors.white
                  : widget.color.withValues(alpha: 0.3),
              width: widget.selected ? 2 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.selected ? Colors.white : widget.color,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected ? Colors.white : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
