import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

class TgfeuLogo extends StatelessWidget {
  const TgfeuLogo({super.key, this.size = 112, this.textSize = 18, this.showStar = true});

  final double size;
  final double textSize;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TgfeuLogoPainter(textSize: textSize, showStar: showStar),
    );
  }
}

class UniversityEmblem extends TgfeuLogo {
  const UniversityEmblem({super.key, super.size, super.textSize, super.showStar});
}

class _TgfeuLogoPainter extends CustomPainter {
  const _TgfeuLogoPainter({required this.textSize, required this.showStar});

  final double textSize;
  final bool showStar;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.gold.withValues(alpha: 0.2),
    );

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = AppColors.gold
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      center,
      radius - 8,
      Paint()..color = AppColors.primaryDark,
    );

    if (showStar) {
      final starPainter = TextPainter(
        text: TextSpan(
          text: '✦',
          style: TextStyle(color: AppColors.gold, fontSize: textSize * 0.52),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      starPainter.paint(canvas, Offset(center.dx - starPainter.width / 2, center.dy - radius + 6));
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ТГФЭУ',
        style: TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w900,
          fontSize: textSize,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _TgfeuLogoPainter oldDelegate) {
    return textSize != oldDelegate.textSize || showStar != oldDelegate.showStar;
  }
}
