import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unibook/app.dart';
import 'package:unibook/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await seedDepartments();
  runApp(const UniBookApp());
}

Future<void> seedDepartments() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('departments').limit(1).get();
  if (snapshot.docs.isNotEmpty) return;

  final departments = [
    {
      'id': 'dept_finance',
      'name': 'Кафедра финансов и кредита',
      'code': 'FIN',
      'bookCount': 0,
    },
    {
      'id': 'dept_accounting',
      'name': 'Кафедра бухгалтерского учёта',
      'code': 'ACC',
      'bookCount': 0,
    },
    {
      'id': 'dept_economics',
      'name': 'Кафедра экономики и менеджмента',
      'code': 'ECO',
      'bookCount': 0,
    },
    {
      'id': 'dept_banking',
      'name': 'Кафедра банковского дела',
      'code': 'BANK',
      'bookCount': 0,
    },
    {
      'id': 'dept_tax',
      'name': 'Кафедра налогов и налогообложения',
      'code': 'TAX',
      'bookCount': 0,
    },
    {
      'id': 'dept_math',
      'name': 'Кафедра математики и информатики',
      'code': 'MATH',
      'bookCount': 0,
    },
    {'id': 'dept_law', 'name': 'Кафедра права', 'code': 'LAW', 'bookCount': 0},
    {
      'id': 'dept_lang',
      'name': 'Кафедра иностранных языков',
      'code': 'LANG',
      'bookCount': 0,
    },
    {
      'id': 'dept_tjru',
      'name': 'Кафедра таджикского и русского языков',
      'code': 'TJRU',
      'bookCount': 0,
    },
    {
      'id': 'dept_history',
      'name': 'Кафедра истории и философии',
      'code': 'HIST',
      'bookCount': 0,
    },
    {
      'id': 'dept_sport',
      'name': 'Кафедра физического воспитания',
      'code': 'SPORT',
      'bookCount': 0,
    },
    {
      'id': 'dept_stat',
      'name': 'Кафедра статистики',
      'code': 'STAT',
      'bookCount': 0,
    },
  ];

  final batch = firestore.batch();
  for (final dept in departments) {
    final ref = firestore.collection('departments').doc(dept['id'] as String);
    batch.set(ref, {...dept, 'createdAt': FieldValue.serverTimestamp()});
  }
  await batch.commit();
}
