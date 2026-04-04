import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibook/core/constants/app_routes.dart';
import 'package:unibook/core/utils/validators.dart';
import 'package:unibook/models/department_model.dart';
import 'package:unibook/providers/auth_provider.dart';
import 'package:unibook/services/firestore_service.dart';
import 'package:unibook/widgets/university_emblem.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _teacherCodeCtrl = TextEditingController();

  String _role = 'student';
  String? _departmentId;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _teacherCodeCtrl.dispose();
    super.dispose();
  }

  /// Returns password strength in range 0..1 using length, uppercase,
  /// digits, and special characters as weighted criteria.
  double get _passwordStrength {
    final value = _passwordCtrl.text;
    if (value.isEmpty) return 0;

    var score = 0.0;
    if (value.length >= 8) score += 0.35;
    if (value.length >= 12) score += 0.15;
    if (RegExp(r'[A-ZА-Я]').hasMatch(value)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) score += 0.15;
    if (RegExp(r'[^A-Za-zА-Яа-я0-9]').hasMatch(value)) score += 0.15;

    return score.clamp(0, 1);
  }

  bool get _needsTeacherCode => _role == 'teacher' || _role == 'admin';

  Future<void> _showSuccessAnimation() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const _SuccessDialog();
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _departmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Пожалуйста, выберите кафедру'),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(auth.error ?? 'Ошибка регистрации. Попробуйте позже'),
        ),
      );
      return;
    }

    await _showSuccessAnimation();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UniversityEmblem(size: 82, textSize: 16),
                    SizedBox(height: 14),
                    Text(
                      'Создать аккаунт',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: FutureBuilder<List<DepartmentModel>>(
                    future: context.read<FirestoreService>().getDepartments(),
                    builder: (context, snapshot) {
                      final departments = snapshot.data ?? [];
                      return SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Шаг 1 из 1', style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: const LinearProgressIndicator(value: 1),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nameCtrl,
                                validator: Validators.requiredField,
                                decoration: const InputDecoration(
                                  labelText: 'Полное имя',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                validator: Validators.password,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Пароль',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _passwordStrength,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(999),
                                color: _passwordStrength >= 0.7
                                    ? Colors.green
                                    : (_passwordStrength >= 0.45
                                        ? Colors.orange
                                        : Colors.red),
                                backgroundColor: Colors.grey.shade200,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _confirmPasswordCtrl,
                                obscureText: true,
                                validator: (value) {
                                  if (Validators.password(value) case final error?) {
                                    return error;
                                  }
                                  if (value != _passwordCtrl.text) {
                                    return 'Пароли не совпадают';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Подтвердите пароль',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _role,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Text('Студент'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'teacher',
                                    child: Text('Учитель'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Text('Мудири кафедра'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _role = v ?? 'student'),
                                decoration: const InputDecoration(
                                  labelText: 'Роль',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _departmentId,
                                items: departments
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d.id,
                                        child: Text(d.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _departmentId = v),
                                decoration: const InputDecoration(
                                  labelText: 'Кафедра',
                                  prefixIcon: Icon(Icons.account_balance_outlined),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: !_needsTeacherCode
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: TextFormField(
                                          key: const ValueKey('teacher-code'),
                                          controller: _teacherCodeCtrl,
                                          validator: _needsTeacherCode
                                              ? Validators.requiredField
                                              : null,
                                          decoration: const InputDecoration(
                                            labelText: 'Код преподавателя/админа',
                                            prefixIcon: Icon(Icons.verified_outlined),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'Зарегистрироваться',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
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
      duration: const Duration(milliseconds: 550),
    )..forward();
    Future.delayed(const Duration(milliseconds: 950), () {
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
              Icon(Icons.check_circle, color: Colors.green, size: 62),
              SizedBox(height: 10),
              Text('Успешно!', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
