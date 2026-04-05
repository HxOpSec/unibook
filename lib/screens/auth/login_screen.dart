import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/providers/settings_provider.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/ddmit_logo.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/press_scale_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();
    final ok = await auth.login(email: _emailCtrl.text, password: _passwordCtrl.text);
    if (!mounted) return;
    if (!ok) {
      showError(context, auth.error ?? settings.t('errorGeneric'));
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    final settings = context.read<SettingsProvider>();
    if (email.isEmpty) {
      showError(context, settings.t('email'));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(email);
    if (!mounted) return;
    if (ok) {
      showSuccess(context, settings.t('resetPasswordSent'));
    } else {
      showError(context, auth.error ?? settings.t('errorGeneric'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final gradient = isDark
        ? const [AppColors.darkBackgroundStart, AppColors.darkBackgroundMid, AppColors.darkBackgroundEnd]
        : const [AppColors.lightBackgroundStart, AppColors.lightBackgroundMid, AppColors.lightBackgroundEnd];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: DdmitLogo(
                              size: 72,
                              text: settings.languageCode == 'en' ? 'DDMIT' : 'ДДМИТ',
                              textSize: settings.languageCode == 'en' ? 14 : 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              settings.t('adminLogin'),
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text(
                              settings.t('adminOnlyLoginHint'),
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailCtrl,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: settings.t('email'),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            validator: Validators.password,
                            obscureText: _obscure,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: settings.t('password'),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: loading ? null : _resetPassword,
                              child: Text(settings.t('forgotPassword')),
                            ),
                          ),
                          const SizedBox(height: 12),
                          PressScaleButton(
                            onTap: loading ? null : _submit,
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
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
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      settings.t('login'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
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
        ],
      ),
    );
  }
}
