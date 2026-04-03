import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final double height;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled ? (gradient ?? AppColors.primaryGradient) : null,
        color: isEnabled ? null : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (gradient?.colors.first ?? AppColors.primary)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isEnabled ? Colors.white : AppColors.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class SecondaryNeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const SecondaryNeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeonButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      gradient: AppColors.secondaryGradient,
    );
  }
}

class AccentNeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AccentNeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeonButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      gradient: const LinearGradient(
        colors: [AppColors.accent, Color(0xFF00FFE5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

class OutlinedNeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  const OutlinedNeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.icon,
    this.fullWidth = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.primary;
    final isEnabled = onPressed != null;

    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isEnabled ? color : color.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: isEnabled ? color : color.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? color : color.withValues(alpha: 0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
