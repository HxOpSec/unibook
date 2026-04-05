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

const String kCloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: '',
);

class UniBookApp extends StatelessWidget {
  const UniBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ProxyProvider<FirestoreService, CloudinaryService>(
          update: (_, __, ___) =>
              CloudinaryService(cloudName: kCloudinaryCloudName),
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
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.splash:
              page = const SplashScreen();
              break;
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.register:
              page = const RegisterScreen();
              break;
            case AppRoutes.home:
              page = const HomeScreen();
              break;
            case AppRoutes.bookList:
              page = const BookListScreen();
              break;
            case AppRoutes.reader:
              page = const PdfReaderScreen();
              break;
            case AppRoutes.uploadBook:
              page = const UploadBookScreen();
              break;
            case AppRoutes.myBooks:
              page = const MyBooksScreen();
              break;
            case AppRoutes.profile:
              page = const ProfileScreen();
              break;
            case AppRoutes.admin:
              page = const AdminScreen();
              break;
            case AppRoutes.adminUsers:
              page = const AdminUsersScreen();
              break;
            case AppRoutes.adminDepartments:
              page = const AdminDepartmentsScreen();
              break;
            default:
              page = const SplashScreen();
          }

          if (settings.name == AppRoutes.home) {
            return _slideUp(page, settings);
          }
          if (settings.name == AppRoutes.reader) {
            return _fadeScale(page, settings);
          }
          if (settings.name == AppRoutes.bookList ||
              settings.name == AppRoutes.profile ||
              settings.name == AppRoutes.admin) {
            return _slideFromRight(page, settings);
          }

          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
    );
  }

  static PageRouteBuilder<dynamic> _slideFromRight(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<dynamic> _slideUp(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<dynamic> _fadeScale(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
