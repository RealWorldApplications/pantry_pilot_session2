import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../theme/pantry_theme.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({
    super.key,
    required this.isScanning,
    required this.onPressed,
    required this.onLongPress,
  });

  final bool isScanning;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Tooltip(
        message: 'Long-press to bypass camera and test',
        preferBelow: false,
        verticalOffset: 36,
        child: ElevatedButton(
          onPressed: isScanning ? null : onPressed,
          onLongPress: isScanning ? null : onLongPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: kEmerald,
            disabledBackgroundColor: kEmerald.withValues(alpha: 0.45),
            foregroundColor: kCharcoal,
            disabledForegroundColor: kCharcoal.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadius),
            ),
            elevation: 0,
            shadowColor: kEmerald.withValues(alpha: 0.4),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isScanning
                ? const Row(
                    key: ValueKey('scanning'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(kCharcoal),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Scanning…',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    key: ValueKey('ready'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Scan Ingredient',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.lensDirection});

  final CameraLensDirection lensDirection;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: kEmerald,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE  ·  ${lensDirection.name.toUpperCase()}',
          style: TextStyle(
            color: kPearl.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
