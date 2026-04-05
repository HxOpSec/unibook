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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();
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
    final ringOpacity = _fade(300, 900);
    final ringScale = Tween<double>(begin: 0.75, end: 1).animate(_fade(300, 900));
    final logoTextOpacity = _fade(600, 1000);
    final titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(_fade(900, 1400));

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
                  opacity: ringOpacity,
                  child: ScaleTransition(
                    scale: ringScale,
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
                            opacity: logoTextOpacity,
                            child: const TgfeuLogo(size: 112, textSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: titleSlide,
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
                  opacity: _fade(1200, 1600),
                  child: Text(
                    'Библиотека ТГФЭУ',
                    style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 16),
                  ),
                ),
                const SizedBox(height: 14),
                SizeTransition(
                  sizeFactor: _fade(1600, 1900),
                  axis: Axis.horizontal,
                  child: Container(
                    width: 200,
                    height: 2,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _fade(1800, 2200),
                  child: Text(
                    'Таджикский государственный',
                    style: TextStyle(color: Colors.white.withOpacity(0.82)),
                  ),
                ),
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: _fade(2000, 2400),
                  child: Text(
                    'финансово-экономический университет',
                    style: TextStyle(color: Colors.white.withOpacity(0.82)),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fade(2500, 3000),
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
