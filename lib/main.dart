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
    debugPrint('seedDepartments error: $e');
  }
  try {
    await seedDemoBooks();
  } catch (e) {
    debugPrint('seedDemoBooks error: $e');
  }
  runApp(const UniBookApp());
}

// ---------------------------------------------------------------------------
// Department seed data
// Each entry uses the stable `doc(id)` key, the `color` field name that
// matches DepartmentModel.fromMap, and an explicit `facultyId`.
// ---------------------------------------------------------------------------

const _kDepartments = <Map<String, String>>[
  {'id': 'dept_world_economy',   'name': 'Кафедра мировой экономики',                               'code': 'ME',    'facultyId': 'faculty_meo',        'facultyName': 'Факультет МЭО',               'building': 'Корпус 1', 'room': '201',     'icon': 'public',            'color': '#1565C0'},
  {'id': 'dept_customs',         'name': 'Кафедра таможенной деятельности',                         'code': 'TAM',   'facultyId': 'faculty_customs',    'facultyName': 'Факультет таможни',           'building': 'Корпус 2', 'room': '105',     'icon': 'security',          'color': '#4A148C'},
  {'id': 'dept_fin_economics',   'name': 'Кафедра финансовой экономики',                            'code': 'FE',    'facultyId': 'faculty_finance',    'facultyName': 'Факультет финансов',          'building': 'Корпус 1', 'room': '310',     'icon': 'trending_up',       'color': '#00695C'},
  {'id': 'dept_banking',         'name': 'Кафедра банковской деятельности',                         'code': 'BANK',  'facultyId': 'faculty_finance',    'facultyName': 'Факультет финансов',          'building': 'Корпус 2', 'room': '215',     'icon': 'account_balance',   'color': '#1B5E20'},
  {'id': 'dept_finance',         'name': 'Кафедра финансов',                                        'code': 'FIN',   'facultyId': 'faculty_finance',    'facultyName': 'Факультет финансов',          'building': 'Корпус 1', 'room': '205',     'icon': 'payments',          'color': '#0D47A1'},
  {'id': 'dept_econ_analysis',   'name': 'Кафедра экономического анализа и статистики',             'code': 'EAS',   'facultyId': 'faculty_accounting', 'facultyName': 'Факультет бухучёта',          'building': 'Корпус 2', 'room': '301',     'icon': 'bar_chart',         'color': '#E65100'},
  {'id': 'dept_audit',           'name': 'Кафедра аудита и ревизии',                                'code': 'AUD',   'facultyId': 'faculty_accounting', 'facultyName': 'Факультет бухучёта',          'building': 'Корпус 2', 'room': '302',     'icon': 'fact_check',        'color': '#880E4F'},
  {'id': 'dept_accounting',      'name': 'Кафедра бухгалтерского учёта',                            'code': 'ACC',   'facultyId': 'faculty_accounting', 'facultyName': 'Факультет бухучёта',          'building': 'Корпус 2', 'room': '210',     'icon': 'calculate',         'color': '#2E7D32'},
  {'id': 'dept_fin_management',  'name': 'Кафедра финансового менеджмента',                         'code': 'FM',    'facultyId': 'faculty_management', 'facultyName': 'Факультет менеджмента',       'building': 'Корпус 1', 'room': '401',     'icon': 'manage_accounts',   'color': '#6A1B9A'},
  {'id': 'dept_tax',             'name': 'Кафедра налогообложения и страхования',                   'code': 'TAX',   'facultyId': 'faculty_customs',    'facultyName': 'Факультет таможни',           'building': 'Корпус 2', 'room': '110',     'icon': 'receipt_long',      'color': '#BF360C'},
  {'id': 'dept_applied_info',    'name': 'Кафедра прикладной информатики в экономике',              'code': 'AIE',   'facultyId': 'faculty_digital',    'facultyName': 'Факультет цифровой экономики','building': 'Корпус 3', 'room': '101',     'icon': 'computer',          'color': '#0277BD'},
  {'id': 'dept_digital',         'name': 'Кафедра цифровой экономики и логистики',                  'code': 'DEL',   'facultyId': 'faculty_digital',    'facultyName': 'Факультет цифровой экономики','building': 'Корпус 3', 'room': '205',     'icon': 'devices',           'color': '#006064'},
  {'id': 'dept_info_systems',    'name': 'Кафедра информационно-инновационных систем',              'code': 'IIS',   'facultyId': 'faculty_digital',    'facultyName': 'Факультет цифровой экономики','building': 'Корпус 3', 'room': '210',     'icon': 'hub',               'color': '#1A237E'},
  {'id': 'dept_intl_finance',    'name': 'Кафедра международных финансово-кредитных отношений',     'code': 'IFC',   'facultyId': 'faculty_meo',        'facultyName': 'Факультет МЭО',               'building': 'Корпус 1', 'room': '315',     'icon': 'currency_exchange', 'color': '#004D40'},
  {'id': 'dept_management',      'name': 'Кафедра менеджмента',                                     'code': 'MAN',   'facultyId': 'faculty_management', 'facultyName': 'Факультет менеджмента',       'building': 'Корпус 1', 'room': '405',     'icon': 'business_center',   'color': '#37474F'},
  {'id': 'dept_econ_law',        'name': 'Кафедра экономического права',                            'code': 'LAW',   'facultyId': 'faculty_management', 'facultyName': 'Факультет менеджмента',       'building': 'Корпус 1', 'room': '410',     'icon': 'gavel',             'color': '#3E2723'},
  {'id': 'dept_enterprise',      'name': 'Кафедра экономики предприятий и предпринимательства',     'code': 'EEE',   'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 2', 'room': '401',     'icon': 'store',             'color': '#827717'},
  {'id': 'dept_econ_theory',     'name': 'Кафедра экономической теории',                            'code': 'ET',    'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 2', 'room': '405',     'icon': 'school',            'color': '#558B2F'},
  {'id': 'dept_foreign_lang',    'name': 'Кафедра иностранных языков',                              'code': 'FL',    'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 1', 'room': '115',     'icon': 'language',          'color': '#AD1457'},
  {'id': 'dept_tj_ru_lang',      'name': 'Кафедра таджикского и русского языков',                   'code': 'TRL',   'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 1', 'room': '120',     'icon': 'translate',         'color': '#283593'},
  {'id': 'dept_math_it',         'name': 'Кафедра математики и информационных технологий',          'code': 'MIT',   'facultyId': 'faculty_digital',    'facultyName': 'Факультет цифровой экономики','building': 'Корпус 3', 'room': '301',     'icon': 'functions',         'color': '#0288D1'},
  {'id': 'dept_sport',           'name': 'Кафедра физического воспитания',                          'code': 'SPORT', 'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 4', 'room': 'Спортзал','icon': 'sports',            'color': '#2E7D32'},
  {'id': 'dept_history',         'name': 'Кафедра истории и философии',                             'code': 'HIST',  'facultyId': 'faculty_economics',  'facultyName': 'Факультет экономики',         'building': 'Корпус 1', 'room': '225',     'icon': 'history_edu',       'color': '#4E342E'},
  {'id': 'dept_statistics',      'name': 'Кафедра статистики',                                      'code': 'STAT',  'facultyId': 'faculty_accounting', 'facultyName': 'Факультет бухучёта',          'building': 'Корпус 2', 'room': '315',     'icon': 'analytics',         'color': '#00695C'},
];

