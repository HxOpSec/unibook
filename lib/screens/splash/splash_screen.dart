import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _progressOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.44, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.44, 0.78, curve: Curves.easeOut),
      ),
    );
    _progressOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(seconds: 3), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.of(context).pushReplacementNamed(
      auth.isAuthenticated ? AppRoutes.home : AppRoutes.login,
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _logoOpacity,
                child: const UniversityEmblem(size: 130, textSize: 24),
              ),
              const SizedBox(height: 22),
              SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    Text(
                      'UniBook',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Библиотека ТГФЭУ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _progressOpacity,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
