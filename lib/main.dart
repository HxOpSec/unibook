import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unibook/app.dart';
import 'package:unibook/core/constants/tgfeu_data.dart';
import 'package:unibook/firebase_options.dart';
import 'package:unibook/widgets/error_boundary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await seedDepartments();
  runApp(const ErrorBoundary(child: UniBookApp()));
}

Future<void> seedDepartments() async {
  const _maxBatchSize = 500;
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('departments').count().get();
  final currentCount = snapshot.count ?? 0;
  if (currentCount >= 20) return;

  final existing = await firestore.collection('departments').get();
  var batch = firestore.batch();
  var operations = 0;

  for (final doc in existing.docs) {
    batch.delete(doc.reference);
    operations++;
    if (operations >= _maxBatchSize) {
      await batch.commit();
      batch = firestore.batch();
      operations = 0;
    }
  }

  for (final dept in tgfeuDepartments) {
    final id = dept['id'] as String;
    batch.set(firestore.collection('departments').doc(id), {
      'name': dept['name'],
      'code': dept['code'],
      'facultyId': dept['facultyId'],
      'facultyName': facultyNameById(dept['facultyId'] as String),
      'building': dept['building'],
      'room': dept['room'],
      'icon': dept['icon'],
      'color': dept['color'],
      'head': '',
      'bookCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    operations++;
    if (operations >= _maxBatchSize) {
      await batch.commit();
      batch = firestore.batch();
      operations = 0;
    }
  }

  if (operations > 0) {
    await batch.commit();
  }
}
