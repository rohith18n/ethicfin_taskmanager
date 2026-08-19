import 'package:flutter/material.dart';

class AppColors {
  // WhatsApp / Meta Brand Palette
  static const Color primary = Color(0xFF00A884); // WhatsApp Emerald Green
  static const Color primaryLight = Color(0xFF25D366); // Bright Green
  static const Color primaryDark = Color(0xFF008069); // Dark Teal/Forest Green
  static const Color accent = Color(0xFF34B7F1); // WhatsApp Blue double checkmark

  // Dark Theme (WhatsApp Dark Mode)
  static const Color darkBackground = Color(0xFF0C1014); // Pure dark background
  static const Color darkSurface = Color(0xFF111B21); // WhatsApp Dark Surface
  static const Color darkCard = Color(0xFF111B21);
  static const Color darkInputFill = Color(0xFF202428); // Search bar pill background
  static const Color darkDivider = Color(0xFF1F2428);
  static const Color darkTextPrimary = Color(0xFFE9EDEF); // Crisp light text
  static const Color darkTextSecondary = Color(0xFF8696A0); // Muted slate-grey text

  // Dark Theme Filter Chip Colors
  static const Color chipSelectedBg = Color(0xFF0C3B2E); // Dark Green Pill
  static const Color chipSelectedText = Color(0xFF25D366); // Bright Green text
  static const Color chipUnselectedBg = Color(0xFF202428); // Dark Grey Pill
  static const Color chipUnselectedText = Color(0xFF8696A0); // Grey text

  // Light Theme (WhatsApp Light Mode)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightInputFill = Color(0xFFF0F2F5); // Light grey pill
  static const Color lightDivider = Color(0xFFE9EDEF);
  static const Color lightTextPrimary = Color(0xFF111B21); // Deep black text
  static const Color lightTextSecondary = Color(0xFF667781); // Slate grey

  // Light Theme Filter Chip Colors (From Reference Image)
  static const Color lightChipSelectedBg = Color(0xFFD9FDD3); // Soft pastel mint green
  static const Color lightChipSelectedText = Color(0xFF008069); // Dark Forest green text
  static const Color lightChipSelectedBorder = Color(0xFFBCECC0);
  static const Color lightChipUnselectedBg = Color(0xFFFFFFFF); // White pill
  static const Color lightChipUnselectedText = Color(0xFF54656F); // Dark slate text
  static const Color lightChipUnselectedBorder = Color(0xFFD1D7DB); // Subtle grey border

  // Priority Colors
  static const Color priorityLow = Color(0xFF25D366); // Emerald Green
  static const Color priorityLowBg = Color(0xFF0C3B2E);
  static const Color priorityLowLightBg = Color(0xFFD9FDD3);

  static const Color priorityMedium = Color(0xFF34B7F1); // Blue
  static const Color priorityMediumBg = Color(0xFF0B3349);
  static const Color priorityMediumLightBg = Color(0xFFD8F1FE);

  static const Color priorityHigh = Color(0xFFFFB020); // Amber
  static const Color priorityHighBg = Color(0xFF4A3408);
  static const Color priorityHighLightBg = Color(0xFFFEF3C7);

  static const Color priorityUrgent = Color(0xFFF15C6D); // Rose/Red
  static const Color priorityUrgentBg = Color(0xFF4C151B);
  static const Color priorityUrgentLightBg = Color(0xFFFDE8E8);

  // Status & Sync Colors
  static const Color success = Color(0xFF25D366);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFF15C6D);
  static const Color synced = Color(0xFF25D366);
  static const Color syncing = Color(0xFF34B7F1);
  static const Color unsynced = Color(0xFFFFB020);
  static const Color offline = Color(0xFF8696A0);
}
