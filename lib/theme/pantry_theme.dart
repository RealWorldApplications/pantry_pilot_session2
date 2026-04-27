import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// ─── Brand-Architect Tokens ──────────────────────────────────────────────────
const Color kCharcoal = Color(0xFF121212);
const Color kEmerald = Color(0xFF50FFAB);
const Color kPearl = Color(0xFFF5F5F5);
const double kRadius = 24.0;
const double kGlassOpacity = 0.2;

// ─── Supported camera platforms (camera package limitation) ─────────────────
bool get isCameraSupported {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.windows;
}

class PantryTheme {
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: kCharcoal,
    colorScheme: const ColorScheme.dark(primary: kEmerald, surface: kCharcoal),
    fontFamily: 'Roboto',
  );
}
