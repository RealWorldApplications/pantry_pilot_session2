import 'package:flutter/material.dart';
import '../theme/pantry_theme.dart';

class ViewfinderFrame extends StatelessWidget {
  const ViewfinderFrame({
    super.key,
    required this.size,
    required this.isScanning,
  });

  final Size size;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    const bracketLen = 28.0;
    const bracketThick = 3.0;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Scanning shimmer line
          if (isScanning) ScanLine(frameHeight: size.height),

          // Four corner brackets
          Positioned(
            top: 0,
            left: 0,
            child: CornerBracket(
              corner: Corner.topLeft,
              len: bracketLen,
              thick: bracketThick,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CornerBracket(
              corner: Corner.topRight,
              len: bracketLen,
              thick: bracketThick,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: CornerBracket(
              corner: Corner.bottomLeft,
              len: bracketLen,
              thick: bracketThick,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CornerBracket(
              corner: Corner.bottomRight,
              len: bracketLen,
              thick: bracketThick,
            ),
          ),
        ],
      ),
    );
  }
}

class ScanLine extends StatefulWidget {
  const ScanLine({super.key, required this.frameHeight});
  final double frameHeight;

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * (widget.frameHeight - 2),
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kEmerald.withValues(alpha: 0),
                kEmerald,
                kEmerald.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class CornerBracket extends StatelessWidget {
  const CornerBracket({
    super.key,
    required this.corner,
    required this.len,
    required this.thick,
  });

  final Corner corner;
  final double len;
  final double thick;

  @override
  Widget build(BuildContext context) {
    final isTop = corner == Corner.topLeft || corner == Corner.topRight;
    final isLeft = corner == Corner.topLeft || corner == Corner.bottomLeft;

    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: BracketPainter(
          color: kEmerald,
          thickness: thick,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }
}

class BracketPainter extends CustomPainter {
  BracketPainter({
    required this.color,
    required this.thickness,
    required this.isTop,
    required this.isLeft,
  });

  final Color color;
  final double thickness;
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Horizontal arm
    final hStart = isLeft ? Offset(0, isTop ? 0 : h) : Offset(w, isTop ? 0 : h);
    final hEnd = isLeft ? Offset(w, isTop ? 0 : h) : Offset(0, isTop ? 0 : h);
    canvas.drawLine(hStart, hEnd, paint);

    // Vertical arm
    final vStart = isLeft ? Offset(0, isTop ? 0 : h) : Offset(w, isTop ? 0 : h);
    final vEnd = isLeft ? Offset(0, isTop ? h : 0) : Offset(w, isTop ? h : 0);
    canvas.drawLine(vStart, vEnd, paint);
  }

  @override
  bool shouldRepaint(BracketPainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.isTop != isTop ||
      old.isLeft != isLeft;
}
