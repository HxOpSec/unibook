import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetailsHandler? _originalErrorHandler;
  ErrorCallback? _originalPlatformOnError;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _originalErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      _originalErrorHandler?.call(details);
      if (mounted) setState(() => _error = details.exception);
    };

    _originalPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _originalPlatformOnError?.call(error, stack);
      if (mounted) setState(() => _error = error);
      return true;
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _originalErrorHandler;
    PlatformDispatcher.instance.onError = _originalPlatformOnError;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error == null) {
      return widget.child;
    }
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Что-то пошло не так',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _error = null),
                  child: const Text('Перезапустить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
