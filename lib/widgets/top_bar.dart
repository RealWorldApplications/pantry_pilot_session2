import 'package:flutter/material.dart';
import '../theme/pantry_theme.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, safeTop + 16, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kEmerald,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded, color: kCharcoal, size: 20),
          ),
          const SizedBox(width: 12),
          // App name
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PANTRY PILOT',
                style: TextStyle(
                  color: kPearl,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                'Vision Scanner',
                style: TextStyle(
                  color: kEmerald,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 48,
          ), // Maintain spacing where icon was if needed, or just nothing.
        ],
      ),
    );
  }
}
