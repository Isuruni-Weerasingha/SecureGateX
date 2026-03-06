import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final Widget? badge;

  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: color ?? AppColors.cyan, size: size ?? 24);
    
    if (badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -4,
            top: -4,
            child: badge!,
          ),
        ],
      );
    }

    Widget button = IconButton(
      icon: iconWidget,
      onPressed: onPressed,
      tooltip: tooltip,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

