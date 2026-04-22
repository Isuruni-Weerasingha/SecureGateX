import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color cyan = Color(0xFF06B6D4);
  static const Color blue = Color(0xFF3B82F6);
  
  // Background colors
  static const Color backgroundDark = Color(0xFF0A0F1F);
  static const Color cardBackground = Color(0xFF1A1F2F);
  
  // Text colors
  static const Color textCyanLight = Color(0xFFB0E5F0);
  static const Color textCyanLighter = Color(0xFFD0F0F8);
  
  // Border colors
  static const Color cardBorder = Color(0xFF2A3F5F);
  
  // Additional colors
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color yellow = Color(0xFFF59E0B);
  
  // Slate colors
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  
  // Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A), // slate-900
      Color(0xFF020617), // slate-950
      Colors.black,
    ],
  );
}

