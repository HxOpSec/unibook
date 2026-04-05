import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/widgets/university_emblem.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _logoTextOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _dividerExpand;
  late final Animation<double> _line1Opacity;
  late final Animation<double> _line2Opacity;
  late final Animation<double> _progressOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();
    _ringOpacity = _fade(300, 900);
    _ringScale = Tween<double>(begin: 0.75, end: 1).animate(_fade(300, 900));
    _logoTextOpacity = _fade(600, 1000);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(_fade(900, 1400));
    _subtitleOpacity = _fade(1200, 1600);
    _dividerExpand = _fade(1600, 1900);
    _line1Opacity = _fade(1800, 2200);
    _line2Opacity = _fade(2000, 2400);
    _progressOpacity = _fade(2500, 3000);
    Future.delayed(const Duration(milliseconds: 3500), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).pushReplacementNamed(
      auth.isAuthenticated ? AppRoutes.home : AppRoutes.login,
    );
  }

  Animation<double> _fade(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin / 3500, end / 3500, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _ringOpacity,
                  child: ScaleTransition(
                    scale: _ringScale,
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 3),
                            ),
                          ),
                          FadeTransition(
                            opacity: _logoTextOpacity,
                            child: const TgfeuLogo(size: 112, textSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _titleSlide,
                  child: const Text(
                    'UniBook',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Text(
                    'Библиотека ТГФЭУ',
                    style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 16),
                  ),
                ),
                const SizedBox(height: 14),
                SizeTransition(
                  sizeFactor: _dividerExpand,
                  axis: Axis.horizontal,
                  child: Container(
                    width: 200,
                    height: 2,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _line1Opacity,
                  child: Text(
                    'Таджикский государственный',
                    style: TextStyle(color: Colors.white.withOpacity(0.82)),
                  ),
                ),
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: _line2Opacity,
                  child: Text(
                    'финансово-экономический университет',
                    style: TextStyle(color: Colors.white.withOpacity(0.82)),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _progressOpacity,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
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
