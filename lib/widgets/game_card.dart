import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

class GameCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final bool glassEffect;
  final String? emojiIcon;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient,
    this.padding,
    this.glowColor,
    this.glassEffect = false,
    this.emojiIcon,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: widget.glassEffect
                ? null
                : (widget.gradient ?? AppColors.cardGradient),
            color: widget.glassEffect
                ? AppColors.surface.withValues(alpha: 0.7)
                : null,
            border: Border.all(
              color: _getBorderColor(),
              width: widget.glowColor != null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              if (widget.glowColor != null)
                BoxShadow(
                  color: widget.glowColor!.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              BoxShadow(
                color: widget.glowColor ?? AppColors.primary,
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Stack(
                children: [
                  if (widget.emojiIcon != null)
                    Positioned(
                      top: -20,
                      right: -10,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.glowColor ?? AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (widget.glowColor ?? AppColors.primary)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.emojiIcon!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding:
                        widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (widget.glowColor != null) {
      return widget.glowColor!.withValues(alpha: 0.5);
    }
    return Colors.white.withValues(alpha: 0.08);
  }
}

class HighlightedGameCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color highlightColor;
  final String? emojiIcon;

  const HighlightedGameCard({
    super.key,
    required this.child,
    this.onTap,
    this.highlightColor = AppColors.primary,
    this.emojiIcon,
  });

  @override
  State<HighlightedGameCard> createState() => _HighlightedGameCardState();
}

class _HighlightedGameCardState extends State<HighlightedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: AppColors.cardGradient,
            border: Border.all(
              color: widget.highlightColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.highlightColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: widget.highlightColor.withValues(alpha: 0.2),
                blurRadius: 25,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Stack(
                children: [
                  if (widget.emojiIcon != null)
                    Positioned(
                      top: -20,
                      right: -10,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.highlightColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  widget.highlightColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.emojiIcon!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
