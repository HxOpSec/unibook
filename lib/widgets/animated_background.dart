import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstColor = isDark ? AppColors.primaryDark : AppColors.lightAccent;
    final secondColor = isDark ? AppColors.darkAccentDeep : AppColors.primaryLight;
    final thirdColor = isDark ? AppColors.lightAccent : AppColors.primary;

    return Stack(
      children: [
        _buildCircle(
          controller: _controller1,
          begin: const Offset(-40, -20),
          end: const Offset(10, 35),
          size: 300,
          color: firstColor.withOpacity(isDark ? 0.3 : 0.18),
        ),
        _buildCircle(
          controller: _controller2,
          begin: const Offset(220, 520),
          end: const Offset(160, 450),
          size: 350,
          color: secondColor.withOpacity(isDark ? 0.3 : 0.2),
        ),
        _buildCircle(
          controller: _controller3,
          begin: const Offset(110, 220),
          end: const Offset(180, 270),
          size: 200,
          color: thirdColor.withOpacity(isDark ? 0.2 : 0.12),
        ),
      ],
    );
  }

  Widget _buildCircle({
    required AnimationController controller,
    required Offset begin,
    required Offset end,
    required double size,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final offset = Offset.lerp(begin, end, Curves.easeInOut.transform(controller.value))!;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
