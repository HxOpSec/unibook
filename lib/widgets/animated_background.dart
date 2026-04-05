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
  late final AnimationController _c1;
  late final AnimationController _c2;
  late final AnimationController _c3;
  late final AnimationController _c4;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 24))
      ..repeat(reverse: true);
    _c4 = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark
        ? [
            AppColors.primary.withOpacity(0.28),
            AppColors.primaryLight.withOpacity(0.20),
            AppColors.primaryDark.withOpacity(0.26),
            AppColors.darkAccentDeep.withOpacity(0.24),
          ]
        : [
            AppColors.lightAccent.withOpacity(0.18),
            AppColors.primary.withOpacity(0.14),
            AppColors.primaryLight.withOpacity(0.12),
            AppColors.primaryDark.withOpacity(0.10),
          ];

    return IgnorePointer(
      child: Stack(
        children: [
          _bubble(_c1, const Offset(-80, -60), const Offset(40, 30), 280, palette[0]),
          _bubble(_c2, const Offset(220, 120), const Offset(140, 240), 220, palette[1]),
          _bubble(_c3, const Offset(180, 520), const Offset(60, 430), 300, palette[2]),
          _bubble(_c4, const Offset(-40, 460), const Offset(70, 320), 240, palette[3]),
        ],
      ),
    );
  }

  Widget _bubble(
    AnimationController controller,
    Offset begin,
    Offset end,
    double size,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(controller.value);
        final offset = Offset.lerp(begin, end, t)!;
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
