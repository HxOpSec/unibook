import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/theme/app_theme.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/books_provider.dart';
import 'package:unibook/providers/upload_provider.dart';
import 'package:unibook/screens/admin/admin_departments_screen.dart';
import 'package:unibook/screens/admin/admin_screen.dart';
import 'package:unibook/screens/admin/admin_users_screen.dart';
import 'package:unibook/screens/auth/login_screen.dart';
import 'package:unibook/screens/auth/register_screen.dart';
import 'package:unibook/screens/home/book_list_screen.dart';
import 'package:unibook/screens/home/home_screen.dart';
import 'package:unibook/screens/profile/profile_screen.dart';
import 'package:unibook/screens/reader/pdf_reader_screen.dart';
import 'package:unibook/screens/splash/splash_screen.dart';
import 'package:unibook/screens/teacher/my_books_screen.dart';
import 'package:unibook/screens/teacher/upload_book_screen.dart';
import 'package:unibook/services/auth_service.dart';
import 'package:unibook/services/cloudinary_service.dart';
import 'package:unibook/services/firestore_service.dart';

class UniBookApp extends StatelessWidget {
  const UniBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ProxyProvider<FirestoreService, CloudinaryService>(
          update: (_, __, ___) => CloudinaryService(cloudName: 'demo'),
        ),
        ChangeNotifierProxyProvider2<AuthService, FirestoreService, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
          update: (_, authService, firestoreService, previous) =>
              previous ?? AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProxyProvider<FirestoreService, BooksProvider>(
          create: (context) => BooksProvider(context.read<FirestoreService>()),
          update: (_, firestore, previous) => previous ?? BooksProvider(firestore),
        ),
        ChangeNotifierProxyProvider2<CloudinaryService, FirestoreService, UploadProvider>(
          create: (context) => UploadProvider(
            context.read<CloudinaryService>(),
            context.read<FirestoreService>(),
          ),
          update: (_, cloudinary, firestore, previous) =>
              previous ?? UploadProvider(cloudinary, firestore),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniBook',
        theme: AppTheme.lightTheme(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.bookList: (_) => const BookListScreen(),
          AppRoutes.reader: (_) => const PdfReaderScreen(),
          AppRoutes.uploadBook: (_) => const UploadBookScreen(),
          AppRoutes.myBooks: (_) => const MyBooksScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.admin: (_) => const AdminScreen(),
          AppRoutes.adminUsers: (_) => const AdminUsersScreen(),
          AppRoutes.adminDepartments: (_) => const AdminDepartmentsScreen(),
        },
      ),
    );
  }
}
