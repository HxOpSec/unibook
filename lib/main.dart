import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings error: $e');
  }
  try {
    await seedDepartments();
  } catch (e) {
    debugPrint('Seed error: $e');
  }
  try {
    await seedDemoBooks();
  } catch (e) {
    debugPrint('Demo books seed error: $e');
  }
  runApp(const UniBookApp());
}

Future<void> seedDepartments() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('departments').limit(1).get();
  if (snapshot.docs.isNotEmpty) return;
  final departments = [
    {'id':'dept_world_economy','name':'Кафедра мировой экономики','code':'ME','facultyName':'Факультет МЭО','building':'Корпус 1','room':'201','icon':'public','colorHex':'#1565C0'},
    {'id':'dept_customs','name':'Кафедра таможенной деятельности','code':'TAM','facultyName':'Факультет таможни','building':'Корпус 2','room':'105','icon':'security','colorHex':'#4A148C'},
    {'id':'dept_fin_economics','name':'Кафедра финансовой экономики','code':'FE','facultyName':'Факультет финансов','building':'Корпус 1','room':'310','icon':'trending_up','colorHex':'#00695C'},
    {'id':'dept_banking','name':'Кафедра банковской деятельности','code':'BANK','facultyName':'Факультет финансов','building':'Корпус 2','room':'215','icon':'account_balance','colorHex':'#1B5E20'},
    {'id':'dept_finance','name':'Кафедра финансов','code':'FIN','facultyName':'Факультет финансов','building':'Корпус 1','room':'205','icon':'payments','colorHex':'#0D47A1'},
    {'id':'dept_econ_analysis','name':'Кафедра экономического анализа и статистики','code':'EAS','facultyName':'Факультет бухучёта','building':'Корпус 2','room':'301','icon':'bar_chart','colorHex':'#E65100'},
    {'id':'dept_audit','name':'Кафедра аудита и ревизии','code':'AUD','facultyName':'Факультет бухучёта','building':'Корпус 2','room':'302','icon':'fact_check','colorHex':'#880E4F'},
    {'id':'dept_accounting','name':'Кафедра бухгалтерского учёта','code':'ACC','facultyName':'Факультет бухучёта','building':'Корпус 2','room':'210','icon':'calculate','colorHex':'#2E7D32'},
    {'id':'dept_fin_management','name':'Кафедра финансового менеджмента','code':'FM','facultyName':'Факультет менеджмента','building':'Корпус 1','room':'401','icon':'manage_accounts','colorHex':'#6A1B9A'},
    {'id':'dept_tax','name':'Кафедра налогообложения и страхования','code':'TAX','facultyName':'Факультет таможни','building':'Корпус 2','room':'110','icon':'receipt_long','colorHex':'#BF360C'},
    {'id':'dept_applied_info','name':'Кафедра прикладной информатики в экономике','code':'AIE','facultyName':'Факультет цифровой экономики','building':'Корпус 3','room':'101','icon':'computer','colorHex':'#0277BD'},
    {'id':'dept_digital','name':'Кафедра цифровой экономики и логистики','code':'DEL','facultyName':'Факультет цифровой экономики','building':'Корпус 3','room':'205','icon':'devices','colorHex':'#006064'},
    {'id':'dept_info_systems','name':'Кафедра информационно-инновационных систем','code':'IIS','facultyName':'Факультет цифровой экономики','building':'Корпус 3','room':'210','icon':'hub','colorHex':'#1A237E'},
    {'id':'dept_intl_finance','name':'Кафедра международных финансово-кредитных отношений','code':'IFC','facultyName':'Факультет МЭО','building':'Корпус 1','room':'315','icon':'currency_exchange','colorHex':'#004D40'},
    {'id':'dept_management','name':'Кафедра менеджмента','code':'MAN','facultyName':'Факультет менеджмента','building':'Корпус 1','room':'405','icon':'business_center','colorHex':'#37474F'},
    {'id':'dept_econ_law','name':'Кафедра экономического права','code':'LAW','facultyName':'Факультет менеджмента','building':'Корпус 1','room':'410','icon':'gavel','colorHex':'#3E2723'},
    {'id':'dept_enterprise','name':'Кафедра экономики предприятий и предпринимательства','code':'EEE','facultyName':'Факультет экономики','building':'Корпус 2','room':'401','icon':'store','colorHex':'#827717'},
    {'id':'dept_econ_theory','name':'Кафедра экономической теории','code':'ET','facultyName':'Факультет экономики','building':'Корпус 2','room':'405','icon':'school','colorHex':'#558B2F'},
    {'id':'dept_foreign_lang','name':'Кафедра иностранных языков','code':'FL','facultyName':'Факультет экономики','building':'Корпус 1','room':'115','icon':'language','colorHex':'#AD1457'},
    {'id':'dept_tj_ru_lang','name':'Кафедра таджикского и русского языков','code':'TRL','facultyName':'Факультет экономики','building':'Корпус 1','room':'120','icon':'translate','colorHex':'#283593'},
    {'id':'dept_math_it','name':'Кафедра математики и информационных технологий','code':'MIT','facultyName':'Факультет цифровой экономики','building':'Корпус 3','room':'301','icon':'functions','colorHex':'#0288D1'},
    {'id':'dept_sport','name':'Кафедра физического воспитания','code':'SPORT','facultyName':'Факультет экономики','building':'Корпус 4','room':'Спортзал','icon':'sports','colorHex':'#2E7D32'},
    {'id':'dept_history','name':'Кафедра истории и философии','code':'HIST','facultyName':'Факультет экономики','building':'Корпус 1','room':'225','icon':'history_edu','colorHex':'#4E342E'},
    {'id':'dept_statistics','name':'Кафедра статистики','code':'STAT','facultyName':'Факультет бухучёта','building':'Корпус 2','room':'315','icon':'analytics','colorHex':'#00695C'},
  ];
  final batch = firestore.batch();
  for (final dept in departments) {
    final id = dept['id'] as String;
    final data = Map<String, dynamic>.from(dept)
      ..remove('id')
      ..['bookCount'] = 0
      ..['createdAt'] = FieldValue.serverTimestamp();
    batch.set(firestore.collection('departments').doc(id), data);
  }
  await batch.commit();
  debugPrint('✅ Seeded 24 departments');
}

