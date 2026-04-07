import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;

  /// Builds a fade + slight scale-up transition.
  static Widget fadeScale(
    Widget child,
    Animation<double> animation, {
    double beginScale = 0.97,
  }) {
    final curved = CurvedAnimation(parent: animation, curve: standard);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: beginScale, end: 1).animate(curved),
        child: child,
      ),
    );
  }

  /// Builds a slide-up + fade transition.
  static Widget slideUp(
    Widget child,
    Animation<double> animation, {
    double beginOffset = 0.08,
  }) {
    final curved = CurvedAnimation(parent: animation, curve: standard);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, beginOffset),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  /// Returns a [PageRouteBuilder] with a fade-scale transition.
  static PageRouteBuilder<T> fadeScaleRoute<T>(
    Widget page, {
    RouteSettings? settings,
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          fadeScale(child, animation),
    );
  }

  /// Returns a [PageRouteBuilder] with a slide-up transition.
  static PageRouteBuilder<T> slideUpRoute<T>(
    Widget page, {
    RouteSettings? settings,
    Duration duration = normal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          slideUp(child, animation),
    );
  }
}
