import 'package:flutter/material.dart';

/// ReVuelta brand color palette incorporating both the operational green system
/// and the student campus forest-green design theme ("Usa. Devuelve. Repite.").
class AppColors {
  AppColors._();

  // Primary & Forest greens
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color forestGreen = Color(0xFF1B4D3E);
  static const Color deepTeal = Color(0xFF133B30);
  static const Color darkGreen = Color(0xFF1E8449);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color mintGreen = Color(0xFFE1EFEA);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surfaceWhite = Colors.white;
  static const Color cardBorder = Color(0xFFE8E8E8);
  static const Color surfaceMuted = Color(0xFFF1F5F3);

  // Text
  static const Color textPrimary = Color(0xFF1A2E28);
  static const Color textSecondary = Color(0xFF6B7E77);
  static const Color textHint = Color(0xFFA0B0A8);

  // Semantic
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color warningOrange = Color(0xFFF39C12);
  static const Color successGreen = Color(0xFF27AE60);

  // Status indicators
  static const Color statusAvailable = Color(0xFF27AE60);
  static const Color statusInUse = Color(0xFF2ECC71);
  static const Color statusReturned = Color(0xFF1B4D3E);
  static const Color statusDamaged = Color(0xFFF39C12);
  static const Color statusLost = Color(0xFFE74C3C);
  static const Color statusRetired = Color(0xFF95A5A6);
}