/// Seeds 3 demo books idempotently — runs only when none of the demo documents
/// exist yet. Safe to call on every startup.
Future<void> seedDemoBooks() async {
  final firestore = FirebaseFirestore.instance;
  const demoIds = ['demo_book_001', 'demo_book_002', 'demo_book_003'];

  // Check whether the first demo book already exists; if so, skip seeding.
  final existing = await firestore.collection('books').doc(demoIds.first).get();
  if (existing.exists) return;

  final now = Timestamp.now();
  final demoBooks = [
    {
      'id': 'demo_book_001',
      'title': 'Основы финансового анализа',
      'author': 'Иванов А.Н.',
      'year': 2022,
      'subject': 'Финансовый анализ',
      'departmentId': 'dept_fin_economics',
      'uploadedBy': 'demo_admin',
      'uploaderName': 'Администратор (демо)',
      'fileUrl':
          'https://www.w3.org/WAI/WCAG21/Techniques/pdf/sample-pdf-files/bookmarks.pdf',
      'publicId': 'unibook/books/demo_book_001',
      'coverUrl': null,
      'downloadCount': 0,
      'createdAt': now,
    },
    {
      'id': 'demo_book_002',
      'title': 'Цифровая экономика: теория и практика',
      'author': 'Рахимов Б.С.',
      'year': 2023,
      'subject': 'Цифровая экономика',
      'departmentId': 'dept_digital',
      'uploadedBy': 'demo_admin',
      'uploaderName': 'Администратор (демо)',
      'fileUrl':
          'https://www.w3.org/WAI/WCAG21/Techniques/pdf/sample-pdf-files/bookmarks.pdf',
      'publicId': 'unibook/books/demo_book_002',
      'coverUrl': null,
      'downloadCount': 0,
      'createdAt': now,
    },
    {
      'id': 'demo_book_003',
      'title': 'Бухгалтерский учёт в организации',
      'author': 'Назаров Ш.Т.',
      'year': 2021,
      'subject': 'Бухгалтерский учёт',
      'departmentId': 'dept_accounting',
      'uploadedBy': 'demo_admin',
      'uploaderName': 'Администратор (демо)',
      'fileUrl':
          'https://www.w3.org/WAI/WCAG21/Techniques/pdf/sample-pdf-files/bookmarks.pdf',
      'publicId': 'unibook/books/demo_book_003',
      'coverUrl': null,
      'downloadCount': 0,
      'createdAt': now,
    },
  ];

  final batch = firestore.batch();
  for (final book in demoBooks) {
    final id = book['id'] as String;
    final data = Map<String, dynamic>.from(book)..remove('id');
    batch.set(firestore.collection('books').doc(id), data);
  }
  await batch.commit();
  debugPrint('✅ Seeded 3 demo books');
}
