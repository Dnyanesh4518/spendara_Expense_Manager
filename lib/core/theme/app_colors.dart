import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFFEEEDFE);

  // Semantic
  static const income = Color(0xFF1D9E75);
  static const incomeLight = Color(0xFFE1F5EE);
  static const expense = Color(0xFFD85A30);
  static const expenseLight = Color(0xFFFAECE7);
  static const warning = Color(0xFFBA7517);
  static const warningLight = Color(0xFFFAEEDA);

  // Neutrals — light mode
  static const background = Color(0xFFF8F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1EFE8);
  static const border = Color(0xFFE0DED8);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B6B80);
  static const textHint = Color(0xFFAEAEB8);

  // Neutrals — dark mode
  static const backgroundDark = Color(0xFF0F0F1A);
  static const surfaceDark = Color(0xFF1A1A2E);
  static const surfaceAltDark = Color(0xFF252538);
  static const borderDark = Color(0xFF2E2E45);
  static const textPrimaryDark = Color(0xFFF0EFF8);
  static const textSecondaryDark = Color(0xFF9898B0);

  // Category colors (used in charts)
  static const categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFF1D9E75),
    Color(0xFFD85A30),
    Color(0xFFBA7517),
    Color(0xFF533AB7),
    Color(0xFF0F6E56),
  ];
}
