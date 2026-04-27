import 'package:flutter/material.dart';
import '../theme/pantry_theme.dart';

/// Glassmorphic circular icon button.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: kGlassOpacity),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: kEmerald.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: kPearl, size: 20),
        ),
      ),
    );
  }
}

/// Glassmorphic card — blur 15.0, opacity 0.2, radius 24.0 (brand-architect).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(kRadius);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: kGlassOpacity),
          borderRadius: radius,
          border: Border.all(color: kEmerald.withValues(alpha: 0.25), width: 1),
        ),
        child: child,
      ),
    );
  }
}

/// Neon Emerald CTA button — radius 24.0 (brand-architect).
class EmeraldButton extends StatelessWidget {
  const EmeraldButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kEmerald,
          foregroundColor: kCharcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}
