import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GradientGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final Color? glowColor;

  const GradientGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradientColors,
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [AppColors.cyan, AppColors.blue];
    
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.map((c) => c.withOpacity(0.2)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? colors.first).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return content;
  }
}

