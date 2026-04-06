import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_colors.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/snackbar_utils.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/animated_background.dart';
import 'package:unibook/widgets/glass_card.dart';
import 'package:unibook/widgets/press_scale_button.dart';
import 'package:unibook/widgets/university_emblem.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _teacherCodeCtrl = TextEditingController();

  late final Future<List<DepartmentModel>> _departmentsFuture;

  String _role = 'student';
  String? _departmentId;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  bool get _requiresStaffCode => _role != 'student';

  double get _passwordStrength {
    final value = _passwordCtrl.text;
    if (value.isEmpty) return 0;
    var score = 0.0;
    if (value.length >= 8) score += 0.33;
    if (RegExp(r'[A-ZА-Я]').hasMatch(value) && RegExp(r'[0-9]').hasMatch(value)) {
      score += 0.33;
    }
    if (RegExp(r'[^A-Za-zА-Яа-я0-9]').hasMatch(value) || value.length >= 12) {
      score += 0.34;
    }
    return score.clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _departmentsFuture = context.read<FirestoreService>().getDepartments();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _teacherCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_departmentId == null) {
      showError(context, 'Выберите кафедру');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: _role,
      departmentId: _departmentId!,
      teacherCode: _teacherCodeCtrl.text,
    );

    if (!mounted) return;
    if (!ok) {
      showError(context, auth.error ?? 'Ошибка регистрации');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => const _SuccessDialog(),
    );
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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
            child: FutureBuilder<List<DepartmentModel>>(
              future: _departmentsFuture,
              builder: (context, snapshot) {
                final departments = snapshot.data ?? [];
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).maybePop(),
                                icon: Icon(Icons.arrow_back, color: textPrimary),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const UniversityEmblem(size: 72, textSize: 14),
                          const SizedBox(height: 12),
                          Text(
                            'Создать аккаунт',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _nameCtrl,
                            validator: Validators.requiredField,
                            decoration: const InputDecoration(
                              labelText: 'Имя и фамилия',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            decoration: const InputDecoration(
                              labelText: 'Email адрес',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePass,
                            validator: Validators.password,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Пароль',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              minHeight: 6,
                              color: _passwordStrength >= 1
                                  ? AppColors.success
                                  : (_passwordStrength >= 0.66
                                      ? Colors.orange
                                      : AppColors.error),
                              backgroundColor: textSecondary.withOpacity(0.35),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            obscureText: _obscureConfirm,
                            validator: (value) {
                              final err = Validators.password(value);
                              if (err != null) return err;
                              if (value != _passwordCtrl.text) return 'Пароли не совпадают';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Подтвердите пароль',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _role,
                            onChanged: (v) => setState(() => _role = v ?? 'student'),
                            decoration: const InputDecoration(
                              labelText: 'Роль',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Студент', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              DropdownMenuItem(
                                value: 'teacher',
                                child: Text('Учитель', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Мудири кафедра', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _departmentId,
                            hint: const Text('Выберите кафедру'),
                            onChanged: (v) => setState(() => _departmentId = v),
                            decoration: const InputDecoration(
                              labelText: 'Кафедра',
                              prefixIcon: Icon(Icons.school_outlined, color: AppColors.primary),
                            ),
                            items: departments
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d.id,
                                    child: Text(
                                      d.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: textPrimary),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _requiresStaffCode
                                ? Padding(
                                    key: const ValueKey('staffCode'),
                                    padding: const EdgeInsets.only(top: 12),
                                    child: TextFormField(
                                      controller: _teacherCodeCtrl,
                                      validator: _requiresStaffCode
                                          ? Validators.requiredField
                                          : null,
                                      decoration: const InputDecoration(
                                        labelText: 'Введите код учителя',
                                        prefixIcon: Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
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
                                      'Зарегистрироваться',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 60),
              SizedBox(height: 10),
              Text('Успешно!', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}