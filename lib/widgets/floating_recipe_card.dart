import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../services/gemini_service.dart';

// ─── Brand-Architect Tokens (mirrored from main.dart) ────────────────────────
const Color _kCharcoal = Color(0xFF121212);
const Color _kEmerald = Color(0xFF50FFAB);
const Color _kPearl = Color(0xFFF5F5F5);
const double _kRadius = 24.0;

// ─── Floating Recipe Card ─────────────────────────────────────────────────────
// vision-orchestrator rule 2: when Gemini returns a recipe, map it to this widget.
class FloatingRecipeCard extends StatefulWidget {
  const FloatingRecipeCard({super.key, required this.result});

  final IngredientResult result;

  @override
  State<FloatingRecipeCard> createState() => _FloatingRecipeCardState();
}

class _FloatingRecipeCardState extends State<FloatingRecipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<Offset> _driftAnimation;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  Offset _tiltOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _driftAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.015), // Subtle upward drift
        ).animate(
          CurvedAnimation(
            parent: _floatController,
            curve: Curves.easeInOutSine,
          ),
        );

    // Listen to accelerometer for "gravity" tilt effect
    if (!kIsWeb) {
      _accelSubscription = accelerometerEventStream().listen((
        AccelerometerEvent event,
      ) {
        if (mounted) {
          setState(() {
            // Amplified mapping for more visible movement
            _tiltOffset = Offset(
              (-event.x * 8.0).clamp(-60.0, 60.0),
              (event.y * 8.0).clamp(-40.0, 40.0),
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _floatController.stop();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return MouseRegion(
          onHover: (event) {
            // Desktop Gravity: Map mouse position to virtual tilt
            final size = MediaQuery.sizeOf(context);
            final centerX = size.width / 2;
            final centerY = size.height / 2;

            // Calculate normalized distance from center (-1.0 to 1.0)
            final relX = (event.position.dx - centerX) / centerX;
            final relY = (event.position.dy - centerY) / centerY;

            setState(() {
              // On desktop, we use mouse position to simulate tilt
              // This ensures the "Antigravity" feel works on laptops too
              _tiltOffset = Offset(relX * 40, relY * 30);
            });
          },
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              // Highly visible weightless drift + tilt gravity (sensor or mouse)
              final driftY = _driftAnimation.value.dy * 2400;

              final combinedOffset = Offset(
                _tiltOffset.dx,
                _tiltOffset.dy + driftY,
              );

              // Add a slight rotation (leaning) based on horizontal tilt
              final tiltRotation = (-_tiltOffset.dx / 600).clamp(-0.05, 0.05);

              return Transform(
                transform: Matrix4.translationValues(
                  combinedOffset.dx,
                  combinedOffset.dy,
                  0,
                )..rotateZ(tiltRotation),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_kRadius),
                child: _maybeBackdropFilter(
                  child: Container(
                    decoration: BoxDecoration(
                      // brand-architect: Opacity 0.2
                      color: kIsWeb
                          ? _kCharcoal.withValues(
                              alpha: 0.85,
                            ) // Darker for web readability
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(_kRadius),
                      border: Border.all(
                        color: _kEmerald.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                      children: [
                        // ── Drag handle ──────────────────────────────────────────
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _kPearl.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        ),
                        // ── Status badge ─────────────────────────────────────────
                        Row(
                          children: [
                            _StatusBadge(
                              investigationMode:
                                  widget.result.investigationMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Item name ────────────────────────────────────────────
                        Text(
                          widget.result.item,
                          style: const TextStyle(
                            color: _kPearl,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Emerald divider ──────────────────────────────────────
                        Container(
                          height: 2.5,
                          width: 52,
                          decoration: BoxDecoration(
                            color: _kEmerald,
                            borderRadius: BorderRadius.circular(1.25),
                            boxShadow: [
                              BoxShadow(
                                color: _kEmerald.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Recipe section ───────────────────────────────────────
                        const _SectionHeader(label: 'Quick Recipe'),
                        const SizedBox(height: 16),
                        ...widget.result.recipe.asMap().entries.map(
                              (e) => _RecipeStep(step: e.key + 1, text: e.value),
                            ),
                        const SizedBox(height: 28),

                        // ── Fun fact card ────────────────────────────────────────
                        if (widget.result.funFact.isNotEmpty)
                          _FunFactCard(text: widget.result.funFact),
                        const SizedBox(height: 32),

                        // ── Dismiss button ───────────────────────────────────────
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kEmerald,
                              foregroundColor: _kCharcoal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_kRadius),
                              ),
                              elevation: 8,
                              shadowColor: _kEmerald.withValues(alpha: 0.3),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child: const Text('READY FOR ANOTHER?'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gracefully degrade glassmorphism on Web to avoid rendering engine crashes.
  Widget _maybeBackdropFilter({required Widget child}) {
    if (kIsWeb) return child;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
      child: child,
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.investigationMode});

  final bool investigationMode;

  @override
  Widget build(BuildContext context) {
    final label = investigationMode
        ? '🔍 ACTIVE INVESTIGATION'
        : '✅ IDENTIFIED';
    final bg = investigationMode
        ? _kEmerald.withValues(alpha: 0.12)
        : _kEmerald.withValues(alpha: 0.15);
    final border = investigationMode
        ? _kEmerald.withValues(alpha: 0.35)
        : _kEmerald.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kEmerald,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _kEmerald,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _kPearl,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Recipe Step ──────────────────────────────────────────────────────────────
class _RecipeStep extends StatelessWidget {
  const _RecipeStep({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number badge — brand-architect: radius 24.0 (using 8 for small badge)
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kEmerald,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$step',
              style: const TextStyle(
                color: _kCharcoal,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                text,
                style: TextStyle(
                  color: _kPearl.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fun Fact Card ────────────────────────────────────────────────────────────
class _FunFactCard extends StatelessWidget {
  const _FunFactCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kEmerald.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kEmerald.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FUN FACT',
                  style: TextStyle(
                    color: _kEmerald,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: _kPearl.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
