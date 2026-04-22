import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BackButtonCustom extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonCustom({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: AppColors.cyan,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

