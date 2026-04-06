import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_seeding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter framework error: ${details.exceptionAsString()}');
  };

  await _safeInitFirebase();

  runZonedGuarded(
    () {
      runApp(const UniBookApp());

      final shouldSeed = kDebugMode &&
          const bool.fromEnvironment('ENABLE_FIREBASE_SEED', defaultValue: false);
      Future<void>.microtask(() async {
        try {
          await seedFirebaseDemoData(enabled: shouldSeed);
        } catch (e, st) {
          debugPrint('Deferred seed failed: $e\n$st');
        }
      });
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error\n$stackTrace');
    },
  );
}

Future<void> _safeInitFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
    return;
  }

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings skipped: $e');
  }
}