// ---------------------------------------------------------------------------
// Demo book seed data
// Replace the placeholder fileUrl/publicId/coverUrl values before going live.
// ---------------------------------------------------------------------------

const _kDemoBooks = <Map<String, Object>>[
  {
    'id':           'demo_book_fin_analysis',
    'title':        'Финансовый анализ предприятия',
    'author':       'А. В. Грачёв',
    'year':         2021,
    'subject':      'Финансовый анализ',
    'departmentId': 'dept_fin_economics',
    'uploadedBy':   'demo_user',
    'uploaderName': 'Demo User',
    // TODO: replace with a real Cloudinary URL before going to production.
    'fileUrl':      'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    'publicId':     'unibook/books/demo_book_fin_analysis',
    'coverUrl':     '',
    'downloadCount': 0,
  },
  {
    'id':           'demo_book_econ_theory',
    'title':        'Основы экономической теории',
    'author':       'П. А. Самуэльсон',
    'year':         2019,
    'subject':      'Экономическая теория',
    'departmentId': 'dept_econ_theory',
    'uploadedBy':   'demo_user',
    'uploaderName': 'Demo User',
    // TODO: replace with a real Cloudinary URL before going to production.
    'fileUrl':      'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    'publicId':     'unibook/books/demo_book_econ_theory',
    'coverUrl':     '',
    'downloadCount': 0,
  },
  {
    'id':           'demo_book_digital_econ',
    'title':        'Цифровая экономика и информационные технологии',
    'author':       'В. Б. Кузнецов',
    'year':         2022,
    'subject':      'Цифровая экономика',
    'departmentId': 'dept_digital',
    'uploadedBy':   'demo_user',
    'uploaderName': 'Demo User',
    // TODO: replace with a real Cloudinary URL before going to production.
    'fileUrl':      'https://www.w3.org/WAI/WCAG21/Techniques/pdf/pdf-sample.pdf',
    'publicId':     'unibook/books/demo_book_digital_econ',
    'coverUrl':     '',
    'downloadCount': 0,
  },
];

