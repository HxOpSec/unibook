import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/constants/app_strings.dart';
import 'package:unibook/core/theme/app_theme.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/books_provider.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/providers/upload_provider.dart';
import 'package:unibook/screens/admin/admin_departments_screen.dart';
import 'package:unibook/screens/admin/admin_screen.dart';
import 'package:unibook/screens/admin/admin_users_screen.dart';
import 'package:unibook/screens/auth/login_screen.dart';
import 'package:unibook/screens/home/book_list_screen.dart';
import 'package:unibook/screens/home/home_screen.dart';
import 'package:unibook/screens/profile/profile_screen.dart';
import 'package:unibook/screens/reader/pdf_reader_screen.dart';
import 'package:unibook/screens/splash/splash_screen.dart';
import 'package:unibook/screens/teacher/my_books_screen.dart';
import 'package:unibook/screens/teacher/upload_book_screen.dart';
import 'package:unibook/services/firestore_service.dart';

class UniBookApp extends StatelessWidget {
  const UniBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(null, context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BooksProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UploadProvider(null, context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 350),
            data: settings.themeMode == ThemeMode.dark
                ? AppTheme.darkTheme()
                : AppTheme.lightTheme(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppStrings.translate('productName', languageCode: settings.languageCode),
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: settings.themeMode,
              home: const SplashScreen(),
              onGenerateRoute: (route) {
                final page = _resolvePage(route.name);
                return _fadeScale(page, route);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _resolvePage(String? name) {
    switch (name) {
      case AppRoutes.login:
        return const LoginScreen();
      case AppRoutes.home:
        return const HomeScreen();
      case AppRoutes.bookList:
        return const BookListScreen();
      case AppRoutes.reader:
        return const PdfReaderScreen();
      case AppRoutes.uploadBook:
        return const UploadBookScreen();
      case AppRoutes.myBooks:
        return const MyBooksScreen();
      case AppRoutes.profile:
        return const ProfileScreen();
      case AppRoutes.admin:
        return const AdminScreen();
      case AppRoutes.adminUsers:
        return const AdminUsersScreen();
      case AppRoutes.adminDepartments:
        return const AdminDepartmentsScreen();
      case AppRoutes.splash:
      default:
        return const SplashScreen();
    }
  }

  static PageRouteBuilder<dynamic> _fadeScale(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
