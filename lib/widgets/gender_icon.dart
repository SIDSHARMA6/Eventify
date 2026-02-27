import 'package:flutter/material.dart';

/// Custom gender icon widget with male/female symbols
class GenderIcon extends StatelessWidget {
  final bool isMale;
  final double size;
  final Color? color;

  const GenderIcon({
    super.key,
    required this.isMale,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Exact colors from client image
    final iconColor =
        color ?? (isMale ? const Color(0xFF00BFFF) : const Color(0xFFE91E63));

    return CustomPaint(
      size: Size(size, size),
      painter: isMale
          ? _MaleIconPainter(color: iconColor)
          : _FemaleIconPainter(color: iconColor),
    );
  }
}

/// Male symbol painter (♂)
class _MaleIconPainter extends CustomPainter {
  final Color color;

  _MaleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.4, size.height * 0.6);
    final radius = size.width * 0.25;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw arrow
    final arrowStart = Offset(size.width * 0.55, size.height * 0.45);
    final arrowEnd = Offset(size.width * 0.85, size.height * 0.15);

    // Arrow line
    canvas.drawLine(arrowStart, arrowEnd, paint);

    // Arrow head - horizontal line
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.65, size.height * 0.15),
      paint,
    );

    // Arrow head - vertical line
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.35),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Female symbol painter (♀)
class _FemaleIconPainter extends CustomPainter {
  final Color color;

  _FemaleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.5, size.height * 0.35);
    final radius = size.width * 0.25;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw vertical line (cross stem)
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.9),
      paint,
    );

    // Draw horizontal line (cross bar)
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.75),
      Offset(size.width * 0.7, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
