import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1F1F1F);
  static const Color secondary = Color(0xFFFFD700);
  static const Color accent = Color(0xFFBFAE9F);
  static const Color background = Color(0xFF121212);
  static const Color text = Color(0xFFF5F5F5);

  // Additional Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color darkGrey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFF555555);
  static const Color transparent = Colors.transparent;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Opacity Colors
  static const Color shadow = Color(0x1AFFFFFF);
  static const Color overlay = Color(0x4D000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFBFAE9F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
