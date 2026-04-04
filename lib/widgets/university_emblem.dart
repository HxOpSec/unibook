import 'dart:math' as math;

import 'package:flutter/material.dart';

class UniversityEmblem extends StatelessWidget {
  const UniversityEmblem({
    super.key,
    this.size = 112,
    this.textSize = 18,
  });

  final double size;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _UniversityEmblemPainter(textSize: textSize),
    );
  }
}

class _UniversityEmblemPainter extends CustomPainter {
  const _UniversityEmblemPainter({required this.textSize});

  final double textSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final fillPaint = Paint()
      ..color = const Color(0x26FFD700)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final innerStrokePaint = Paint()
      ..color = const Color(0xB3FFD700)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius - 2, strokePaint);
    canvas.drawCircle(center, radius - 10, innerStrokePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ТГФЭУ',
        style: TextStyle(
          color: const Color(0xFFFFD700),
          fontWeight: FontWeight.w900,
          fontSize: textSize,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _UniversityEmblemPainter oldDelegate) {
    return oldDelegate.textSize != textSize;
  }
}
