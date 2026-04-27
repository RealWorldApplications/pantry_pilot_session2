import 'package:flutter/material.dart';
import '../theme/pantry_theme.dart';
import 'common_widgets.dart';

class CameraLoadingView extends StatelessWidget {
  const CameraLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kEmerald),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Initializing Camera…',
              style: TextStyle(
                color: kPearl.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantry Pilot Vision',
              style: TextStyle(
                color: kEmerald,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraErrorView extends StatelessWidget {
  const CameraErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.onBypass,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onBypass;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, color: kEmerald, size: 48),
            const SizedBox(height: 24),
            const Text(
              'Camera Unavailable',
              style: TextStyle(
                color: kPearl,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPearl.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            EmeraldButton(label: 'Try Again', onPressed: onRetry),
            if (onBypass != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onBypass,
                child: const Text(
                  'Bypass to Test Mode',
                  style: TextStyle(color: kEmerald, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CameraUnsupportedView extends StatelessWidget {
  const CameraUnsupportedView({
    super.key,
    required this.message,
    this.onBypass,
  });

  final String message;
  final VoidCallback? onBypass;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.laptop_rounded, color: kEmerald, size: 48),
            const SizedBox(height: 24),
            const Text(
              'Desktop Dev Mode',
              style: TextStyle(
                color: kPearl,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPearl.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (onBypass != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: onBypass,
                child: const Text(
                  'Bypass to Test Mode',
                  style: TextStyle(color: kEmerald, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