// ---------------------------------------------------------------------------
// Bootstrap helpers
// ---------------------------------------------------------------------------

/// Seeds the [departments] collection idempotently.
///
/// The collection is checked with a single [limit](1) read before any write.
/// If documents already exist the function returns immediately without
/// performing any Firestore writes.
Future<void> seedDepartments() async {
  final firestore = FirebaseFirestore.instance;
  final check = await firestore.collection('departments').limit(1).get();
  if (check.docs.isNotEmpty) {
    debugPrint('ℹ️  seedDepartments: collection already populated — skipped');
    return;
  }
  final batch = firestore.batch();
  for (final dept in _kDepartments) {
    final id = dept['id'] as String;
    final data = <String, dynamic>{
      'name':        dept['name'],
      'code':        dept['code'],
      'facultyId':   dept['facultyId'],
      'facultyName': dept['facultyName'],
      'building':    dept['building'],
      'room':        dept['room'],
      'icon':        dept['icon'],
      'color':       dept['color'],
      'head':        '',
      'bookCount':   0,
      'createdAt':   FieldValue.serverTimestamp(),
    };
    batch.set(firestore.collection('departments').doc(id), data);
  }
  await batch.commit();
  debugPrint('✅ seedDepartments: seeded ${_kDepartments.length} departments');
}

/// Seeds the [books] collection with a small set of demo books idempotently.
///
/// Runs only when the [books] collection is empty (checked via [limit](1)).
/// Each demo document is written with its stable id so subsequent launches
/// will find the collection non-empty and skip the seed.
Future<void> seedDemoBooks() async {
  final firestore = FirebaseFirestore.instance;
  final check = await firestore.collection('books').limit(1).get();
  if (check.docs.isNotEmpty) {
    debugPrint('ℹ️  seedDemoBooks: collection already populated — skipped');
    return;
  }
  final batch = firestore.batch();
  for (final book in _kDemoBooks) {
    final id = book['id'] as String;
    final data = <String, dynamic>{
      'title':         book['title'],
      'author':        book['author'],
      'year':          book['year'],
      'subject':       book['subject'],
      'departmentId':  book['departmentId'],
      'uploadedBy':    book['uploadedBy'],
      'uploaderName':  book['uploaderName'],
      'fileUrl':       book['fileUrl'],
      'publicId':      book['publicId'],
      'coverUrl':      book['coverUrl'],
      'downloadCount': book['downloadCount'],
      'createdAt':     FieldValue.serverTimestamp(), // always set at write time
    };
    batch.set(firestore.collection('books').doc(id), data);
  }
  await batch.commit();
  debugPrint('✅ seedDemoBooks: seeded ${_kDemoBooks.length} demo books');
}
