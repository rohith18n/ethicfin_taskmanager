import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF06B6D4); // Cyan 500
  static const Color accent = Color(0xFFEC4899); // Pink 500

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightDivider = Color(0xFFE2E8F0); // Slate 200
  static const Color lightInputFill = Color(0xFFF1F5F9); // Slate 100

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkDivider = Color(0xFF334155); // Slate 700
  static const Color darkInputFill = Color(0xFF334155); // Slate 700

  // Task Priority Colors
  static const Color priorityLow = Color(0xFF10B981); // Emerald 500
  static const Color priorityLowBg = Color(0xFFD1FAE5);
  static const Color priorityMedium = Color(0xFF3B82F6); // Blue 500
  static const Color priorityMediumBg = Color(0xFFDBEAFE);
  static const Color priorityHigh = Color(0xFFF59E0B); // Amber 500
  static const Color priorityHighBg = Color(0xFFFEF3C7);
  static const Color priorityUrgent = Color(0xFFEF4444); // Red 500
  static const Color priorityUrgentBg = Color(0xFFFEE2E2);

  // Status & Sync Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color synced = Color(0xFF10B981);
  static const Color syncing = Color(0xFF3B82F6);
  static const Color unsynced = Color(0xFFF59E0B);
  static const Color offline = Color(0xFF64748B);
}
