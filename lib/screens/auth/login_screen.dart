import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/press_scale_button.dart';
import 'package:unibook/widgets/university_emblem.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  static const _shakeScale = 4.0;
  static const _shakeAmplitude = 10.0;
  static const _shakeMidpoint = 0.5;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _cardController;
  late final AnimationController _shakeController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _cardController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email: _emailCtrl.text, password: _passwordCtrl.text);
    if (!mounted) return;
    if (!ok) {
      _shakeController.forward(from: 0);
      showError(context, auth.error ?? 'Ошибка входа');
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      showError(context, 'Введите email для сброса пароля');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(email);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Проверьте почту для сброса пароля');
    } else {
      showError(context, auth.error ?? 'Ошибка сброса пароля');
    }
  }

  Future<void> _loginAsDeveloper() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginAsDeveloper();
    if (!mounted) return;
    if (!ok) {
      showError(context, auth.error ?? 'Ошибка входа');
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final backgroundGradient = isDark
        ? const [
            AppColors.darkBackgroundStart,
            AppColors.darkBackgroundMid,
            AppColors.darkBackgroundEnd,
          ]
        : const [
            AppColors.lightBackgroundStart,
            AppColors.lightBackgroundMid,
            AppColors.lightBackgroundEnd,
          ];
    final cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: backgroundGradient,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: SlideTransition(
                  position: cardSlide,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    child: Form(
                      key: _formKey,
                      child: AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final p = _shakeController.value;
                          final offset = (p * (1 - p) * _shakeScale) *
                              _shakeAmplitude *
                              (p < _shakeMidpoint ? 1 : -1);
                          return Transform.translate(offset: Offset(offset, 0), child: child);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(child: TgfeuLogo(size: 72, textSize: 14)),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'UniBook',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Center(
                              child: Text(
                                'Библиотека ТГФЭУ',
                                style: TextStyle(color: textSecondary, fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Добро пожаловать!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Войдите в свой аккаунт',
                              style: TextStyle(fontSize: 14, color: textSecondary),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              decoration: const InputDecoration(
                                labelText: 'Email адрес',
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              validator: Validators.password,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Spacer(),
                                TextButton(
                                  onPressed: _resetPassword,
                                  child: const Text(
                                    'Забыли пароль?',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            PressScaleButton(
                              onTap: loading ? null : _submit,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryLight],
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Войти',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Divider(color: textSecondary.withOpacity(0.25))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('или', style: TextStyle(color: textSecondary)),
                                ),
                                Expanded(child: Divider(color: textSecondary.withOpacity(0.25))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: loading
                                    ? null
                                    : () => Navigator.of(context).pushNamed(AppRoutes.register),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Создать аккаунт',
                                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (kDebugMode)
                              Center(
                                child: TextButton(
                                  onPressed: loading ? null : _loginAsDeveloper,
                                  child: Text(
                                    'Войти как разработчик',
                                    style: TextStyle(fontSize: 13, color: textSecondary),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
